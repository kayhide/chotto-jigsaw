type handler = EventHandler.handler(string);
type handlers = EventHandler.handlers(string);

let handlers: ref(handlers) = ref(EventHandler.create());

let append = handler: unit =>
  handlers := handlers^ |> EventHandler.append(handler);

let trace = (msg: string): unit => handlers^ |> EventHandler.fire(msg);

let traceId = (msg: string): string => {
  msg |> trace;
  msg;
};

[@bs.send] external toString: 'a => string = "toString";

let traceShow = (obj: 'a): unit =>
  handlers^ |> EventHandler.fire(obj |> toString);

let traceShowId = (obj: 'a): 'a => {
  obj |> traceShow;
  obj;
};
