module IntOrd = {
  type t = int;
  let compare = compare;
};

include Set.Make(IntOrd);
