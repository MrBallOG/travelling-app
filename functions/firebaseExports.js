const admin = require("firebase-admin");
exports.functions = require("firebase-functions");

admin.initializeApp();

exports.db = admin.firestore();
exports.bucket = admin.storage().bucket();
exports.auth = admin.auth();
