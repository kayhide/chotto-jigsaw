module App.Interactor.BrowserInteractor where

import AppPrelude

import App.EaselJS.Stage as Stage
import App.Interactor.GameInteractor (GameInteractor)
import App.Logger as Logger
import App.Utils as Utils
import Data.Int as Int
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML as HTML
import Web.HTML.HTMLCanvasElement as HTMLCanvasElement
import Web.HTML.Window as Window

onWindowResize :: GameInteractor -> Effect Unit
onWindowResize gi = do
  window <- HTML.window
  width <- Window.innerWidth window
  height <- Window.innerHeight window
  Logger.info
    $ "window resized: width: " <> show width <> ", height: " <> show height

  [gi.activeStage, gi.baseStage] # traverse_ \stage -> do
    canvas <- HTMLCanvasElement.fromElement stage.canvas
              # throwOnNothing "Not Canvas element"

    Utils.setWidth (Int.toNumber width) canvas
    Utils.setHeight (Int.toNumber height) canvas
    HTMLCanvasElement.setWidth width canvas
    HTMLCanvasElement.setHeight height canvas

    Stage.invalidate stage

attach :: GameInteractor -> Effect Unit
attach gi = do
  listener <- eventListener \_ -> onWindowResize gi
  window <- HTML.window

  addEventListener (EventType "resize") listener false (Window.toEventTarget window)
  onWindowResize gi
