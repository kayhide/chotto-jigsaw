const EaselJS = require("@createjs/easeljs");

exports.getMeasuredFPS = () => EaselJS.Ticker.getMeasuredFPS();

exports.getFramerate = () => EaselJS.Ticker.framerate;

exports.setFramerate = x => () => EaselJS.Ticker.framerate = x;

exports.onTick = action => () =>
  EaselJS.Ticker.addEventListener("tick", action);
