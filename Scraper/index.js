const putenv = require("putenv");
const ozbargain = require("./ozbargain");

// (async () => {

//   putenv("GOOGLE_APPLICATION_CREDENTIALS","C:\\projects\\scraper\\ozbargain\\OzBargains.json")
//   //await ozbargain.parseDeals();
//   await ozbargain.parseLive();
//   //  let deal = await ozbargain.scrapeDeal("https://www.ozbargain.com.au/node/525477");
//   //  console.log(deal);


//   // let s = "Bad Company on 19/03/2020   -    09:01  jaycar.com.au (103 clicks)";

//   // let regex = /\d{1,2}\/\d{1,2}\/\d{4}/;
//   // let regex1 = /\d{1,2}\:\d{1,2}/;
//   // let match = s.match(regex)[0];
//   // let match1 = s.match(regex1)[0];
//   // console.log(match);
//   // console.log(match1);
// })();

exports.syncDeals = async () => {
  await ozbargain.parseDeals();
}

exports.syncLive = async () => {
  await ozbargain.parseLive();
}