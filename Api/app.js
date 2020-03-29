/* jshint esversion:8 */

const express = require("express");
const compression = require("compression");
const ozbargain = require("./ozbargain");
const bodyParser = require('body-parser');
const {PubSub} = require('@google-cloud/pubsub');

const putenv = require("putenv");
const app = express();
const PORT = process.env.PORT || 80;
const SOCKS_PORT = process.env.SOCKS_PORT || 8080;
const moment = require("moment");
const log = console.log;
const logError = console.error;

const pubsub = new PubSub();

const server = require('http').Server(app);
const io = require('socket.io')(server);



app.use(compression());
app.use(express.urlencoded());

// Parse JSON bodies (as sent by API clients)
app.use(express.json());

app.get("/", async (req, res) => {
  res.send("API Version ");
});
app.get("/api/deals", async (req, res) => {
  
  let q =  getQueryFromParams(req);
  log(q);
  try {
    let deals = await ozbargain.getDeals(q);
    res
      .status(200)
      .json({
        success: true,
        errorCode: "",
        errorDescription: "",
        deals: deals
      });
  } catch (e) {
    logError('An error occured while retrieving deals',e);
    sendError(res, 100, "An error occurred while retrieving deals");
  }
});

app.get("/api/cleandeals", async (req, res) => {
  
  try {
    let deals = await ozbargain.cleanDeals();
    res
      .status(200)
      .json({
        success: true,
        errorCode: "",
        errorDescription: "",
        deals: deals
      });
  } catch (e) {
    logError('An error occured while cleaning deals',e);
    sendError(res, 100, "An error occurred while cleaning deals");
  }
});
app.get("/api/synclive", async (req, res) => {
  try {
    let deals = await ozbargain.parseLive();

    let dealIds = deals.map(d => {
      return d.dealId;
    });
    res
      .status(200)
      .json({
        success: true,
        errorCode: "",
        errorDescription: "",
        deals: dealIds
      });
  } catch (e) {
    logError(e);
    sendError(res, 100, "An error occurred while syncing live");
  }
});

app.get("/api/syncdeals", async (req, res) => {
  try {
    
    let deals = await ozbargain.parseDeals();
    let dealIds = deals.map(d => {
      return d.dealId;
    });
    res
      .status(200)
      .json({
        success: true,
        errorCode: "",
        errorDescription: "",
        deals: dealIds
      });
  } catch (e) {
    logError(e);
    res.status(500).json({ status: "failed", error: JSON.stringify(e) });
  }
});

app.post("/api/pushdeals", (req, res)=>{

  const message = req.body ? req.body.message : null;
  
  try{
    if (message) {
      const buffer = Buffer.from(message.data, 'base64').toString('utf-8');
      const data = buffer ? buffer.toString() : null;
 
      console.log(`Received message ${message.messageId}:`);

      if(data)
      {
          console.log("sending deals ");
          io.emit("deals", data);
          console.log("done");
      }
      else
      {
        console.error("Invalid data received ");
      }
    }
    else
    {
      console.log(" ******* No Message received *******");
    }
  }
  catch(e)
  {
      console.error("An error occurred ",e);
  }
  res.status(204).send();
});

io.on('connection', (socket)=>{
  var address = socket.handshake.address;
  log('New connection from ' + address);
  
  socket.on('disconnecting',(reason)=>{
    console.log("Disconnecting ", reason);
    socket.emit("Disconnecting ...");
  });

  socket.on('disconnect', (reason)=>{
      console.log('Socket disconnected', reason);
  });

  socket.on('error', (error)=>{
      console.error("An error occurred for socket ", error);
  });

  socket.emit('message', 'Connected successfuly...');
});

io.on('disconnect',()=>{
  log("Disconnecting...");
});


server.listen(PORT, () => {
  log(" Starting api ...");
 
  if(process.env.Local)
    {
    log("Local Run, configuring gcloud credentials");
    putenv(
      "GOOGLE_APPLICATION_CREDENTIALS",
      "OzBargains.json"
    );
    }
});

function sendError(res, code, error) {
  res
    .status(500)
    .json({ success: false, errorCode: code, errorDescription: error });
}


function getQueryFromParams(req)
{
    
  let q = {};

  if (req.query["limit"]) {
    q.limit = parseInt(req.query["limit"]);
  }
  if (req.query["sort"]) {
    q.order = req.query["sort"];
  }
  if (req.query["startRow"]) {
    let val = req.query["startRow"];
    if (val) {
        q.start = val;
      }
    
  }
  if (req.query["endRow"]) {
    let val = req.query["endRow"];
    if (val) {
        q.end = val;
      }
    
  }

  let where = [];
  if (req.query["dateFrom"]) {
    let val = parseInt(req.query["dateFrom"]);
    if (val) {
      where.push(["meta.timestamp", ">=", +val]);
    }
  }

  if (req.query["dateTo"]) {
    let val = parseInt(req.query["dateTo"]);
    if (val) {
      where.push(["meta.timestamp", "<=", +val]);
    }
  }

  if (req.query["dealFrom"]) {
    let val = parseInt(req.query["dealFrom"]);
    if (val) {
      where.push(["dealId", ">=", +val]);
    }
  }

  if (req.query["dealTo"]) {
    let val = parseInt(req.query["dealTo"]);
    if (val) {
      where.push(["dealId", "<=", +val]);
    }
  }

  if (where.length > 0) {
    q.where = where;
  }

  return q;
}