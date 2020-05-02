module App.Pixi.Container where

import AppPrelude

import App.Pixi.Type (class DisplayObject, Container, Graphics)


foreign import create :: Effect Container
foreign import addChild :: forall obj. DisplayObject obj => obj -> Container -> Effect Unit
foreign import addShape :: Graphics -> Container -> Effect Unit
foreign import addContainer :: Container -> Container -> Effect Unit
foreign import getShapes :: Container -> Effect (Array Graphics)
