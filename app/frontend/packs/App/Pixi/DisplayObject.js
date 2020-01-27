const Pixi = require("pixi.js");

exports.update = attrs => obj => () => {
  if (attrs.position) {
    obj.position = attrs.position;
  } else {
    if (attrs.x) obj.x = attrs.x;
    if (attrs.y) obj.y = attrs.y;
  }
  if (attrs.rotation) {
    obj.rotation = attrs.rotation;
  }
  if (attrs.scale) {
    obj.scale = attrs.scale;
  }
};

exports.clearTransform = obj => () =>
  obj.setTransform();

exports.getMatrix = obj => obj.localTransform;

exports._getParent = obj => obj.parent;


exports.setName = name => obj => () =>
  obj.name = name;

exports.getName = obj => () => obj.name;


exports.setHitArea = area => obj => () =>
  obj.hitArea = area;

exports.hitTest = pt => obj => () =>
  obj.hitTest(pt.x, pt.y);


exports.cache = obj => () => {
  obj.cacheAsBitmap = true;
}

exports.toGlobal = pt => obj => () =>
  obj.toGlobal(pt);

exports.toLocal = pt => obj => () =>
  obj.toLocal(pt);

exports.getCanvas = obj => () =>
  obj.canvas;
