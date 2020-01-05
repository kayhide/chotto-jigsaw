// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/frontend and only use these pack files to reference
// that code so it'll be compiled.

import $ from "jquery";
import "bootstrap";
import "../styles/playboard";

import FabAction from "./fab-action";
import App from "./App/App";

$(document).ready(() => {
  FabAction.init();
  App.init();
});
