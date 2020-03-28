/* jshint esversion: 8 */
const xray = require("x-ray");
const cheerio = require("cheerio");
const axios = require("axios");
const moment = require("moment-timezone");

const x = new xray();
const log = console.log;
const logInfo = console.info;
const logError = console.error;

const db = require("./gcp");

const dealUrl = "https://www.ozbargain.com.au";
const liveUrl = dealUrl + "/api/live?last=0";

const Action_VoteUp = "Vote Up";
const Action_VoteDown = "Vote Down";
const Action_Post = "Post";
const liveActions = [Action_Post, Action_VoteUp, Action_VoteDown];
const DateFormat = "DD/MM/YYYY hh:mm";
const TimeZone = 'Australia/Melbourne';

const DateRegex = /\d{1,2}\/\d{1,2}\/\d{4}/;
const TimeRegex = /\d{1,2}\:\d{1,2}/;
const ExpiredRegex = /\d{1,2}[\sa-zA-Z]{1,10}\d{1,2}\:\d{1,2}([a-zA-Z]{2})?/;
const UpcomingRegex = /((\d{1,2}\s[a-zA-Z]{3}(\s\d{1,2}\:\d{1,2})?([a-zA-Z]{2})?)|\d{2})/;

const sleepTime = 200;

moment.tz.setDefault(TimeZone);
x.delay(sleepTime);

async function parseDeals() {
  log("Fetching deals ");
  let deals = await scrapeDeals();
  log("Deals found ", deals.length);

  let dummyDeals = deals;
  let saveDeals = [];
  for (let deal of deals) {
    try {
      let link = deal.link;
      if (link) {
       
        await sleep(sleepTime);
    
        let details = await scrapeDeal(link);
        if (details) {

          saveDeals.push(details);

          // deal.description = details.description;
          // deal.tags = details.tags;
          // if (!deal.dealId) {
          //   deal.dealId = details.dealId;
          // }
          // deal.meta = details.meta;
          // deal.snapshot = details.snapshot;
          // deal.errors = details.errors;
        } 
        // else {
        //   if (!deal.dealId) {
        //     deal.dealId = deal.link.split("/").pop();
        //   }
        //}
      }
    } catch (e) {
      logError(e);
    }
  }

  log("Storing to database ", saveDeals.length);

  if (saveDeals.length > 0 ) {
    
    await db.addDeals(saveDeals);
  }

  log("done...");
  return saveDeals;
}
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
async function parseLive() {
  let deals = [];

  try {
    log("Fetching live deals");
    let liveDeals = await scrapeLive();
    log(" Total live deals found " + liveDeals.length);
    let dealIds = [];
    let uniqueDeals = [];

    for(let liveDeal of liveDeals)
    {
      let dealId = liveDeal.link.split("/").pop();
      liveDeal.dealId = dealId;
      if(dealIds.indexOf(dealId)<0)
      {
        dealIds.push(dealId);
        uniqueDeals.push(liveDeal);
      }
    }
    log("After removing duplicates ", dealIds, dealIds.length);
    for (let liveDeal of uniqueDeals) {
      try {
        

        if (liveDeal.dealId) {

      
          let url = dealUrl + liveDeal.link;
         
          await sleep(sleepTime);
         
          let deal = await scrapeDeal(url);
          if (deal && deal.description) {
            deals.push(deal);
          }
        }
      } catch (e) {
        logError("An error occurred while adding/updating live deal ", e);
      }
      //log(liveDeal);
    }

    log("Storing live deals ",deals.length);
    await db.addDeals(deals);
    log("Done...");
  } catch (e) {
    logError("An error occurred while storing live deals", e);
  }

  return deals;
}

async function scrapeLive() {
  let deals = [];
  try {
    let liveDeals = await axios.get(liveUrl);
    if (liveDeals.data) {
      let records = liveDeals.data.records;
      if (records) {
        deals = records.filter(function(record) {
          if (liveActions.indexOf(record.action) >= 0) {
            return record;
          }
        });
      }
    }
  } catch (e) {
    logError(e);
  }
  return deals;
}

