module App.Pixi.Container where

import AppPrelude

import App.Pixi.Type (Container, DisplayObject, Graphics)


foreign import create :: Effect Container
foreign import addChild :: DisplayObject -> Container -> Effect Unit
foreign import addShape :: Graphics -> Container -> Effect Unit
foreign import addContainer :: Container -> Container -> Effect Unit
foreign import getShapes :: Container -> Effect (Array Graphics)

foreign import toDisplayObject :: Container -> DisplayObject
