/* jshint esversion:8 */

const express = require("express");
const ozbargain = require("./ozbargain");
const putenv = require("putenv");
const app = express();
const PORT = process.env.PORT || 80;
const moment = require("moment");
const log = console.log;
const logError = console.error;

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

app.listen(PORT, () => {
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