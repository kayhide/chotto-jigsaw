const EaselJS = require( "@createjs/easeljs")

exports.create = new EaselJS.Matrix2D();

exports.from = attrs =>
  new EaselJS.Matrix2D().appendTransform(
    attrs.x || 0.0,
    attrs.y || 0.0,
    attrs.rotation || 0.0,
    attrs.scaleX || 1.0,
    attrs.scaleY || 1.0
  );

exports.toString = mtx => mtx.toString();

exports.translate = dx => dy => mtx => mtx.clone().translate(dx, dy);

exports.rotate = d => mtx => mtx.clone().rotate(d);

exports.scale = s => mtx => mtx.clone().scale(s, s);

exports.invert = mtx => mtx.clone().invert();

exports.decompose = mtx => mtx.decompose();

exports.appendMatrix = src => dst => dst.clone().appendMatrix(src);

exports.appendTransform = ({ x, y, scaleX, scaleY, rotation }) => mtx =>
  mtx.clone().appendTransform(x, y, scaleX, scaleY, rotation);

exports.apply = ({ x, y }) => mtx => mtx.transformPoint(x, y);
