const Pixi = require("pixi.js");

exports.create = view => () =>
  new Pixi.Application({
    view,
    autoResize: true,
    // resolution: devicePixelRatio,
    resolution: 1,
    antialias: true,
    transparent: true
  });

exports.adjustPlacement = app => () => {
  const parent = app.view.parentNode;
  app.renderer.resize(parent.clientWidth, parent.clientHeight);
  app.stage.position.x = app.screen.width / 2;
  app.stage.position.y = app.screen.height / 2;
};

exports._hitTest = pt => app => () =>
  app.renderer.plugins.interaction.hitTest(pt);
