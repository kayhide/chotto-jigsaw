export default class Screen {
  static isTouchScreen(): boolean {
    return "ontouchstart" in window;
  }

  static isFullscreenAvailable(): boolean {
    return document.fullscreenEnabled;
  }

  static toggleFullScreen(element: JQuery): void {
    if (document.fullscreenElement) {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      }
    } else {
      const elm = element[0] as HTMLElement;
      if (elm.requestFullscreen) {
        elm.requestFullscreen();
      }
    }
  }
}
