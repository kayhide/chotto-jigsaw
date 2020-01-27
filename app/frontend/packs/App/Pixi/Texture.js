const Pixi = require("pixi.js");

exports.fromElement = elm => () => Pixi.Texture.from(elm);
