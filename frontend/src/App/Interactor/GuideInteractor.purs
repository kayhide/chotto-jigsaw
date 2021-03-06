module App.Interactor.GuideInteractor where

import AppPrelude

import App.Drawer.PuzzleDrawer as PuzzleDrawer
import App.Interactor.GameInteractor (GameInteractor)
import App.Utils as Utils
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Effect.Unsafe (unsafePerformEffect)
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML as HTML
import Web.HTML.HTMLCanvasElement as HTMLCanvasElement
import Web.HTML.Window as Window
import Web.UIEvent.KeyboardEvent as KeyboardEvent


isActive :: Ref Boolean
isActive = unsafePerformEffect $ Ref.new false

setActive :: Boolean -> GameInteractor -> Effect Unit
setActive b gi = do
  Ref.write b isActive

  let canvas = (unwrap gi.activeStage).view
  bool Utils.removeClass Utils.addClass b "shadow" $ HTMLCanvasElement.toElement canvas

  let actor = gi.manager.puzzleActor
  PuzzleDrawer.draw actor { drawsGuide: b }

toggle :: GameInteractor -> Effect Unit
toggle gi = do
  b <- Ref.read isActive
  setActive (not b) gi

attach :: GameInteractor -> Effect Unit
attach gi = do
  listener <- eventListener \e -> do
    e' <- KeyboardEvent.fromEvent e # throwOnNothing "Not keyboard event"
    when (KeyboardEvent.key e' == "F2") do
      toggle gi

  window <- HTML.window
  addEventListener (EventType "keydown") listener false (Window.toEventTarget window)
