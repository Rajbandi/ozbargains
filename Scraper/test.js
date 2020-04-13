/* jshint esversion: 8 */
const putenv = require("putenv");
    const ozbargain = require("./ozbargain");
    const moment = require('moment-timezone');

(async()=>{
    putenv(
        "GOOGLE_APPLICATION_CREDENTIALS",
        "OzBargains.json"
      );

    // //let url = "https://www.ozbargain.com.au/node/524178";
    // let url="https://www.ozbargain.com.au/node/527817";
    // let deal = await ozbargain.scrapeDeal(url);

    // console.log(deal);

     ozbargain.parseLive();

    // await ozbargain.publishDeals([deal]);
})();

// (async () => {
//   let format = "DD/MM/YYYY hh:mm";
//   let dt = "26/03/2020 15:23";
//   const TimeZone = 'Australia/Melbourne';
//   const TimeZone1 = 'Australia/Perth';
//   moment.tz.setDefault(TimeZone);
//   let m = moment(dt, format).unix();
  
//   let m1 = moment(dt, format).unix();

//   console.log(m, m1);

// })();

//   let expired=" 24 Mar 9:01am ";
//   let upcoming=" From 4 Apr In 11 days ";
//   let upcoming1="28 Mar 4:00am–31 Mar 4:00am  In 4 days";
//   let upcoming2=" 26–29 Mar In 2 days ";

//   let regex = /\d{1,2}[\sa-zA-Z]{1,10}\d{1,2}\:\d{1,2}([a-zA-Z]{2})?/;
//   let regex1= /(\d{1,2}|(\d{1,2}[\sa-zA-Z]{1,5}(\d{1,2}\:\d{1,2}([a-zA-Z]{2})))?)(\–\d{1,2}[\sa-zA-Z]{1,5}(\d{1,2}\:\d{1,2}([a-zA-Z]{2}))?)?/;

//   let regex2 = /((\d{1,2}\s[a-zA-Z]{3}(\s\d{1,2}\:\d{1,2})?([a-zA-Z]{2})?)|\d{2})/;

//   // let match = expired.match(regex);
//   // if(match)
//   // {
//   //   console.log(moment(match[0], "DD MMM HH:mmA").unix());
//   // }
//   // console.log(match[0]);

//   // let match1=upcoming.match(regex1);
//   // console.log(match1);

//   // //console.log(moment(match1[0],"DD MMM HH:mmA"));

//   // let match2=upcoming1.match(regex1);
//   // console.log(match2);

//   // let match3=upcoming2.match(regex1);
//   // console.log(match3);

  
//   //console.log(moment(match2[0],"DD MMM HH:mmA"));

//   // putenv("GOOGLE_APPLICATION_CREDENTIALS","C:\\projects\\scraper\\ozbargain\\OzBargains.json")
//   // //await ozbargain.parseDeals();
//   // //await ozbargain.parseLive();

//   // let links = ["https://www.ozbargain.com.au/node/526272","https://www.ozbargain.com.au/node/526229"];
    
//   // //  "https://www.ozbargain.com.au/node/526145"];
  
//   // //,"https://www.ozbargain.com.au/node/526229","https://www.ozbargain.com.au/node/526272"]

//   // links.forEach(async (link)=>{
//   //   let deal = await ozbargain.scrapeDeal(link);
//   //   console.log(deal);
//   //   console.log('--------------------------------');
//   // });

//   let dates = parseUpcoming(upcoming2);
//   console.log(" Dates2 ", dates);
//   console.log('-------------------------');

//   dates = parseUpcoming(upcoming1);
//   console.log(" Dates1 ", dates);
//   console.log('-------------------------');

//   dates = parseUpcoming(upcoming);
//   console.log(" Dates0 ", dates);
//   console.log('-------------------------');
//   function parseUpcomingDates(upcoming)
//   {
//     let dates = {
//       upcoming: 0,
//       expiry: 0
//     };
//     console.log('Parsing upcoming ', upcoming);
//     let upcomingDate, expiryDate;
//     let upcomings = upcoming.split("–");
//     if(upcomings.length>0)
//     {
//         let upcomingText = upcomings[0];
//         let upcomingMatch = upcomingText.match(regex2);
//         if(upcomingMatch && upcomingMatch.length>0)
//         {
//             upcomingDate = upcomingMatch[0];
//         }
//         if(upcomings.length>1)
//         {
//             let expiryText = upcomings[1];  
//             let expiryMatch = expiryText.match(regex2);
//             if(expiryMatch && expiryMatch.length>0)
//             {
//               expiryDate = expiryMatch[0];
//             }
//         }

//         let exp;
//         if(expiryDate)
//         {
//             exp = moment(expiryDate, 'DD MMM hh:mmA');
//             console.log('Expiry ',exp);
//             dates.expiry = exp.unix();
//         }
//         let upcom;
//         if(upcomingDate)
//         {
//             upcom = moment(upcomingDate, 'DD MMM hh:mmA');
//           if(upcomingDate.replace(" ","").length==2)
//             {
//               if(exp)
//               {
//                 console.log("******* ", exp.get('M'));
//                 upcom.set({month: exp.get('M')});
//               }
//             }
//             dates.upcoming = upcom.unix();
//         }
//     }

//     return dates;
//   }


//   // let s = "Bad Company on 19/03/2020   -    09:01  jaycar.com.au (103 clicks)";

//   // let regex = /\d{1,2}\/\d{1,2}\/\d{4}/;
//   // let regex1 = /\d{1,2}\:\d{1,2}/;
//   // let match = s.match(regex)[0];
//   // let match1 = s.match(regex1)[0];
//   // console.log(match);
//   // console.log(match1);
// })();
