type jquery('a) = Js.t('a);

[@bs.module "jquery"] external jquery: 'a => jquery('b) = "default";
[@bs.send] external data: (jquery('a), string) => 'b = "data";
[@bs.send] external getText: (jquery('a), unit) => string = "text";
[@bs.send] external setText: (jquery('a), string) => 'b = "text";
[@bs.send] external on: (jquery('a), string, 'e => unit) => unit = "on";
[@bs.send] external trigger: (jquery('a), string) => 'b = "trigger";
[@bs.send] external append: (jquery('a), 'b) => jquery('a) = "append";
[@bs.send] external ready: (jquery('a), 'b) => unit = "ready";
[@bs.send] external fadeIn: (jquery('a), string) => 'b = "fadeIn";
[@bs.send] external fadeOut: (jquery('a), string) => 'b = "fadeOut";
[@bs.send] external fadeToggle: (jquery('a), unit) => 'b = "fadeToggle";
[@bs.send] external addClass: (jquery('a), string) => 'b = "addClass";
[@bs.send] external removeClass: (jquery('a), string) => 'b = "removeClass";
[@bs.send] external toggleClass: (jquery('a), string) => 'b = "toggleClass";
[@bs.send] external get: (jquery('a), unit) => 'b = "get";
[@bs.send] external show: (jquery('a), unit) => 'b = "show";
[@bs.send] external hide: (jquery('a), unit) => 'b = "hide";
[@bs.send] external css: (jquery('a), string, 'a) => 'b = "css";
[@bs.send] external setWidth: (jquery('a), float) => 'b = "width";
[@bs.send] external setHeight: (jquery('a), float) => 'b = "height";

type offset = {
  .
  "left": float,
  "top": float,
};
[@bs.send] external getOffset: (jquery('a), unit) => offset = "offset";
[@bs.send] external setOffset: (jquery('a), offset) => 'b = "offset";
