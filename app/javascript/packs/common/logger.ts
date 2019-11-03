import EventHandler from "./event_handler";

export default class Logger {
  static handlers = new EventHandler<any>();

  static append(handler: (any) => void): void {
    this.handlers.append(handler);
  }

  static trace(message: any): void {
    this.handlers.fire(message);
  }
}
