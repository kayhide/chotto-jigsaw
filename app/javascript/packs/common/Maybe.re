let maybe = (y : 'b, f : 'a => 'b, x : option('a)) : 'b =>
  switch (x) {
  | None => y
  | Some(x') => f(x')
  };

let fromMaybe = (y : 'a, x : option('a)) : 'a =>
  switch (x) {
  | None => y
  | Some(x') => x'
  };

let isNone = (x : option('a)) : bool =>
  switch (x) {
  | None => true
  | Some(_) => false
  };

let isSome = (x : option('a)) : bool =>
  switch (x) {
  | None => false
  | Some(_) => true
  };

let map = (f : 'a => 'b, x : option('a)) : option('b) =>
  switch (x) {
  | None => None
  | Some(x') => Some(f(x'))
  };

let pure = (x : 'a) : option('a) =>
  Some(x);

let bind = (f : 'a => option('b), x : option('a)) : option('b) =>
  switch (x) {
  | None => None
  | Some(x') => f(x')
  };

let guard = (f : 'a => bool, x : option('a)) : option('a) =>
  switch (x) {
  | None => None
  | Some(x') => f(x') ? x : None;
  };

let traverse_ = (f : 'a => 'b, x : option('a)) : unit =>
  switch (x) {
  | None => ()
  | Some(x') => {
      f(x');
      ();
    }
  };

let catMaybes = (xs : list(option('a))) : list('a) => {
  let rec f = (xs') => switch (xs') {
    | [] => []
    | [None, ...xs''] => f(xs'')
    | [Some(x), ...xs''] => [x, ...f(xs'')]
  };
  f(xs);
};

let fromJust : (option('a)) => 'a = fun
| Some(x) => x
| None => raise(Invalid_argument("Passed `None` to unwrapUnsafely"))
;
