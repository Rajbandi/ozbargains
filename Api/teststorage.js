/* jshint esversion:8 */
const putenv = require("putenv");
const storage = require("./gcp-storage");
const Buffer = require('buffer');
const log = console.log;
(async function(){


    if(process.env.Local)
    {
    log("Local Run, configuring gcloud credentials");
    putenv(
      "GOOGLE_APPLICATION_CREDENTIALS",
      "OzBargains.json"
    );
    }

    var file = await storage.downloadFile({
        bucket: "ozbargainau.appspot.com",
        fileName: "app/version.json"
    });

    log(file.toString('utf-8'));
})();