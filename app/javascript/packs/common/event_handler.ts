export default class EventHandler<T> {
  handlers: Array<(T) => void> = [];

  append(handler: (T) => void): void {
    this.handlers.push(handler);
  }

  prepend(handler: (T) => void): void {
    this.handlers.unshift(handler);
  }

  fire(x: T): void {
    this.handlers.forEach(f => f(x));
  }
}
