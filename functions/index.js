const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {Timestamp} = require("firebase-admin/firestore");
const express = require("express");
const cors = require("cors");
const {filesUpload} = require("./fileUploadMiddleware");
// const formidable = require("formidable");
const fs = require("fs");
const path = require("path");

admin.initializeApp();

const db = admin.firestore();
const app = express();

app.use(cors());

// const formOptions = {
//   allowEmptyFiles: false,
//   maxFileSize: 5 * 1024 * 1024,
//   multiples: false,
//   uploadDir: __dirname,
// };

// api.get("/h")
app.get("/h", (req, res) => res.send("hello there"));

// authorization bearer token => req.headers.authorization
app.post("/photo", filesUpload, (req, res, next) => {
  functions.logger.info("Parser okkkkk");
  const uploadDir = path.join(__dirname, "ha.jpeg");
  fs.writeFile(uploadDir, req.files[0].buffer, (err) => {
    if (err) {
      next(err);
    }
  });
  res.send("created");
});
// app.post("/photo", async (req, res, next) => {
//   const form = formidable(formOptions);
//   await new Promise((resolve, reject) => {
//     form.parse(req, (err, fields, files) => {
//       if (err) {
//         functions.logger.error("Parser error");
//         next(err);
//         return;
//       }
//       functions.logger.info("Parser ok");
//       res.send("created");
//     // res.json({fields, files});
//     });
//     // form.on("file", (formname, file) => {
//     //   functions.logger.info("Parser OK");
//     //   res.send("created");
//     // });
//   });
//   // const uploadDir = path.resolve(__dirname, "./uploads/");
//   // if (!fs.existsSync(uploadDir)) {
//   //   fs.mkdir(uploadDir);
//   // }
//   // fs.writeFile(uploadDir, req.file.buffer, (err) => {
//   //   if (err) {
//   //     next(err);
//   //   }
//   // });
//   // functions.logger.info("Parser okkkkk");
//   // res.send("created");
// });

exports.api = functions.https.onRequest(app);
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

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
// firebase functions:shell => createUser({uid: "0UgNpe4TuhWEAu7E99LiJhk1E3G2"})

exports.createUser = functions.auth.user().onCreate(async (user) => {
  const newUser = {
    uid: user.uid,
    badges: [],
    dailyPhotoCount: 0,
    photoUploadTime: Timestamp.now(),
    messagingTokens: [],
  };
  await db.collection("users").add(newUser);
  functions.logger.info("User created", newUser);
});
