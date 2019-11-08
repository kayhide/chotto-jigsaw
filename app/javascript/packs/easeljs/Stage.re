type t = DisplayObject.t;

[@bs.module "@createjs/easeljs"] [@bs.new] external create: 'a => t = "Stage";

[@bs.send] external update: t => unit = "update";

let canvas = (stage: t): Webapi.Dom.Element.t => stage##canvas;

let isInvalidated = (stage: t): bool => stage##invalidated;

let invalidate = (stage: t): unit => stage##invalidated #= true;
