const fs = require('fs');
const YAML = require('js-yaml');
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

var GeoFirestore = require('geofirestore').GeoFirestore;


const fileName = process.argv[2];

const reDate = new RegExp(/^date/);
const reGeo = new RegExp(/^geo/);

let dateArray = process.argv.filter(item => item.match(reDate))[0];
let geoArray = process.argv.filter(item => item.match(reGeo))[0];

if (dateArray) {
  dateArray = dateArray.split('=')[1].split(',');
}

if (geoArray) {
  geoArray = geoArray.split('=')[1].split(',');
}

// You should replace databaseURL with your own
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "DATABASE_URL"
});

const db = admin.firestore();

const geofirestore = new GeoFirestore(db);

db.settings({ timestampsInSnapshots: true });

fs.readFile(fileName, 'utf8', function(err, data){
  if(err){
    return console.log(err);
  }

  // Turn string from file to an Array
  if (fileName.endsWith('yaml') || fileName.endsWith('yml')) {
    dataArray = YAML.safeLoad(data);
  } else {
    dataArray = JSON.parse(data);
  }

  updateCollection(dataArray);

})

async function updateCollection(dataArray){
  for(const index in dataArray){
    const collectionName = index;
    for(const doc in dataArray[index]){
      if(dataArray[index].hasOwnProperty(doc)){
        await startUpdating(collectionName, doc, dataArray[index][doc]);
      }
    }
  }
}

function startUpdating(collectionName, doc, data){
  // convert date from unixtimestamp  
  let parameterValid = true;

  if (data.hasOwnProperty('date') && typeof data.date === 'object' && data.date != null){
    data['date'] = new admin.firestore.Timestamp(data['date']._seconds, data['date']._nanoseconds)
  }
  
  if (data.hasOwnProperty('createdAt') && typeof data.createdAt === 'object' && data.createdAt != null) {
    data['createdAt'] = new admin.firestore.Timestamp(data['createdAt']._seconds, data['createdAt']._nanoseconds)
  }
  
  if (data.hasOwnProperty('expiresAt') && typeof data.expiresAt === 'object' && data.expiresAt != null) {
    data['expiresAt'] = new admin.firestore.Timestamp(data['expiresAt']._seconds, data['expiresAt']._nanoseconds)
  }
  
  if (data.hasOwnProperty('lastOnlineTimestamp') && typeof data.lastOnlineTimestamp === 'object' && data.lastOnlineTimestamp != null) {
    data['lastOnlineTimestamp'] = new admin.firestore.Timestamp(data['lastOnlineTimestamp']._seconds, data['lastOnlineTimestamp']._nanoseconds)
  }

  if(collectionName == "booked_table"){
      if(data.hasOwnProperty('author') && data.author.hasOwnProperty('lastOnlineTimestamp') && typeof data.author.lastOnlineTimestamp === 'object' && data.author.lastOnlineTimestamp != null){
      data.author['lastOnlineTimestamp'] = new admin.firestore.Timestamp(data.author['lastOnlineTimestamp']._seconds, data.author['lastOnlineTimestamp']._nanoseconds)
    }
      if(data.hasOwnProperty('vendor') && data.vendor.hasOwnProperty('createdAt') && typeof data.vendor.createdAt === 'object' && data.vendor.createdAt != null) {
      data.vendor['createdAt'] = new admin.firestore.Timestamp(data.vendor['createdAt']._seconds, data.vendor['createdAt']._nanoseconds)
    }	
  }
  
  if(collectionName == "driver_payouts" || collectionName == "payouts"){
    if (data.hasOwnProperty('paidDate') && typeof data.paidDate === 'object' && data.paidDate != null) {
      data['paidDate'] = new admin.firestore.Timestamp(data['paidDate']._seconds, data['paidDate']._nanoseconds)
    }
  }

  if(collectionName == "restaurant_orders"){
      if(data.hasOwnProperty('author') && data.author.hasOwnProperty('lastOnlineTimestamp') && typeof data.author.lastOnlineTimestamp === 'object' && data.author.lastOnlineTimestamp != null){
          data.author['lastOnlineTimestamp'] = new admin.firestore.Timestamp(data.author['lastOnlineTimestamp']._seconds, data.author['lastOnlineTimestamp']._nanoseconds)
    }
    if(data.hasOwnProperty('vendor') && data.vendor.hasOwnProperty('createdAt') && typeof data.vendor.createdAt === 'object' && data.vendor.createdAt != null) {
        data.vendor['createdAt'] = new admin.firestore.Timestamp(data.vendor['createdAt']._seconds, data.vendor['createdAt']._nanoseconds)
    }		
  }

  // Enter date value
  if(typeof dateArray !== 'undefined') {        
    dateArray.map(date => {      
      if (data.hasOwnProperty(date)) {
        data[date] = new Date(data[date]._seconds * 1000);
      } else {
        console.log('Please check your date parameters!!!', dateArray);
        parameterValid = false;
      }     
    });    
  }

  // Enter geo value
  if(typeof geoArray !== 'undefined') {
    geoArray.map(geo => {
      if(data.hasOwnProperty(geo)) {        
        data[geo] = new admin.firestore.GeoPoint(data[geo]._latitude, data[geo]._longitude);        
      } else {
        console.log('Please check your geo parameters!!!', geoArray);
        parameterValid = false;
      }
    })
  }
  
  if(parameterValid) {
    return new Promise(resolve => {
      db.collection(collectionName).doc(doc)
      .set(data)
      .then(() => {
        console.log(`${doc} is imported successfully to firestore!`);
        resolve('Data wrote!');
        if(collectionName=='vendors'){

            if(data.g.geopoint._longitude && data.g.geopoint._latitude){

              coordinates=new admin.firestore.GeoPoint(data.g.geopoint._latitude,data.g.geopoint._longitude);

              try{
                    geofirestore.collection('vendors').doc(doc).update({'coordinates':coordinates}).then(() => {

                        console.log('Provided document has been updated in Firestore');

                      }, (error) => {

                        console.log('Error: ' + error);

                      });
                    }catch(err) {

                    }

            }

        }
      })
      .catch(error => {
        console.log(error);
      });
    });
  } else {
    console.log(`${doc} is not imported to firestore. Please check your parameters!`);    
  }
}
