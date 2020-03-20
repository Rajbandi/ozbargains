const Firestore = require('@google-cloud/firestore');

const PROJECTID = 'ozbargains';
const COLLECTION_NAME = 'deals';


const firestore = new Firestore({
    projectId: PROJECTID,
    timestampsInSnapshots: true,
  });

async function getDeals(q)
{
  return new Promise(function(resolve, reject){

    try{
      let col = firestore.collection(COLLECTION_NAME);

      let query = col;

      if(!q)
        q={};
      if(q.offset)
      {
        query = query.offset(q.offset);
      }
      if(q.order)
      {
        query = query.orderBy(q.order);
      }
      if(q.limit)
      {
        query = query.limit(q.limit);
      }
      
      if(q.where)
      {
        query = query.where(q.where);
      }
   
      query.get().then(qs=>{

        let deals = [];
        qs.forEach(d=>{
          deals.push(d.data());
        });

        resolve(deals);
      });
   
      
    }
    catch(e)
    {
      reject(e);
    }
  });
   
}

async function addDeals(deals)
{
    if(!deals || deals.length<=0)
    {
        return;
    }

    let batch = firestore.batch();

    for(let deal of deals)
    {
        if(deal.dealId)
        {
            let dealRef = firestore.collection(COLLECTION_NAME).doc(deal.dealId)
            batch.set(dealRef, deal);
        }
    }

    await batch.commit();
}

async function updateDeals(deals)
{
    if(!deals || deals.length<=0)
    {
        return;
    }

    let batch = firestore.batch();

    for(let deal of deals)
    {
        if(deal.dealId)
        {
            let dealRef = firestore.collection(COLLECTION_NAME).doc(deal.dealId)
            batch.update(dealRef, deal);
        }
    }

    await batch.commit();
}

async function addDeal(deal)
{
    if(!deal.dealId)
    {
        return;
    }

    await firestore.collection(COLLECTION_NAME).doc(deal.dealId).set(deal);
}

async function updateDeal(deal)
{
    if(!deal.dealId)
    {
        return;
    }

    await firestore.collection(COLLECTION_NAME).doc(deal.dealId).update(deal);
}

async function updateVote(deal)
{
    if(!deal.dealId)
    {
        return;
    }

    await firestore.collection(COLLECTION_NAME).doc(deal.dealId).update({
        vote: deal.vote
    })
}

async function updateComments(deal)
{
    if(!deal.dealId)
    {
        return;
    }

    await firestore.collections(COLLECTION_NAME).doc(deal.dealId).update({
        comments: deal.comments
    })
}

async function deleteDeals()
{
    await deleteCollection(firestore, COLLECTION_NAME, 1000);
}

function deleteCollection(db, collectionPath, batchSize) {
    let collectionRef = db.collection(collectionPath);
    let query = collectionRef.orderBy('__name__').limit(batchSize);
  
    return new Promise((resolve, reject) => {
      deleteQueryBatch(db, query, batchSize, resolve, reject);
    });
  }
  
  function deleteQueryBatch(db, query, batchSize, resolve, reject) {
    query.get()
      .then((snapshot) => {
        // When there are no documents left, we are done
        if (snapshot.size === 0) {
          return 0;
        }
  
        // Delete documents in a batch
        let batch = db.batch();
        snapshot.docs.forEach((doc) => {
          batch.delete(doc.ref);
        });
  
        return batch.commit().then(() => {
          return snapshot.size;
        });
      }).then((numDeleted) => {
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
  

module.exports={
    getDeals: getDeals,
    addDeal:addDeal,
    addDeals:addDeals,
    updateDeal:updateDeal,
    updateDeals:updateDeals,
    updateVote: updateVote,
    updateComments: updateComments,
    deleteDeals: deleteDeals
}