const Firestore = require("@google-cloud/firestore");

const PROJECTID = "ozbargains";
const DEALS_COLLECTION = "deals";
const INVALID_DEALS_COLLECTION = "invaliddeals";

const firestore = new Firestore({
  projectId: PROJECTID,
  timestampsInSnapshots: true
});

async function getDeals(q) {
  return new Promise(function(resolve, reject) {
    try {
      let col = firestore.collection(DEALS_COLLECTION);

      let query = col;

      if (!q) q = {};

      if (q.where) {
        q.where.forEach(w => {
          query = query.where(w[0], w[1], w[2]);
        });
      }

      if (q.order) {
        let orderTokens = q.order.split(",");

        if (orderTokens.length > 1)
          query = query.orderBy(orderTokens[0], orderTokens[1]);
        else query = query.orderBy(orderTokens[0]);
      }

      if (q.start) {
        query = query.startAt(q.start);
      }

      if (q.end) {
        query = query.endAt(q.end);
      }
      if (q.offset) {
        query = query.offset(q.offset);
      }

      if (q.limit) {
        query = query.limit(q.limit);
      }

      query.get().then(qs => {
        let deals = [];
        qs.forEach(d => {
          deals.push(d.data());
        });

        resolve(deals);
      }).catch(error=>{
        reject(error);
      });
    } catch (e) {
      reject(e);
    }
  });
}

async function addDeals(deals) {
  if (!deals || deals.length <= 0) {
    return;
  }

  let invalidDeals = deals.filter((deal)=>{
    return deal.errors != null && deal.errors.length>0;
  });

  let batch = firestore.batch();

  for (let deal of deals) {
    if (deal.dealId) {
      let dealRef = firestore.collection(DEALS_COLLECTION).doc(deal.dealId);
      batch.set(dealRef, deal);
    }
  }

  for(let deal of invalidDeals)
  {
    if(deal.dealId)
    {
      let dealRef =  firestore.collection(INVALID_DEALS_COLLECTION).doc(deal.dealId);
      batch.set(dealRef, deal);
    }
  }
  await batch.commit();
}

async function updateDeals(deals) {
  if (!deals || deals.length <= 0) {
    return;
  }

  let batch = firestore.batch();

  for (let deal of deals) {
    if (deal.dealId) {
      let dealRef = firestore.collection(DEALS_COLLECTION).doc(deal.dealId);
      batch.update(dealRef, deal);
    }
  }

  await batch.commit();
}

async function addDeal(deal) {
  if (!deal.dealId) {
    return;
  }

  if(deal.errors != null && deal.errors.length>=0)
  {
    await firestore
    .collection(INVALID_DEALS_COLLECTION)
    .doc(deal.dealId)
    .set(deal);
    
  }
  else
  {
    await firestore
    .collection(DEALS_COLLECTION)
    .doc(deal.dealId)
    .set(deal);
  }
}

async function updateDeal(deal) {
  if (!deal.dealId) {
    return;
  }

  await firestore
    .collection(DEALS_COLLECTION)
    .doc(deal.dealId)
    .update(deal);
}

async function updateVote(deal) {
  if (!deal.dealId) {
    return;
  }

  await firestore
    .collection(DEALS_COLLECTION)
    .doc(deal.dealId)
    .update({
      vote: deal.vote
    });
}

async function updateComments(deal) {
  if (!deal.dealId) {
    return;
  }

  await firestore
    .collections(DEALS_COLLECTION)
    .doc(deal.dealId)
    .update({
      comments: deal.comments
    });
}

async function deleteDeals() {
  await deleteCollection(firestore, DEALS_COLLECTION, 1000);
}

async function deleteAllDeals() {
  await deleteCollection(firestore, DEALS_COLLECTION, 1000);
  await deleteCollection(firestore, INVALID_DEALS_COLLECTION, 1000);
}

function deleteCollection(db, collectionPath, batchSize) {
  let collectionRef = db.collection(collectionPath);
  let query = collectionRef.orderBy("__name__").limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(db, query, batchSize, resolve, reject);
  });
}

function deleteQueryBatch(db, query, batchSize, resolve, reject) {
  query
    .get()
    .then(snapshot => {
      // When there are no documents left, we are done
      if (snapshot.size === 0) {
        return 0;
      }

      // Delete documents in a batch
      let batch = db.batch();
      snapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      return batch.commit().then(() => {
        return snapshot.size;
      });
    })
    .then(numDeleted => {
      if (numDeleted === 0) {
        resolve();
        return;
      }

      // Recurse on the next process tick, to avoid
      // exploding the stack.
      process.nextTick(() => {
        deleteQueryBatch(db, query, batchSize, resolve, reject);
      });
    })
    .catch(reject);
}

module.exports = {
  getDeals: getDeals,
  addDeal: addDeal,
  addDeals: addDeals,
  updateDeal: updateDeal,
  updateDeals: updateDeals,
  updateVote: updateVote,
  updateComments: updateComments,
  deleteDeals: deleteDeals,
  deleteAllDeals: deleteAllDeals
};
