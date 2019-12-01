export default class FabAction {
  static init() {
    const elms = document.querySelectorAll("[data-toggle=fab-action]");
    for (let elm of elms) {
      const parent = elm.parentElement;
      elm.onclick = () => {
        elm.classList.toggle("active");
        for (let btn of parent.querySelectorAll(".fab-action-menu button")) {
          btn.classList.toggle("show");
        }
      };
    }
  }
};
