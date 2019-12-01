// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/frontend and only use these pack files to reference
// that code so it'll be compiled.

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

require("@rails/ujs").start();
require("@rails/activestorage").start();

import $ from "jquery";
import "bootstrap";
import bsCustomFileInput from "bs-custom-file-input";

import LoadingWatcher from "./loading-watcher";
import BackgroundPicture from "./background-picture";

import "../styles/application";

$(document).ready(() => {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
  bsCustomFileInput.init();
  LoadingWatcher.init();
  BackgroundPicture.init();

  if (document.location.hash !== "") {
    $(`[href="${document.location.hash}"]`).trigger('click');
  };

  $('a[data-toggle="pill"]').on('show.bs.tab', (e) => {
    if (e.target.dataset.url) {
      history.pushState(history.state, document.title, e.target.dataset.url);
    }
    else {
      history.pushState(history.state, document.tilte, e.target.href);
    }
  })
})
