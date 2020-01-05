const EaselJS = require("@createjs/easeljs");

exports.create = canvas => () =>
  new EaselJS.Stage(canvas);

exports.isInvalidated = stage => () =>
  stage.isInvalidated;

exports.invalidate = stage => () =>
  stage.invalidated = true;

exports.update = stage => () => {
  if (stage.invalidated) {
    stage.update();
    stage.invalidated = false;
  };
};

exports._getObjectUnderPoint = pt => stage => () =>
  stage.getObjectUnderPoint(pt.x, pt.y);

exports.setNextStage = stage => next => () =>
  stage.nextStage = next;

exports.toDisplayObject = stage => stage;

exports.toContainer = stage => stage;
