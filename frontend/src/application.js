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
