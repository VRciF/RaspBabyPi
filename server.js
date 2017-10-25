const exec = require('child_process').exec;
const execSync = require('child_process').execSync;
var ws = require("nodejs-websocket")
var path = require('path')
var Inotify = require('inotify').Inotify;
var fs = require('fs-extra')
var http = require('http');

var httpServer = null;
var server = null;
var disableAudio = false;

var inotify = new Inotify(); //persistent by default, new Inotify(false) //no persistent

function execute(command, callback){
    exec(command, function(error, stdout, stderr){ callback(stdout, stderr); });
};

function sendContent(conn){
    try{
        conn.isDrain = false;

        var msg = { audio: null, video: null, audioName: null, disableAudio: disableAudio };
        if(conn.messageQueue.audio){
            msg.audio = conn.messageQueue.audio.toString('base64');
            msg.audioName = conn.messageQueue.audioName;
        }
        if(conn.messageQueue.video){
            msg.video = conn.messageQueue.video.toString('base64');
        }

        conn.messageQueue.audio = null;
        conn.messageQueue.video = null;

        //console.log("sending packet: ", msg);

        conn.sendText(JSON.stringify(msg));
    }catch(e){
        console.log("sending failed: ", e);
    }
}

var isAudioPostProcessRunning = false;

var postAudio = null;

function readAudioFile(filename){
    var parsedPath = path.parse(filename);
    var name = parsedPath.base;

        fs.readFile(filename, function(err, content){
           if(err){ return; }

           //console.log("file read: ", filename, content, fs.statSync(filename));
           for(var i=0;i<server.connections.length;i++){
               server.connections[i].messageQueue.audio = content;
               server.connections[i].messageQueue.audioName = name;

               if(server.connections[i].isDrain){
                   sendContent(server.connections[i]);
               }
           }
           updateNoiseProfile(filename);
        });
}

function updateNoiseProfile(filename){
    execute("sox "+filename+" -n stat", function(stdout, stderr){
        postAudio = null;
        isAudioPostProcessRunning = false;

                var lines = stderr.split('\n');
                for(var i=0;i<lines.length;i++){
                    if(lines[i].indexOf("Maximum amplitude")==-1){ continue; }
                    var amp = parseFloat(lines[i].replace( /^\D+/g, ''));
                    if(amp <= 0.013){ break; }
                    if(minimumAmplitude == null || amp < minimumAmplitude){
                        minimumAmplitude = amp;
                        //console.log("new noise: ", minimumAmplitude);
                        execute("sox "+filename+" -n noiseprof "+__dirname+"/noise.prof", function(){});
                    }
                    break;
                }
    });
}

function postProcessAudio(){
    if(!postAudio){ return; }

    if(isAudioPostProcessRunning){ return; }

    isAudioPostProcessRunning = true;

    var filename = postAudio;

    fs.access(__dirname+"/noise.prof", fs.constants.F_OK, function(err){
        if(err){
            readAudioFile(filename);
        }
        else{
            exec("sox "+filename+" "+filename+".cleaned.mp3 noisered "+__dirname+"/noise.prof 0.21", function(error, stdout, stderr){
                execSync("mv "+filename+".cleaned.mp3 "+filename);
                readAudioFile(filename);
            });
        }
    });
}

var previousAudio = null;
var minimumAmplitude = null;

