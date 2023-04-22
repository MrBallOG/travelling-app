const {auth} = require("./firebaseExports");

exports.authorization = async function(req, res, next) {
  const header = req.headers.authorization;
  if (!header) {
    const err = new Error("Missing authorization header");
    err.statusCode = 401;
    return next(err);
  }
  const headerArr = header.split(" ");
  if (headerArr.length !== 2 || headerArr[0] !== "Bearer") {
    const err = new Error("Authorization must be a bearer token");
    err.statusCode = 401;
    return next(err);
  }
  try {
    const token = await auth.verifyIdToken(headerArr[1]);
    req.uid = token.uid;
    next();
  } catch (_) {
    const err = new Error("Invalid token");
    err.statusCode = 401;
    return next(err);
  }
};
