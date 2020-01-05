const Hammer = require("hammerjs");

exports.create = target => () =>
  new Hammer(target);

exports.get = name => manager => () =>
  manager.get(name);

exports.set = opts => recognizer => () =>
  recognizer.set(opts);

exports.recognizeWith = obj => sbj => () =>
  sbj.recognizeWith(obj);

exports.addHammerEventListener = name => manager => listener => () =>
  manager.on(name, e => listener(e)());
