var socket = require('socket.io-client')('https://ozbargains.appspot.com');

console.log("Socket acquired");
socket.on('connect', function(){

    console.log("Connected");

});
socket.on('deals', function(data){ 

    console.log("Received deals ",data.length);
    console.log(data[0]);
});

socket.on('message', function(data){ 
    console.log("Message received");
    console.log(data);
});
socket.on('disconnect', function(){

    console.log('Disconnected');
});
