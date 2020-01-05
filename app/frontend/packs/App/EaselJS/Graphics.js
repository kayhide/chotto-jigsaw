const EaselJS = require( "@createjs/easeljs")

exports.clear = g => () => g.clear();
exports.setStrokeStyle = thickness => g => () =>  g.setStrokeStyle(thickness);
exports.beginStroke = color => g => () =>  g.beginStroke(color);
exports.endStroke = g => () =>  g.endStroke();
exports.beginFill = color => g => () =>  g.beginFill(color);
exports.beginBitmapFill = image => g => () =>  g.beginBitmapFill(image);
exports.endFill = g => () =>  g.endFill();
exports.moveTo = ({ x, y }) => g => () =>  g.moveTo(x, y);
exports.lineTo = ({ x, y }) => g => () =>  g.lineTo(x, y);
exports.bezierCurveTo = cp1 => cp2 => pt => g => () =>
  g.bezierCurveTo(cp1.x, cp1.y, cp2.x, cp2.y, pt.x, pt.y);
exports.drawRect = rect => g => () =>  g.drawRect(rect.x, rect.y, rect.width, rect.height);
exports.drawCircle = ({ x, y }) => radius => g => () =>  g.drawCircle(x, y, radius);
