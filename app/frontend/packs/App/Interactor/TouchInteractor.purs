module App.Interactor.TouchInteractor where

import AppPrelude

import App.Hammer (HammerEvent)
import App.Hammer as Hammer
import App.Interactor.GameInteractor (GameInteractor)
import App.Interactor.GameInteractor as GameInteractor
import App.Logger as Logger
import App.Pixi.Point (Point)
import App.Pixi.Point as Point
import Effect.Ref as Ref
import Web.Event.EventTarget (EventTarget)
import Web.HTML.HTMLCanvasElement as HTMLCanvasElement


attach :: GameInteractor -> Effect Unit
attach gi = do
  Logger.info "attached: TouchInteractor"

  let target = HTMLCanvasElement.toEventTarget (unwrap gi.baseStage).view

  hammer <- setupHammer target
  updateListener gi hammer

  Hammer.addHammerEventListener "tap" hammer \e -> do
    GameInteractor.resume (clientPoint e) gi
    GameInteractor.attempt gi
    updateListener gi hammer

  Hammer.addHammerEventListener "doubletap" hammer \e -> do
    GameInteractor.fit gi

  Hammer.addHammerEventListener "pinchstart" hammer \e -> do
    Logger.info e.type
    GameInteractor.setPointer (clientPoint e) gi

  Hammer.addHammerEventListener "pinchmove" hammer \e -> do
    GameInteractor.movePointerTo (clientPoint e) gi
    GameInteractor.zoomPointer e.scale gi
    GameInteractor.pegZoomer e.scale gi

  Hammer.addHammerEventListener "pinchend" hammer \e -> do
    Logger.info e.type
    GameInteractor.pegZoomer 1.0 gi

  Hammer.addHammerEventListener "panstart" hammer \e -> do
    Logger.info e.type
    GameInteractor.resume (clientPoint e) gi

  Hammer.addHammerEventListener "panmove" hammer \e -> do
    GameInteractor.movePointerTo (clientPoint e) gi

  Hammer.addHammerEventListener "panend" hammer \e -> do
    Logger.info e.type
    GameInteractor.attempt gi
    updateListener gi hammer

  Hammer.addHammerEventListener "rotatestart" hammer \e -> do
    Logger.info e.type
    GameInteractor.pegSpinner (e.rotation * 4.0) gi

  Hammer.addHammerEventListener "rotatemove" hammer \e -> do
    GameInteractor.spinPointer (e.rotation * 4.0) gi
    GameInteractor.pegSpinner (e.rotation * 4.0) gi

  Hammer.addHammerEventListener "rotateend" hammer \e -> do
    Logger.info e.type


updateListener :: GameInteractor -> Hammer.Manager -> Effect Unit
updateListener gi hammer = do
  piece <- _.piece <$> Ref.read gi.dragger
  case piece of
    Nothing -> do
      Hammer.set { enable: true } =<< Hammer.get "pinch" hammer
      Hammer.set { enable: false } =<< Hammer.get "rotate" hammer
    Just _ -> do
      Hammer.set { enable: false } =<< Hammer.get "pinch" hammer
      Hammer.set { enable: true } =<< Hammer.get "rotate" hammer


setupHammer :: EventTarget -> Effect Hammer.Manager
setupHammer target = do
  hammer <- Hammer.create target

  pan <- Hammer.get "pan" hammer
  pan # Hammer.set { enable: true, pointers: 1, direction: Hammer.direction_all }

  pinch <- Hammer.get "pinch" hammer
  pinch # Hammer.set { enable: true, threshold: 0.1 }
  pinch # Hammer.recognizeWith pan

  tap <- Hammer.get "tap" hammer
  tap # Hammer.set { enable: true, pointers: 1 }

  press <- Hammer.get "press" hammer
  press # Hammer.set { enable: true, pointers: 1 }

  doubletap <- Hammer.get "doubletap" hammer
  doubletap # Hammer.set { enable: true, pointers: 2 }

  rotate <- Hammer.get "rotate" hammer
  rotate # Hammer.set { enable: true, threshold: 15.0, pointers: 2 }

  pure hammer


clientPoint :: HammerEvent -> Point
clientPoint e = Point.create e.center.x e.center.y
