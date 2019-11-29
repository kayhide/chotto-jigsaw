type window('a) = {. "ontouchstart": 'a};
[@bs.val] external window: window('a) = "window";

type element = Webapi.Dom.Element.t;
type document = {
  .
  "fullscreenEnabled": bool,
  "fullscreenElement": Js.Nullable.t(element),
  "exitFullscreen": Js.Nullable.t(unit => unit),
};
[@bs.val] external document: document = "document";

let isTouchScreen = (): bool => window##ontouchstart !== Js.Nullable.undefined;

let isFullscreenAvailable = (): bool => document##fullscreenEnabled;

let toggleFullScreen = element: unit =>
  if (document##fullscreenElement !== Js.Nullable.null) {
    document##exitFullscreen
    |> Js.Nullable.toOption
    |> Maybe.maybe((), f => f());
  } else {
    element |> Webapi.Dom.Element.requestFullscreen;
  };
