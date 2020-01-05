const app = require("../playboard/App.bs");

exports.play = (obj) => () => app.play(obj);
