    /* jshint esversion: 8 */
const request = require('request');

(async()=>{
    const url = 'https://ozbargains.omkaars.dev';
    //const url = 'https://ozbargains.appspot.com';

var socketUrl = await getUrl(url);
console.log(socketUrl);

var socket = require('socket.io-client')(socketUrl);

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

})();

function getUrl(url)
{
    return new Promise(function(resolve, reject){
        try{
            var r = request(url, function (e, response) {
                resolve(r.uri.href);
              });
        }
        catch(e)
        {
            reject(e);
        }
        });
}