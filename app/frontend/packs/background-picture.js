export default class BackgroundPicture {
  static init() {
    const elms = document.querySelectorAll(".background-picture .bg-image");
    const next = (i) => {
      const elm = elms[i];
      if (elm) {
        const url = elm.dataset.src;
        if (url) {
          const img = new Image();
          img.onload = () => {
            elm.classList.add("loaded");
            elm.style.backgroundImage = `url(${url})`;
            window.setTimeout(() => next(i + 1), 1000);
          };
          img.src = elm.dataset.src;
        } else {
          next(i + 1);
        }
      }
    }
    next(0);
  }
};
