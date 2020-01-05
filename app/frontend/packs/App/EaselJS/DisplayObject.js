const EaselJS = require("@createjs/easeljs");

exports.update = attrs => obj => () => {
  if (attrs.position) {
    if (attrs.position.x) obj.x = attrs.position.x;
    if (attrs.position.y) obj.y = attrs.position.y;
  } else {
    if (attrs.x) obj.x = attrs.x;
    if (attrs.y) obj.y = attrs.y;
  }
  if (attrs.rotation) obj.rotation = attrs.rotation;
  if (attrs.scaleX) obj.scaleX = attrs.scaleX;
  if (attrs.scaleY) obj.scaleY = attrs.scaleY;
};

exports.clearTransform = obj => () =>
  obj.setTransform();

exports.getMatrix = obj =>
  obj.getMatrix();

exports._getParent = obj =>
  obj.parent;

exports._getStage = obj => {
  let obj_ = obj;
  while (obj_.parent) {
    obj_ = obj_.parent;
  }
  return (obj_ instanceof EaselJS.Stage) ? obj_ : null;
};

exports.setHitArea = area => obj => () =>
  obj.hitArea = area;

exports.hitTest = pt => obj => () =>
  obj.hitTest(pt.x, pt.y);


exports.setShadow = shadow => obj => () =>
  obj.shadow = new EaselJS.Shadow(shadow.color, shadow.offsetX, shadow.offsetY, shadow.blur);


exports.cache = rect => scale => obj => () =>
  obj.cache(rect.x, rect.y, rect.width, rect.height, scale);

exports.localToGlobal = pt => obj => () =>
  obj.localToGlobal(pt.x, pt.y);

exports.globalToLocal = pt => obj => () =>
  obj.globalToLocal(pt.x, pt.y);

exports.getCanvas = obj => () =>
  obj.canvas;