async function cleanDeals()
{
        try{
            await db.deleteDeals();
        }
        catch(e)
        {
          logError("An error occurred while cleaning deals ",e);
        }
}
function scrapeDeal(dealLink) {
  return new Promise(function(resolve, reject) {
    try {
      log("fetching " + dealLink);
      x(dealLink, ".main", {
        title: "h1#title@data-title",
        meta: {
          submitted: "div.submitted",
          image: "img.gravatar@src",
          labels: ["div.messages ul li"],
          freebie:"span.nodefreebie@text",
          expired: ".links span.expired",
          upcoming:".links span.inactive"
        },
        description: "div.content@html",
        vote: {
          up: "span.voteup",
          down: "span.votedown"
        },

        snapshot: {
          link: ".foxshot-container a@href",
          title: ".foxshot-container a@title",
          image: ".foxshot-container img@src"
        },
        category: "ul.links span.tag a",
        tags: [".taxonomy span"]
      })
        .then(function(deal) {
          let errors = [];
          deal.link = dealLink;
          deal.dealId = dealLink.split("/").pop();
          let content = parseDescription(deal.description);
          if (!content || content.length < 2) {
            errors.push("Failed to parse content from description");
          }
          deal.content = content;
          deal.meta = parseMeta(deal.meta);
          
          if(deal.vote)
          {
            if(!deal.vote.up)
            {
              deal.vote.up = "0";
            }
            if(!deal.vote.down)
            {
              deal.vote.down = "0";
            }
          }
          let meta = deal.meta;
          if (!meta.author || meta.author.length < 2) {
            errors.push("Failed to parse author from " + meta.submitted);
          }
          if (!meta.date || meta.date.length < 16 || meta.date.length > 20) {
            errors.push("Failed to parse date from " + meta.submitted);
          }
          if (!meta.timestamp || meta.timestamp.length < 8) {
            errors.push("Failed to parse timestamp from " + meta.submitted);
          }

          deal.snapshot = parseSnapshot(deal.snapshot);
          let snapshot = deal.snapshot;
          if (!snapshot.goto || snapshot.goto.length < 5) {
            errors.push("Failed to parse snapshot from " + snapshot.title);
          }

          deal.errors = errors;
          resolve(deal);
        })
        .catch(function(e) {
          reject(e);
        });
    } catch (e) {
      reject(e);
    }
  });
}

function parseDescription(description) {
  let html = "";
  try {
    if(!description)
    {
      return html;
    }
    let $ = cheerio.load(description);
    let childs = $("body").children();

    let truncateLen = 165;
    let htmlLen = 0;
    if (childs.length > 0) {
      let child1 = $(childs[0]);
      let child1Text = child1.text();

      if (child1Text.length > truncateLen) {
        child1.text(child1Text.substring(1, truncateLen) + " ...");
      }

      htmlLen = child1.text().length;

      html += $.html(childs[0]) + "\n";
    }
    if (htmlLen < truncateLen && childs.length > 1) {
      let child2 = $(childs[1]);
      let child2Text = child2.text();
      let diffLen = truncateLen - htmlLen;
      if (child2Text.length > diffLen) {
        child2.text(child2Text.substring(1, diffLen));
      }

      child2.text(child2.text() + "...");
      html += $.html(childs[1]) + "\n";
    }
  } catch (e) {
    logError("An error occurred while parsing description ", e, description);
  }
  return html;
}
function parseMeta(meta) {
  let author, submitDate, timestamp, expiredDate, upcomingDate;
  if (meta.submitted) {
    author = meta.submitted.split(" on ")[0];

    let dateMatch = meta.submitted.match(DateRegex);
    if (dateMatch.length > 0) {
      submitDate = dateMatch[0];
      let timeMatch = meta.submitted.match(TimeRegex);
      if (timeMatch.length > 0) {
        submitDate += " ";
        submitDate += timeMatch[0];
      }
    }

    
    if (submitDate && submitDate.length > 0) {
      timestamp = moment(submitDate, DateFormat).unix();
   
    }

    let expired = meta.expired;
    if(expired)
    {
      let expiredMatch = expired.match(ExpiredRegex);
      if(expiredMatch.length>0)
      {
        
         expiredDate = moment(expiredMatch[0],"DD MMM HH:mmA").unix();
      }
    }

    if(meta.upcoming)
    {

      let upcomingDates = parseUpcomingDates(meta.upcoming);
       upcomingDate = upcomingDates.upcoming;
       if(upcomingDates.expiry)
       {
         expiredDate = upcomingDates.expiry;
       }
    }

     if(meta.freebie)
     {
       meta.freebie = meta.freebie.trim();
     }
     else
     {
       meta.freebie = '';
     }

     if(!meta.labels)
     {
        meta.labels = [];
     }
  }

  meta.author = author || "";
  meta.date = submitDate || "";
  meta.timestamp = timestamp || 0;
  meta.expiredDate = expiredDate || 0;
  meta.upcomingDate = upcomingDate || 0;

  return meta;
}

