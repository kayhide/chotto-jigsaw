const Pixi = require( "pixi.js")

exports.create = () => {
  g = new Pixi.Graphics();
  g.buttonMode = true;
  g.interactive = true;
  return g;
};

exports.clear = g => () => g.clear();
exports.setLineStyle = style => g => () => g.lineStyle(style);
exports.closePath = g => () =>  g.closePath();
exports.beginFill = color => alpha => g => () =>  g.beginFill(color, alpha);
exports.beginTextureFill = texture => g => () =>  g.beginTextureFill({ texture });
exports.endFill = g => () =>  g.endFill();
exports.moveTo = ({ x, y }) => g => () =>  g.moveTo(x, y);
exports.lineTo = ({ x, y }) => g => () =>  g.lineTo(x, y);
exports.bezierCurveTo = cp1 => cp2 => pt => g => () =>
  g.bezierCurveTo(cp1.x, cp1.y, cp2.x, cp2.y, pt.x, pt.y);
exports.drawRect = rect => g => () =>  g.drawRect(rect.x, rect.y, rect.width, rect.height);
exports.drawCircle = ({ x, y }) => radius => g => () =>  g.drawCircle(x, y, radius);
