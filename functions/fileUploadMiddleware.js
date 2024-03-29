const busboy = require("busboy");
const {v4} = require("uuid");

exports.fileUpload = function(req, res, next) {
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
    fields[name] = Number.parseFloat(val);
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
        file.filename = v4() + ".jpeg";
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

    if (!hasLongitude || !hasLatitude) {
      const err = new Error("Missing fields");
      err.statusCode = 400;
      return next(err);
    }

    const longitude = fields.longitude;
    const latitude = fields.latitude;

    if (isNaN(longitude) || isNaN(latitude)) {
      const err = new Error("Longitude and latitude must be floats");
      err.statusCode = 400;
      return next(err);
    }

    const longitudeInBounds = longitude <= 180 && longitude >= -180;
    const latitudeInBounds = latitude <= 90 && latitude >= -90;

    if (!longitudeInBounds || !latitudeInBounds) {
      const err = new Error(
          "Longitude and latitude must be in bounds ([-180, 180], [-90, 90])");
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
