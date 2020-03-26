/*jshint esversion: 8 */

const putenv = require("putenv");
const ozbargain = require("./ozbargain");
const moment = require('moment-timezone');

exports.syncDeals = async (req, res) => {
  await ozbargain.parseDeals();
  res.status(200).end();
  console.log("Function finished");
};

exports.syncLive = async (req, res) => {
  await ozbargain.parseLive();
  res.status(200).end();
  console.log("Function finished");
};

exports.cleanDeals = async(req, res)=>{
  await ozbargain.cleanDeals();
  res.status(200).end();
};