module App.EaselJS.Graphics where

import AppPrelude

import App.EaselJS.Point (Point)
import App.EaselJS.Rectangle (Rectangle)

foreign import data Graphics :: Type

foreign import clear :: Graphics -> Effect Unit
foreign import setStrokeStyle :: Number -> Graphics -> Effect Unit
foreign import beginStroke :: String -> Graphics -> Effect Unit
foreign import endStroke :: Graphics -> Effect Unit
foreign import beginFill :: String -> Graphics -> Effect Unit
foreign import beginBitmapFill :: forall img. img -> Graphics -> Effect Unit
foreign import endFill :: Graphics -> Effect Unit
foreign import moveTo :: Point -> Graphics -> Effect Unit
foreign import lineTo :: Point -> Graphics -> Effect Unit
foreign import bezierCurveTo :: Point -> Point -> Point -> Graphics -> Effect Unit
foreign import drawRect :: Rectangle -> Graphics -> Effect Unit
foreign import drawCircle :: Point -> Number -> Graphics -> Effect Unit
