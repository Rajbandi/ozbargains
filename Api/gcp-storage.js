/* jshint esversion:8 */

const { Storage } = require("@google-cloud/storage");

const storage = new Storage();

const log = console.log;
const PROJECTID = "ozbargainau";
async function downloadFile(options) {
  return new Promise(function (resolve, reject) {
    try {
      var checkOptions = validateFileOptions(options);
      if (!checkOptions.valid) {
        reject(checkOptions.error);
        return;
      }

      storage
        .bucket(options.bucket)
        .file(options.fileName)
        .download(function (err, contents) {
          if (err) {
            reject(err);
            return;
          }

          resolve(contents);
        });
    } catch (e) {
      reject(e);
    }
  });
}

function validateFileOptions(options) {
  var err = "";
  if (!options.bucket) {
    err = "Bucket name is required";
  } else if (!options.fileName) {
    err = "File name is required";
  }
  return {
    valid: !err || err.length == 0,
    error: err,
  };
}

async function uploadFile(options) {
  return new Promise(function (resolve, reject) {
    try {
      var checkOptions = validateFileOptions(options);
      if (!checkOptions.valid || (options.contents||"").length==0) {
        reject(checkOptions.error);
        return;
      }

      storage
        .bucket(options.bucket)
        .file(options.fileName)
        .save(options.contents, function (err) {
          if (err) {
            reject(err);
            return;
          }

          resolve();
        });
    } catch (e) {
      reject(e);
    }
  });


}



async function deleteFile(options) {
    return new Promise(function (resolve, reject) {
      try {
        var checkOptions = validateFileOptions(options);
        if (!checkOptions.valid) {
          reject(checkOptions.error);
          return;
        }
  
        storage
          .bucket(options.bucket)
          .file(options.fileName)
          .delete(function (err, response) {
            if (err) {
              reject(err);
              return;
            }
  
            resolve();
          });
      } catch (e) {
        reject(e);
      }
    });
}


async function createBucket(options) {
    return new Promise(function (resolve, reject) {
      try {

        var err = "";
        if(!options.bucket)
        {
            err = "Bucket name is required";
            
        }
        if(err && err.length>0)
        {
            reject(err);
            return;
        }

        
        storage
          .bucket(options.bucket)
          .create(function (err, bucket, response) {
            if (err) {
              reject(err);
              return;
            }
  
            resolve(bucket);
          });
      } catch (e) {
        reject(e);
      }
    });
}


async function getBucket(options) {
    return new Promise(function (resolve, reject) {
      try {

        var err = "";
        if(!options.bucket)
        {
            err = "Bucket name is required";
            
        }
        if(err && err.length>0)
        {
            reject(err);
            return;
        }

        
        storage
          .bucket(options.bucket)
          .get({
              autoCreate: true,
              userProject: PROJECTID
          },function (err, bucket, response) {
            if (err) {
              reject(err);
              return;
            }
  
            resolve(bucket);
          });
      } catch (e) {
        reject(e);
      }
    });
}
async function bucketExists(options) {
    return new Promise(function (resolve, reject) {
      try {

        var err = "";
        if(!options.bucket)
        {
            err = "Bucket name is required";
            
        }
        if(err && err.length>0)
        {
            reject(err);
            return;
        }

        
        storage
          .bucket(options.bucket)
          .exists(function (err, exists) {
            if (err) {
              reject(err);
              return;
            }
  
            resolve(exists);
          });
      } catch (e) {
        reject(e);
      }
    });
}







module.exports = {
    downloadFile: downloadFile,
    uploadFile: uploadFile,
    deleteFile: deleteFile,
    createBucket: createBucket,
    bucketExists: bucketExists
  };
  