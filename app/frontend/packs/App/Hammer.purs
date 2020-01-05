module App.Hammer where

import AppPrelude

import Web.DOM (Element)
import Web.Event.Event (Event)
import Web.Event.EventTarget (EventTarget)

foreign import data Manager :: Type
foreign import data Recognizer :: Type

foreign import create :: EventTarget -> Effect Manager
foreign import get :: String -> Manager -> Effect Recognizer
foreign import set :: forall options. options -> Recognizer -> Effect Unit
foreign import recognizeWith :: Recognizer -> Recognizer -> Effect Unit

foreign import addHammerEventListener :: String -> Manager -> (HammerEvent -> Effect Unit) -> Effect Unit


type Point =
  { x :: Number
  , y :: Number
  }

type HammerEvent =
  { type :: String
  , deltaX :: Number
  , deltaY :: Number
  , deltaTime :: Number
  , distance :: Number
  , angle :: Number
  , velocityX :: Number
  , velocityY :: Number
  , velocity :: Number
  , direction :: Int
  , offsetDirection :: Int
  , scale :: Number
  , rotation :: Number
  , center :: Point
  , srcEvent :: Event
  , target :: Element
  , pointerType :: String
  , eventType :: Int
  , isFirst :: Boolean
  , isFinal :: Boolean
  }


direction_none :: Int
direction_none = 1

direction_left :: Int
direction_left = 2

direction_right :: Int
direction_right = 4

direction_up :: Int
direction_up = 8

direction_down :: Int
direction_down = 16

direction_horizontal :: Int
direction_horizontal = 6

direction_vertical :: Int
direction_vertical = 24

direction_all :: Int
direction_all = 30
