module App.EaselJS.Shape where

import AppPrelude

import App.EaselJS.Type (Shape, DisplayObject)

foreign import create :: Effect Shape

foreign import toDisplayObject :: Shape -> DisplayObject
