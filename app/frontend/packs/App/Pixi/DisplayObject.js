const Pixi = require("pixi.js");

exports.update = _ => attrs => obj => () => {
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

exports.clearTransform = _ => obj => () => obj.setTransform();
exports.getMatrix = _ => obj => obj.localTransform;
exports._getParent = _ => obj => obj.parent;


exports.setName = _ => name => obj => () => obj.name = name;
exports.getName = _ => obj => () => obj.name;


exports.setHitArea = _ => area => obj => () => obj.hitArea = area;
exports.hitTest = _ => pt => obj => () => obj.hitTest(pt.x, pt.y);


exports.cache = _ => obj => () => obj.cacheAsBitmap = true;


exports.toGlobal = _ => pt => obj => () => obj.toGlobal(pt);
exports.toLocal = _ => pt => obj => () => obj.toLocal(pt);

exports.getCanvas = _ => obj => () => obj.canvas;
