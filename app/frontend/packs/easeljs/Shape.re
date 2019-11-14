type t = DisplayObject.t;

[@bs.module "@createjs/easeljs"] [@bs.new]
external create: unit => t = "Shape";

[@bs.send] external graphics: t => Graphics.t = "graphics";
