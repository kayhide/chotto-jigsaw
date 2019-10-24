import { Ticker } from "@createjs/easeljs";

import Logger from "./logger";
import Puzzle from "./model/puzzle";
import Command from "./command/command";
import MergeCommand from "./command/merge_command";
import Game from "./interactor/game";
import BrowserInteractor from "./interactor/browser_interactor";
import TouchInteractor from "./interactor/touch_interactor";
import MouseInteractor from "./interactor/mouse_interactor";

function isTouchScreen() {
  return "ontouchstart" in window;
}

function play() {
  const puzzle = new Puzzle($("#field")[0]);
  puzzle.parse($("#puzzle").data("content"));
  const game = new Game(puzzle);

  const sounds = {
    merge: $("#sound-list > .merge")[0]
  };

  const image = new Image();
  image.crossOrigin = "anonymous";
  $(image).on("load", () => {
    puzzle.initizlize(image);

    new BrowserInteractor(game).attach();
    if (isTouchScreen()) {
      new TouchInteractor(game).attach();
      Logger.trace("attached: TouchInteractor");
    } else {
      new MouseInteractor(game).attach();
      Logger.trace("attached: MouseInteractor");
    }

    puzzle.shuffle();
    game.fit();

    {
      const p = document.createElement("p");
      p.id = "piece-count";
      $(p).text(puzzle.pieces.length);
      $("#info").prepend(p);
    }

    Command.onPost.push(cmd => {
      if (cmd instanceof MergeCommand) {
        $("#progressbar").width(`${(puzzle.progress * 100).toFixed(0)}%`);
        if (sounds.merge) sounds.merge.play();
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

    $(window).on("keydown", e => {
      if (e.key === "F1") {
        game.guide = !game.guide
        game.guide ? $("#log").fadeIn() : $("#log").fadeOut()
      }
    });
  });

  $("#fit").on("click", () => {
    game.fit();
    return false;
  });

  image.src = $("#picture").data("url");
}

$(document).ready(play);
