const busboy = require("busboy");
const fs = require("fs");
const path = require("path");
const os = require("os");
const {v4} = require("uuid");
const functions = require("firebase-functions");

exports.filesUpload = function(req, res, next) {
  let bb;
  try {
    bb = busboy({
      headers: req.headers,
      limits: {
        fileSize: 5 * 1024 * 1024,
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
  const files = [];
  const fileWrites = [];
  // Note: os.tmpdir() points to an in-memory file system on GCF
  // Thus, any files in it must fit in the instance's memory.
  const tmpdir = os.tmpdir();
  let fileAttached = false;

  bb.on("field", (name, val, info) => {
    // You could do additional deserialization logic here, values will just be
    // strings
    fields[name] = val;
  });

  bb.on("file", (name, file, info) => {
    fileAttached = true;
    const fileName = v4() + ".jpeg";
    const filepath = path.join(tmpdir, fileName);
    const writeStream = fs.createWriteStream(filepath);
    functions.logger.info("name", filepath);
    file.pipe(writeStream);

    fileWrites.push(
        new Promise((resolve, reject) => {
          file.on("end", () => writeStream.end());
          writeStream.on("finish", () => {
            fs.readFile(filepath, (err, buffer) => {
              const size = Buffer.byteLength(buffer);
              if (err) {
                return reject(err);
              }

              files.push({
                fileName,
                encoding: info.encoding,
                mimeType: info.mimeType,
                buffer,
                size,
              });

              try {
                fs.unlinkSync(filepath);
              } catch (error) {
                return reject(error);
              }

              resolve();
            });
          });
          writeStream.on("error", reject);
        }),
    );
  });

  bb.on("finish", () => {
    if (!fileAttached) {
      const err = new Error("No file attached");
      err.statusCode = 400;
      return next(err);
    }
    Promise.all(fileWrites)
        .then(() => {
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

          const longitude = Number.parseFloat(fields.longitude).toFixed(8);
          const latitude = Number.parseFloat(fields.latitude).toFixed(8);

          if (isNaN(longitude) || isNaN(latitude)) {
            const err = new Error("Longitude and latitude must be floats");
            err.statusCode = 400;
            return next(err);
          }

          fields.longitude = longitude;
          fields.latitude = latitude;

          req.body = fields;
          req.files = files;

          next();
        })
        .catch(next);
  });

  bb.end(req.rawBody);
  // if (req.rawBody) {
  //   bb.end(req.rawBody);
  // } else {
  //   req.pipe(bb);
  // }
};
