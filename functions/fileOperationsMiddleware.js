const sharp = require("sharp");

exports.fileOperations = async function(req, res, next) {
  let newBuffer;
  try {
    newBuffer = await sharp(req.file.buffer)
        .jpeg({
          mozjpeg: true,
          quality: 70,
        })
        .toBuffer();
  } catch (err) {
    err.statusCode = 400;
    return next(err);
  }
  req.file.buffer = newBuffer;
  next();
};
