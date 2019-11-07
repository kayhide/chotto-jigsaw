let maybe = (y : 'b, f : 'a => 'b, x : option('a)) : 'b => {
  switch (x) {
  | None => y
  | Some(x') => f(x')
  };
};

let isSome = (x : option('a)) : bool => {
  switch (x) {
  | None => false
  | Some(_) => true
  };
};
