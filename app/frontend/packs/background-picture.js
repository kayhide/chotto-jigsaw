import $ from "jquery";


export default class BackgroundPicture {
  static init() {
    const $body = $("body");
    const url = $body.data("picture");
    console.log(url);
    if (url) {
      $body.css("background-image", `url("${url}")`);
    }
  }
};