function parseUpcomingDates(upcoming)
  {
    let dates = {
      upcoming: 0,
      expiry: 0
    };
    console.log('Parsing upcoming ', upcoming);
    let upcomingDate, expiryDate;
    let upcomings = upcoming.split("–");
    if(upcomings.length>0)
    {
        let upcomingText = upcomings[0];
        let upcomingMatch = upcomingText.match(UpcomingRegex);
        if(upcomingMatch && upcomingMatch.length>0)
        {
            upcomingDate = upcomingMatch[0];
        }
        if(upcomings.length>1)
        {
            let expiryText = upcomings[1];  
            let expiryMatch = expiryText.match(UpcomingRegex);
            if(expiryMatch && expiryMatch.length>0)
            {
              expiryDate = expiryMatch[0];
            }
        }

        let exp;
        if(expiryDate)
        {
            exp = moment(expiryDate, 'DD MMM hh:mmA');
            console.log('Expiry ',exp);
            dates.expiry = exp.unix();
        }
        let upcom;
        if(upcomingDate)
        {
            upcom = moment(upcomingDate, 'DD MMM hh:mmA');
          if(upcomingDate.replace(" ","").length==2)
            {
              if(exp)
              {
                console.log("******* ", exp.get('M'));
                upcom.set({month: exp.get('M')});
              }
            }
            dates.upcoming = upcom.unix();
        }
    }

    return dates;
  }
function parseSnapshot(snapshot) {
  let goto = "";

  if (snapshot.title) {
    goto = snapshot.title.replace("Go to ", "");
  }

  snapshot.goto = goto;
  return snapshot;
}
function scrapeDeals(lastDeal) {
  return new Promise(function(resolve, reject) {
    x(dealUrl, ".node-ozbdeal", [
      {
        title: "h2.title@data-title",
        link: "h2.title a@href",
        meta: {
          submitted: "div.submitted",
          image: "img.gravatar@src"
        },
        content: "div.content@html",
        vote: {
          up: "span.voteup",
          down: "span.votedown"
        },
        gravatar: "img.gravatar@src",

        snapshot: {
          link: ".foxshot-container a@href",
          title: ".foxshot-container a@title",
          image: ".foxshot-container img@src"
        },
        category: "ul.links span.tag a"
      }
    ])
      .paginate("a.pager-next@href")
      .then(function(data) {
        resolve(data);
      })
      .catch(function(e) {
        reject(e);
      });
  });
}


async function getDeals(query)
{
    let deals = await db.getDeals(query);
    return deals;
}


async function downloadImage(imageUrl) {
  let base64 = "";
  try {
    let image = await axios.get(imageUrl, { responseType: "arraybuffer" });
    base64 = Buffer.from(image.data).toString("base64");
  } catch (e) {
    logError(e);
  }
  return base64;
}

module.exports = {
  getDeals: getDeals,
  parseDeals: parseDeals,
  scrapeDeals: scrapeDeals,
  scrapeDeal: scrapeDeal,
  cleanDeals: cleanDeals,
  downloadImage: downloadImage,
  scrapeLive: scrapeLive,
  parseLive: parseLive
};
