const Pixi = require( "pixi.js")

exports.create = new Pixi.Matrix();

exports.from = attrs =>
  new Pixi.Matrix().appendTransform(
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

exports.decompose = mtx => {
  let t = new Pixi.Transform();
  mtx.decompose(t);
  return t;
}

exports.appendMatrix = src => dst =>
  {
    return dst.clone().append(src);
  }

exports.appendTransform = ({ x, y, scaleX, scaleY, rotation }) => mtx =>
  mtx.clone().appendTransform(x, y, scaleX, scaleY, rotation);

exports.apply = pt => mtx => mtx.apply(pt);
