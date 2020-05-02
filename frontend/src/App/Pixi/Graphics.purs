module App.Pixi.Graphics where

import AppPrelude

import App.Pixi.Point (Point)
import App.Pixi.Rectangle (Rectangle)
import App.Pixi.Texture (Texture)
import App.Pixi.Type (Graphics)


foreign import create :: Effect Graphics

foreign import clear :: Graphics -> Effect Unit
foreign import setLineStyle :: forall style. style -> Graphics -> Effect Unit
foreign import closePath :: Graphics -> Effect Unit
foreign import beginFill :: Color -> Number -> Graphics -> Effect Unit
foreign import beginTextureFill :: Texture -> Graphics -> Effect Unit
foreign import endFill :: Graphics -> Effect Unit
foreign import moveTo :: Point -> Graphics -> Effect Unit
foreign import lineTo :: Point -> Graphics -> Effect Unit
foreign import bezierCurveTo :: Point -> Point -> Point -> Graphics -> Effect Unit
foreign import drawRect :: Rectangle -> Graphics -> Effect Unit
foreign import drawCircle :: Point -> Number -> Graphics -> Effect Unit


newtype Color = Color Int

rgb :: Int -> Int -> Int -> Color
rgb r g b =
  Color $ 256 * 256 * (r `mod` 256) + 256 * (g `mod` 256) + (b `mod` 256)
