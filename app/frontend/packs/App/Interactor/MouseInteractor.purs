module App.Interactor.MouseInteractor where

import AppPrelude

import App.EaselJS.Point (Point)
import App.EaselJS.Point as Point
import App.Interactor.GameInteractor (GameInteractor)
import App.Interactor.GameInteractor as GameInteractor
import App.Logger as Logger
import Data.Int as Int
import Web.DOM.Element as Element
import Web.Event.Event (EventType(..))
import Web.Event.Event as Event
import Web.Event.EventTarget (EventTarget, addEventListener, eventListener)
import Web.UIEvent.MouseEvent (MouseEvent)
import Web.UIEvent.MouseEvent as MouseEvent
import Web.UIEvent.WheelEvent (WheelEvent)
import Web.UIEvent.WheelEvent as WheelEvent

attach :: GameInteractor -> Effect Unit
attach gi = do
  Logger.info "attached: MouseInteractor"

  let target = Element.toEventTarget gi.baseStage.canvas

  addMouseEventListener "mousedown" target $ onMouseDown gi
  addMouseEventListener "mousemove" target $ onMouseMove gi
  addMouseEventListener "mouseup" target $ onMouseUp gi
  addWheelEventListener "wheel" target $ onWheel gi

onMouseDown :: GameInteractor -> MouseEvent -> Effect Unit
onMouseDown gi e =
  GameInteractor.resume (clientPoint e) gi

onMouseMove :: GameInteractor -> MouseEvent -> Effect Unit
onMouseMove gi e =
  GameInteractor.movePointerTo (clientPoint e) gi

onMouseUp :: GameInteractor -> MouseEvent -> Effect Unit
onMouseUp gi e = do
  GameInteractor.attempt gi
  GameInteractor.pause gi

onWheel :: GameInteractor -> WheelEvent -> Effect Unit
onWheel gi e = do
  GameInteractor.resume (clientPoint $ WheelEvent.toMouseEvent e) gi
  GameInteractor.spinPointer (negate $ WheelEvent.deltaY e) gi
  GameInteractor.zoomPointer (bool identity recip (0.0 < WheelEvent.deltaY e) 1.02) gi
  GameInteractor.pause gi



clientPoint :: MouseEvent -> Point
clientPoint e =
  Point.create
  (Int.toNumber $ MouseEvent.clientX e)
  (Int.toNumber $ MouseEvent.clientY e)

addMouseEventListener :: String -> EventTarget -> (MouseEvent -> Effect Unit) -> Effect Unit
addMouseEventListener name target listener = do
  listener' <- eventListener \e -> do
    Event.preventDefault e
    e' <- MouseEvent.fromEvent e # throwOnNothing "Not mouse event"
    listener e'
  addEventListener (EventType name) listener' false target

addWheelEventListener :: String -> EventTarget -> (WheelEvent -> Effect Unit) -> Effect Unit
addWheelEventListener name target listener = do
  listener' <- eventListener \e -> do
    Event.preventDefault e
    e' <- WheelEvent.fromEvent e # throwOnNothing "Not wheel event"
    listener e'
  addEventListener (EventType name) listener' false target