var callback = function(av, event) {
    var mask = event.mask;
    var type = mask & Inotify.IN_ISDIR ? 'directory ' : 'file ';
    if (event.name) {
        type += ' ' + event.name + ' ';
    } else {
        type += ' ';
    }
    //console.log(type);
    // the purpose of this hell of 'if' statements is only illustrative.

    if (!(mask & Inotify.IN_CLOSE_WRITE)) {
        return;
    }

    var isaudio = (av=='audio') ? true : false;
    if(isaudio && disableAudio){ return; } 

    //if(isaudio){
    //    if(!previousAudio){ previousAudio = event.name; return; }
    //    if(previousAudio == event.name){ return; }
    //    event.name = previousAudio;
    //    previousAudio = null;
    //}

    var parsedPath = path.parse(event.name);
    var parts = parsedPath.name.split("_");
    var no = parts[1];

    try{
        var filename = __dirname+"/"+av+"/"+event.name;
        if (!fs.existsSync(filename)) { return; }

        if(isaudio){ postAudio = filename; }
        else{
            var content = fs.readFileSync(filename);
            //console.log("file read: ", filename, content, fs.statSync(filename));
            fs.unlinkSync(filename);
            for(var i=0;i<server.connections.length;i++){
                server.connections[i].messageQueue.video = content;
                if(server.connections[i].isDrain){
                    sendContent(server.connections[i]);
                }
            }
        }
    }catch(e){
        console.log("reading file failed: "+event.name, e);
    }
}

var audio_dir = {
    // Change this for a valid directory in your machine.
    path:      __dirname+'/audio',
    watch_for: Inotify.IN_CLOSE_WRITE,
    callback:  function(ev){ callback('audio', ev); },
};
var audio_watch_descriptor = inotify.addWatch(audio_dir);

var video_dir = {
    // Change this for a valid directory in your machine.
    path:      __dirname+'/video',
    watch_for: Inotify.IN_CLOSE_WRITE,
    callback:  function(ev){ callback('video', ev); },
};
var video_watch_descriptor = inotify.addWatch(video_dir);

//process.stdout.on('error', function( err ) {
//    if (err.code == "EPIPE") {
//        process.exit(0);
//    }
//});

server = ws.createServer(function (conn) {
    //console.log("new connection: ", new Date());
    conn.sendAudio = false;
    conn.sendVideo = false;
    conn.isDrain = true;

    conn.messageQueue = { audio: null, video: null, audioName: null };

    conn.on("text", function (str) {
        var data = JSON.parse(str);
        switch(data.cmd){
            case "received":
                conn.isDrain = true;
                if(conn.messageQueue.audio || conn.messageQueue.audio){
                    process.nextTick(function(){sendContent(conn)});
                }
                break;
            case "reboot":
                exec("reboot");
                break;
            case "shutdown":
                exec("shutdown -h now");
                break;
            case "toggleAudio":
                disableAudio = !disableAudio;
                break;
        }
    })
    conn.on("error", function(err){
        console.log("connection error", err);
        conn.close();
    });
    conn.on("close", function (code, reason) {
        //console.log("Connection closed", code, reason);
    });
}).listen(8080);

var httpdispatcher = require('httpdispatcher');
var dispatcher = new httpdispatcher();
dispatcher.setStaticDirname(__dirname);
dispatcher.setStatic('.');
dispatcher.onGet("/", function(request, response) {
    var filePath = path.join(__dirname, 'index.html');
    var stat = fs.statSync(filePath);

    response.writeHead(200, {
        'Content-Type': 'text/html',
        'Content-Length': stat.size
    });

    var readStream = fs.createReadStream(filePath);
    // We replaced all the event handlers with a simple call to readStream.pipe()
    readStream.pipe(response);
});

httpServer = http.createServer(function(request, response){
    try {
        //console.log(request.url);

        var filePath = path.join(__dirname, request.url);
        var head = {};
        if(request.url == '/'){
            filePath = path.join(__dirname, 'index.html');
            head['Content-Type'] = 'text/html';
        }
        var stat = fs.statSync(filePath);
        head['Content-Length'] = stat.size;
        var stat = fs.statSync(filePath);
        response.writeHead(200, head);
        var readStream = fs.createReadStream(filePath);
        readStream.pipe(response);

        //log the request on console
        //console.log(request.url);
        //Disptach
        //dispatcher.dispatch(request, response);
    } catch(err) {
        console.log(err);
    }
});

httpServer.listen(80, function(){
    console.log("server listening");
});

setTimeout(postProcessAudio, 1000);

