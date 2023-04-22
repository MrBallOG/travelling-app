const {functions, db, bucket} = require("./firebaseExports");
const {Timestamp} = require("firebase-admin/firestore");
const express = require("express");
const cors = require("cors");
const {authorization} = require("./authorizationMiddleware");
const {fileUpload} = require("./fileUploadMiddleware");
const {fileOperations} = require("./fileOperationsMiddleware");
const {errorResponse} = require("./errorResponseMiddleware");

const app = express();

app.use(cors());

app.use(authorization);

// authorization bearer token => req.headers.authorization
app.post("/photo", fileUpload, fileOperations, async (req, res, next) => {
  const uid = req.uid;
  const metadata = {
    metadata: {
      uid: uid,
    },
  };
  const file = bucket.file(req.file.filename);
  await file.save(req.file.buffer);
  await file.setMetadata(metadata);
  functions.logger.info("STORAGE: Photo saved", req.file.filename);

  const tempPhoto = {
    uid: uid,
    file: req.file.filename,
    longitude: req.body.longitude,
    latitude: req.body.latitude,
  };
  await db.collection("tempPhotos").add(tempPhoto);
  functions.logger.info("FIRESTORE: TempPhoto created", req.file.filename);

  res.sendStatus(200);
});

app.use(errorResponse);

exports.api = functions.https.onRequest(app);

// const warsaw = {
//   continent: "Europe",
//   country: "Poland",
//   administrationArea: "Mazowicekie",
//   city: "Warsaw",
// };

// const badge = {
//   continent: "Europe",
//   country: "Poland",
//   administrationArea: "Mazowicekie",
//   requirements: { // {places: [warsaw, płock]}
//     count: 10,
//     distinctArea: false,
//   },
// };

// https://ajv.js.org/json-schema.html#keywords-for-numbers, https://express-validator.github.io/docs/custom-error-messages -> validation
// firebase functions:shell => createUser({uid: "some uid"})

exports.createUser = functions.auth.user().onCreate(async (user) => {
  const newUser = {
    uid: user.uid,
    badges: [],
    dailyPhotoCount: 0,
    photoUploadTime: Timestamp.now(),
    messagingTokens: [],
  };
  await db.collection("users").add(newUser);
  functions.logger.info("FIRESTORE: User created", newUser);
});
