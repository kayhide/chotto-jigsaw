module type T = {
  type identifier;
  type funcs;
  type subscription;
};

module Make = (X: T) => {
  type identifier = X.identifier;
  type funcs = X.funcs;
  type subscription = X.subscription;

  type subscriptions;
  type consumer = {. "subscriptions": subscriptions};

  [@bs.module "@rails/actioncable"]
  external createConsumer: unit => consumer = "createConsumer";

  [@bs.send]
  external create: (subscriptions, identifier, funcs) => subscription =
    "create";

  [@bs.send] external perform: (subscription, string, 'a) => unit = "perform";
};
