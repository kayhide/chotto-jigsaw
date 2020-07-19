import $ from "jquery";
import "bootstrap";
// import "../styles/playboard";

import FabAction from "./fab-action";
import App from "./App/App";

$(document).ready(() => {
  FabAction.init();
  App.init();
});
