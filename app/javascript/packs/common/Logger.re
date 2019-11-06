type handler = EventHandler.handler(string);
type handlers = EventHandler.handlers(string);

let handlers : ref(handlers) = ref(EventHandler.create());

let append = (handler) : unit => {
  handlers := handlers^ |> EventHandler.append(handler);
};

let trace = (msg : string) : unit => {
  handlers^ |> EventHandler.fire(msg);
};
