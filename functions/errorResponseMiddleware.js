const {functions} = require("./firebaseExports");

exports.errorResponse = function(err, req, res, next) {
  if ([400, 401].includes(err.statusCode)) {
    functions.logger.info("USER-ERROR", err.message);
    res.status(err.statusCode).json({error: err.message});
  } else {
    functions.logger.error("SERVER-ERROR", err.message);
    res.status(500).json({error: "Server error"});
  }
};
