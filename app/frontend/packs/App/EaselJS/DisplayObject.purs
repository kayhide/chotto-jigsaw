module App.EaselJS.DisplayObject where

import AppPrelude

import App.EaselJS.Matrix2D (Matrix2D)
import App.EaselJS.Point (Point)
import App.EaselJS.Rectangle (Rectangle)
import App.EaselJS.Type (Container, DisplayObject, Stage)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Web.DOM (Element)


foreign import update :: forall attrs. attrs -> DisplayObject -> Effect Unit
foreign import getMatrix :: DisplayObject -> Matrix2D
foreign import _getParent :: DisplayObject -> Nullable Container
foreign import _getStage :: DisplayObject -> Nullable Stage

foreign import setHitArea :: DisplayObject -> DisplayObject -> Effect Unit
foreign import hitTest :: Point -> DisplayObject -> Effect Boolean

type Shadow =
  { color :: String
  , offsetX :: Number
  , offsetY :: Number
  , blur :: Number
  }
foreign import setShadow :: Shadow -> DisplayObject -> Effect Unit

foreign import cache :: Rectangle -> Number -> DisplayObject -> Effect Unit
foreign import localToGlobal :: Point -> DisplayObject -> Effect Point
foreign import globalToLocal :: Point -> DisplayObject -> Effect Point
foreign import getCanvas :: DisplayObject -> Effect Element


getParent :: DisplayObject -> Maybe Container
getParent = Nullable.toMaybe <<< _getParent

getStage :: DisplayObject -> Maybe Stage
getStage = Nullable.toMaybe <<< _getStage

copyTransform :: DisplayObject -> DisplayObject -> Effect Unit
copyTransform src dst = update src dst

foreign import clearTransform :: DisplayObject -> Effect Unit


toGlobalFrom :: DisplayObject -> Point -> Effect Point
toGlobalFrom obj pt = localToGlobal pt obj

fromGlobalTo :: DisplayObject -> Point -> Effect Point
fromGlobalTo obj pt = globalToLocal pt obj
