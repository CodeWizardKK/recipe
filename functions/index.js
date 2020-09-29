const functions = require('firebase-functions');

 // Create and Deploy Your First Cloud Functions
 // https://firebase.google.com/docs/functions/write-firebase-functions

 exports.version = functions.https.onRequest((req, res) => {

   var val =
   {
     "s":2.2,
     "q":1.8
   }

   functions.logger.info("get version!!!!", {structuredData: true});
//   res.status(200).send('foo.json');
   res.status(200).send(JSON.stringify(val));
 });

 exports.seasoning = functions.https.onRequest((req, res) => {

   var val =
    {
      "seasonings":[
        {
          "id":1,
          "name":"砂糖"
        },
        {
          "id":2,
          "name":"塩"
        },
        {
          "id":3,
          "name":"酢"
        },
        {
          "id":4,
          "name":"醤油"
        },
        {
          "id":5,
          "name":"味噌"
        },
        {
          "id":6,
          "name":"酒"
        },
        {
          "id":7,
          "name":"みりん"
        },
        {
          "id":8,
          "name":"油"
        },
        {
          "id":9,
          "name":"バター"
        }
      ]
    }
   functions.logger.info("get seasoning!!!!", {structuredData: true});
//   res.status(200).send('foo.json');
   res.status(200).send(JSON.stringify(val));
 });

 exports.quantityunit = functions.https.onRequest((req, res) => {

    var val =
    {
      "quantityunits":[
        {
          "id":1,
          "name":"g"
        },
        {
          "id":2,
          "name":"ml"
        },
        {
          "id":3,
          "name":"cc"
        },
        {
          "id":4,
          "name":"個"
        },
        {
          "id":5,
          "name":"大さじ"
        },
        {
          "id":6,
          "name":"小さじ"
        },
        {
          "id":7,
          "name":"少々"
        },
        {
          "id":8,
          "name":"適量"
        }
      ]
    }

   functions.logger.info("get quantityunit!!!!", {structuredData: true});
   res.status(200).send(JSON.stringify(val));
 });
