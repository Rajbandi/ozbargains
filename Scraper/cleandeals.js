const db = require('./gcp');
const putenv = require('putenv');

(async ()=>{
    putenv("GOOGLE_APPLICATION_CREDENTIALS","C:\\projects\\scraper\\ozbargain\\OzBargains.json")
    db.deleteDeals();
})();