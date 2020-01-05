module App.EaselJS.Container where

import AppPrelude

import App.EaselJS.Type (Container, DisplayObject, Shape)


foreign import create :: Effect Container
foreign import addChild :: DisplayObject -> Container -> Effect Unit
foreign import addShape :: Shape -> Container -> Effect Unit
foreign import addContainer :: Container -> Container -> Effect Unit
foreign import getShapes :: Container -> Effect (Array Shape)

foreign import toDisplayObject :: Container -> DisplayObject
