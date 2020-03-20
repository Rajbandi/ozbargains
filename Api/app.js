const express = require('express');
const ozbargain = require("../Scraper/ozbargain");
const putenv = require("putenv");
const app = express()
const PORT = 80;
const moment = require('moment');
const log = console.log;
const logError = console.error;

app.get("/", async (req, res)=>{

    res.send("API Version ");

});
app.get("/api/deals", async (req, res)=>{

    
    putenv("GOOGLE_APPLICATION_CREDENTIALS","C:\\projects\\scraper\\ozbargain\\OzBargains.json")

    
    try{
    let deals = await ozbargain.getDeals();
    res.status(200).json({success: true, errorCode:"", errorDescription:"", deals:deals});
    }
    catch(e)
    {
        logError(e);
        sendError(res, 100, 'An error occurred while retrieving deals');
    }

});

app.get("/api/synclive", async (req, res)=>{
    try{
        putenv("GOOGLE_APPLICATION_CREDENTIALS","C:\\projects\\scraper\\ozbargain\\OzBargains.json")
        let deals = await ozbargain.parseLive();

        let dealIds = deals.map((d)=> {return d.dealId;});
        res.status(200).json({success: true, errorCode:"", errorDescription:"", deals:dealIds});
    }
    catch(e)
    {
        logError(e);
        sendError(res, 100, 'An error occurred while syncing live');
    }

});

app.get("/api/syncdeals", async (req, res)=>{

    try{
        putenv("GOOGLE_APPLICATION_CREDENTIALS","C:\\projects\\scraper\\ozbargain\\OzBargains.json")
        let deals = await ozbargain.parseDeals();
        let dealIds = deals.map((d)=> {return d.dealId;});
        res.status(200).json({success: true, errorCode:"", errorDescription:"", deals:dealIds});
    }
    catch(e)
    {
        logError(e);
        res.status(500).json({status: "failed", error: JSON.stringify(e)});
    }
});


app.listen(PORT, ()=>{
    log(" Starting api ...");
})


function sendError(res, code, error)
{
    res.status(500).json({success: false, errorCode:code, errorDescription:  error});
}