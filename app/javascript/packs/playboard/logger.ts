export default class Logger {
  static trace(message): void {
    $("#log").append($(document.createElement("p")).text(message));
    window.console.log(message);
  }
}
