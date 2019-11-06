type handler('a) = ('a) => unit;
type handlers('a) = list(handler('a));

let create = () : handlers('a) => {
  [];
};

let append = (handler : handler('a), handlers : handlers('a)) : handlers('a) => {
  List.append(handlers, [handler]);
};

let prepend = (handler : handler('a), handlers : handlers('a)) : handlers('a) => {
  [handler, ...handlers];
};

let fire = (x : 'a, handlers : handlers('a)) : unit => {
  handlers |> List.iter(f => f(x));
}
