const busboy = require("busboy");
const {v4} = require("uuid");

exports.filesUpload = function(req, res, next) {
  let bb;
  const fileSize = 5 * 1024 * 1024;
  try {
    bb = busboy({
      headers: req.headers,
      limits: {
        fileSize: fileSize,
        fieldSize: 16,
        fieldNameSize: 16,
        fields: 2,
        files: 1,
      },
    });
  } catch (err) {
    err.statusCode = 400;
    return next(err);
  }

  const fields = {};
  const file = {};
  let fileAttached = false;
  let err;

  bb.on("field", (name, val, info) => {
    fields[name] = Number.parseFloat(val).toFixed(8);
  });

  bb.on("file", (name, stream, info) => {
    if (info.mimeType !== "image/jpeg") {
      stream.resume();
      err = new Error("File must be a jpeg image");
      err.statusCode = 400;
      return;
    }

    fileAttached = true;
    const bufferList = [];
    let bufferLength = 0;

    // stream.on("limit", () => {
    //   const err = new Error(`File must be smaller than ${fileSize} bytes`);
    //   err.statusCode = 400;
    //   return next(err);
    // });

    stream.on("data", (chunk) => {
      bufferList.push(chunk);
      bufferLength += chunk.length;
    });

    stream.on("end", () => {
      if (stream.truncated) {
        err = new Error(`File must be smaller than ${fileSize} bytes`);
        err.statusCode = 400;
        return;
      } else {
        file.buffer = Buffer.concat(bufferList, bufferLength);
        file.fileName = v4() + ".jpeg";
      }
    });
  });

  bb.on("finish", () => {
    if (err) return next(err);

    if (!fileAttached) {
      const err = new Error("No file attached");
      err.statusCode = 400;
      return next(err);
    }

    const hasLongitude = Object.prototype.hasOwnProperty.call(
        fields, "longitude",
    );
    const hasLatitude = Object.prototype.hasOwnProperty.call(
        fields, "latitude",
    );

    if (!hasLatitude || !hasLongitude) {
      const err = new Error("Missing fields");
      err.statusCode = 400;
      return next(err);
    }

    if (isNaN(fields.longitude) || isNaN(fields.latitude)) {
      const err = new Error("Longitude and latitude must be floats");
      err.statusCode = 400;
      return next(err);
    }

    req.body = fields;
    req.file = file;

    next();
  });

  bb.end(req.rawBody);
  // if (req.rawBody) {
  //   bb.end(req.rawBody);
  // } else {
  //   req.pipe(bb);
  // }
};
