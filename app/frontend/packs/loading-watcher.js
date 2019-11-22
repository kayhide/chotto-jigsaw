import $ from "jquery";


function watch(elm) {
  const url = $(elm).data("loading");
  const id = elm.id;
  if (url && elm.id) {
    window.setTimeout(() => {
      $.ajax(url).then(res => {
        $(`#${id}`).replaceWith(res);
      });
    }, 3000);
  };
};

export default class LoadingWatcher {
  static init() {
    for (let elm of $("[data-loading]")) {
      watch(elm);
    };
    for (let elm of $(".loading-watcher")) {
      const observer = new MutationObserver((mutations, observer) => {
        for (let mutation of mutations) {
          for (let elm of mutation.addedNodes) {
            watch(elm);
          };
        };
      }).observe(elm, {childList: true});
    };
  }
};
