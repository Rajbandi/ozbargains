const db = require('./gcp');
const putenv = require('putenv');

(async ()=>{
    putenv("GOOGLE_APPLICATION_CREDENTIALS","OzBargains.json")
    db.deleteDeals();
})();