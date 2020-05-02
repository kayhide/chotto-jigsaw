const $ = require("jquery");

exports.toArray = obj => Array.from(obj);


exports._loadImage = url => (onError, onSuccess) => {
  const elm = document.createElement("img");
  elm.crossOrigin = "Anonymous";
  elm.addEventListener("load", e => {
    onSuccess(elm);
  });
  elm.src = url;
  (cancelError, cancelerError, cancelerSuccess) => {
    elm.src = "";
    cancelerSuccess();
  };
};

exports.isTouchScreen = () =>
  !!('ontouchstart' in window || navigator.maxTouchPoints);

exports.isFullscreenAvailable = () =>
  document.fullscreenEnabled;

exports.toggleFullscreen = elm => () => {
  if (document.fullscreenElement) {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    }
  } else {
    elm.requestFullscreen();
  }
};


exports.setWidth = x => elm => () => $(elm).width(x);
exports.setHeight = x => elm => () => $(elm).height(x);

exports.trigger = x => elm => () => $(elm).trigger(x);

exports.fadeInSlow = elm => () => $(elm).fadeIn("slow");
exports.fadeOutSlow = elm => () => $(elm).fadeOut("slow");
exports.fadeToggle = elm => () => $(elm).fadeToggle();
