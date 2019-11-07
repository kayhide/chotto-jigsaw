import { Ticker, Rectangle } from "@createjs/easeljs";

import * as Logger from "../common/Logger.bs";
import * as Screen from "../common/Screen.bs";
import View from "./view";
import Bridge from "./bridge";
import Puzzle from "./model/puzzle";
import Command from "./command/command";
import MergeCommand from "./command/merge_command";
import Game from "./interactor/game";
import BrowserInteractor from "./interactor/browser_interactor";
import TouchInteractor from "./interactor/touch_interactor";
import MouseInteractor from "./interactor/mouse_interactor";
import PuzzleDrawer from "./drawer/puzzle_drawer";
import GameChannel from "../channel/game_channel";

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

function setupLogger(): void {
  Logger.append(message => {
    $("#log").append($(document.createElement("p")).text(message));
    window.console.log(message);
  });
}

function setupUi(puzzle: Puzzle): void {
  Ticker.addEventListener("tick", () => {
    $("#info .fps").text(`FPS: ${Math.round(Ticker.getMeasuredFPS())}`);
  });

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

  $("#log-button").on("click", () => {
    $("#log").fadeToggle();
    $("#log-button").toggleClass("rotate-180");
  });

  if (Screen.isFullscreenAvailable()) {
    $("#fullscreen")
      .removeClass("hidden")
      .on("click", () => Screen.toggleFullScreen($("#playboard")[0]));
  }

  Command.onCommit(cmds => {
    if (_(cmds).some(cmd => cmd instanceof MergeCommand)) {
      $("#progressbar").width(`${(puzzle.progress * 100).toFixed(0)}%`);
    }
  });
}

function setupSound(): void {
  const sounds = {
    merge: $("#sound-list > .merge")[0] as HTMLAudioElement
  };

  Command.onPost(cmd => {
    if (cmd instanceof MergeCommand) {
      if (sounds.merge) sounds.merge.play();
    }
  });
}

function connectGameChannel(game_id: number): void {
  const channel = GameChannel.subscribe(game_id);
  Command.onCommit(cmd => channel.commit(cmd));
}

function play(): void {
  setupLogger();

  const $playboard = $("#playboard");
  const puzzle = new Puzzle($("#field")[0] as HTMLCanvasElement);
  puzzle.parse(JSON.parse($($playboard.data("puzzle")).text()));

  const image = new Image();
  image.crossOrigin = "anonymous";
  $(image).on("load", () => {
    Logger.trace(`image loaded: ${image.src}`);
    puzzle.initizlize(image);
    new PuzzleDrawer().draw(puzzle, puzzle.shape.graphics);
    setupUi(puzzle);
    setupSound();

    const game = new Game(puzzle);

    if (typeof $playboard.data("initial-view") !== "undefined") {
      const { width, height } = $playboard.data("initial-view");
      View.contain(puzzle, new Rectangle(0, 0, width, height));
    }
    if (typeof $playboard.data("standalone") !== "undefined") {
      puzzle.shuffle();
      Command.commit();
    } else {
      connectGameChannel($playboard.data("game-id"));
    }

    new BrowserInteractor(game).attach();
    if (Screen.isTouchScreen()) {
      new TouchInteractor(game).attach();
      Logger.trace("attached: TouchInteractor");
    } else {
      new MouseInteractor(game).attach();
      Logger.trace("attached: MouseInteractor");
    }
  });

  image.src = $playboard.data("picture");
}

$(document).ready(play);
