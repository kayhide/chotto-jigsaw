import { Ticker } from "@createjs/easeljs";

import Puzzle from "./model/puzzle";
import Command from "./command/command";
import MergeCommand from "./command/merge_command";
import BrowserInteractor from "./interactor/browser_interactor";
import DoubleCanvasInteractor from "./interactor/double_canvas_interactor";

const sounds = {
  merge: $("#sound-list > .merge")[0]
};

function play() {
  const puzzle = new Puzzle($("#field")[0]);
  puzzle.parse($("#puzzle").data("content"));

  const image = new Image();
  $(image).on("load", () => {
    puzzle.initizlize(image);

    new BrowserInteractor(puzzle).attach();
    new DoubleCanvasInteractor(puzzle).attach();

    puzzle.shuffle();
    puzzle.fit();

    {
      const p = document.createElement("p");
      p.id = "piece-count";
      $(p).text(puzzle.pieces.length);
      $("#info").prepend(p);
    }

    Command.onPost.push(cmd => {
      if (cmd instanceof MergeCommand) {
        $("#progressbar").width(`${(puzzle.progress * 100).toFixed(0)}%`);
        if (sounds && sounds.merge) sounds.merge.play();
        if (puzzle.progress === 1) {
          $("#finished").fadeIn("slow", () =>
            $("#finished").css("opacity", 0.99)
          );
        }
      }
    });

    {
      const p = document.createElement("p");
      p.id = "ticker";
      $("#info").prepend(p);

      Ticker.framerate = 60;
      Ticker.addEventListener("tick", () => {
        if (puzzle.stage.invalidated) {
          puzzle.stage.update();
          puzzle.stage.invalidated = null;
        }
        $(p).text(`FPS: ${Math.round(Ticker.getMeasuredFPS())}`);
      });
    }

    $("body").css("overflow", "hidden");

    $("#playboard").fadeIn("slow");
  });

  $("#fit").on("click", () => {
    puzzle.fit();
    return false;
  });
  $("#zoom-in").on("click", () => {
    puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1.2);
    return false;
  });
  $("#zoom-out").on("click", () => {
    puzzle.zoom(window.innerWidth / 2, window.innerHeight / 2, 1 / 1.2);
    return false;
  });

  image.src = $("#picture").data("url");
}

$(document).ready(play);
$(document).on("turbolinks:load", play);
