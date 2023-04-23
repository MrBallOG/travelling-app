const {db} = require("./firebaseExports");
const {Timestamp} = require("firebase-admin/firestore");

const SEC_PER_DAY = 60 * 60 * 24;
const MAX_PHOTOS_PER_DAY = 20;

exports.photoLimit = async function(req, res, next) {
  await db.runTransaction(async (transaction) => {
    const usersRef= db.collection("users");
    const q = usersRef
        .where("uid", "==", req.uid)
        .select("dailyPhotoCount", "photoUploadTime");
    const result = await transaction.get(q);
    const userData = result.docs[0].data();
    const userRef = result.docs[0].ref;
    const photoUploadTimeSec = userData.photoUploadTime.seconds;
    const now = Timestamp.now();
    const nowSec = now.seconds;
    const diffInDays = Math.floor((nowSec - photoUploadTimeSec) / SEC_PER_DAY);

    if (diffInDays > 0) {
      transaction
          .update(userRef, {
            dailyPhotoCount: 1,
            photoUploadTime: now,
          });
      return next();
    }

    const dailyPhotoCount = userData.dailyPhotoCount;
    if (dailyPhotoCount >= MAX_PHOTOS_PER_DAY) {
      const err = new Error("Daily photo count limit reached");
      err.statusCode = 403;
      return next(err);
    }

    transaction
        .update(userRef, {dailyPhotoCount: dailyPhotoCount + 1});
    next();
  });
};
