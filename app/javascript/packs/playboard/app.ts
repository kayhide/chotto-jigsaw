import { Ticker } from "@createjs/easeljs";

import Logger from "./logger";
import Action from "./action";
import Puzzle from "./model/puzzle";
import Command from "./command/command";
import MergeCommand from "./command/merge_command";
import Game from "./interactor/game";
import BrowserInteractor from "./interactor/browser_interactor";
import TouchInteractor from "./interactor/touch_interactor";
import MouseInteractor from "./interactor/mouse_interactor";
import PuzzleDrawer from "./drawer/puzzle_drawer";

function isTouchScreen(): boolean {
  return "ontouchstart" in window;
}

function isFullscreenAvailable(): boolean {
  return document.fullscreenEnabled;
}

function toggleFullScreen(element: JQuery) {
  if (document.fullscreenElement) {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    }
  } else {
    const fs = element[0] as HTMLElement;
    if (fs.requestFullscreen) {
      Logger.trace(`requestFullscreen`);
      fs.requestFullscreen();
    }
  }
}

class Guider {
  _guide = false;
  puzzle: Puzzle;
  drawer: PuzzleDrawer;

  constructor(puzzle: Puzzle) {
    this.puzzle = puzzle;
    this.drawer = new PuzzleDrawer();
  }

  get guide(): boolean {
    return this._guide;
  }

  set guide(f: boolean) {
    this._guide = f;
    if (this._guide) {
      $("#active-canvas").addClass("z-depth-3");
    } else {
      $("#active-canvas").removeClass("z-depth-3");
    }
    this.drawer.drawsGuide = this._guide;
    this.drawer.draw(this.puzzle, this.puzzle.shape.graphics);
    this.puzzle.invalidate();
  }

  toggle(): void {
    this.guide = !this.guide;
  }
}

function play(): void {
  const puzzle = new Puzzle($("#field")[0] as HTMLCanvasElement);
  puzzle.parse(JSON.parse($($("#playboard").data("puzzle")).text()));
  const game = new Game(puzzle);

  const sounds = {
    merge: $("#sound-list > .merge")[0] as HTMLAudioElement
  };

  const image = new Image();
  image.crossOrigin = "anonymous";
  $(image).on("load", () => {
    Logger.trace(`image loaded: ${image.src}`);
    puzzle.initizlize(image);
    new PuzzleDrawer().draw(puzzle, puzzle.shape.graphics);

    new BrowserInteractor(game).attach();
    if (isTouchScreen()) {
      new TouchInteractor(game).attach();
      Logger.trace("attached: TouchInteractor");
    } else {
      new MouseInteractor(game).attach();
      Logger.trace("attached: MouseInteractor");
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

    puzzle.shuffle();
    Action.fit(game.puzzle);

    {
      Ticker.framerate = 60;
      Ticker.addEventListener("tick", () => {
        if (puzzle.stage.invalidated) {
          puzzle.stage.update();
          puzzle.stage.invalidated = false;
        }
        $("#info .fps").text(`FPS: ${Math.round(Ticker.getMeasuredFPS())}`);
      });
    }

    $("body").css("overflow", "hidden");

    $("#field").fadeIn("slow");

    const guider = new Guider(puzzle);
    $(window).on("keydown", e => {
      if (e.key === "F1") {
        $("#log-button").trigger("click");
      }
      if (e.key === "F2") {
        guider.toggle();
      }
    });
  });

  $("#log-button").on("click", () => {
    $("#log").fadeToggle();
    $("#log-button").toggleClass("rotate-180");
  });

  if (isFullscreenAvailable()) {
    $("#fullscreen")
      .removeClass("hidden")
      .on("click", () => toggleFullScreen($("#playboard")));
  }

  image.src = $("#playboard").data("picture");
}

$(document).ready(play);
