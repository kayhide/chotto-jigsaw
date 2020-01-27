module App.Pixi.Texture where

import AppPrelude

import Web.DOM (Element)

foreign import data Texture :: Type

foreign import fromElement :: Element -> Effect Texture
