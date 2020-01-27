module App.Interactor.BrowserInteractor where

import AppPrelude

import App.Interactor.GameInteractor (GameInteractor)
import App.Logger as Logger
import App.Pixi.Application as Application
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML as HTML
import Web.HTML.Window as Window


onWindowResize :: GameInteractor -> Effect Unit
onWindowResize gi = do
  window <- HTML.window
  width <- Window.innerWidth window
  height <- Window.innerHeight window
  Logger.info
    $ "window resized: width: " <> show width <> ", height: " <> show height

  [gi.activeStage, gi.baseStage] # traverse_ \stage -> do
    Application.adjustPlacement stage

attach :: GameInteractor -> Effect Unit
attach gi = do
  listener <- eventListener \_ -> onWindowResize gi
  window <- HTML.window

  addEventListener (EventType "resize") listener false (Window.toEventTarget window)
  onWindowResize gi
