import $ from "jquery";


export default class BackgroundPicture {
  static init() {
    const $elm = $(".background-picture");
    const url = $elm.data("picture");
    console.log(url);
    if (url) {
      $elm.css("background-image", `url("${url}")`);
    }
  }
};
