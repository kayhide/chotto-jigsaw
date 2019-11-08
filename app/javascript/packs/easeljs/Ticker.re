type ticker = {. [@bs.set] "framerate": int};

[@bs.module "@createjs/easeljs"] [@bs.val] external _ticker: ticker = "Ticker";

[@bs.send]
external _getMeasuredFPS: (ticker, unit) => float = "getMeasuredFPS";
[@bs.send]
external _addEventListener: (ticker, string, unit => unit) => unit =
  "addEventListener";

let getFramerate = (): int => _ticker##framerate;

let setFramerate = (x: int): unit => _ticker##framerate #= x;

let getMeasuredFPS = (): float => _ticker->_getMeasuredFPS();

let addEventListener = (e: string, f: unit => unit): unit =>
  _ticker->_addEventListener(e, f);
