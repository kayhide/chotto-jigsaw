module App.EaselJS.Stage where

import AppPrelude

import App.EaselJS.Point (Point)
import App.EaselJS.Type (Container, Stage, DisplayObject)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Web.DOM (Element)


foreign import create :: Element -> Effect Stage
foreign import isInvalidated :: Stage -> Effect Boolean
foreign import invalidate :: Stage -> Effect Unit
foreign import update :: Stage -> Effect Unit
foreign import _getObjectUnderPoint :: Point -> Stage -> Effect (Nullable DisplayObject)

foreign import setNextStage :: Stage -> Stage -> Effect Unit

foreign import toDisplayObject :: Stage -> DisplayObject
foreign import toContainer :: Stage -> Container

getObjectUnderPoint :: Point -> Stage -> Effect (Maybe DisplayObject)
getObjectUnderPoint pt stage = Nullable.toMaybe <$> _getObjectUnderPoint pt stage
