module App.Pixi.Rectangle where

import AppPrelude

import App.Pixi.Point (Point)
import App.Pixi.Point as Point
import Data.Argonaut (Json, decodeJson, (.:))
import Data.Array as Array

type Rectangle =
  { x :: Number
  , y :: Number
  , width :: Number
  , height :: Number
  , empty :: Boolean
  }

foreign import create :: Number -> Number -> Number -> Number -> Rectangle
foreign import empty :: Rectangle

decode :: Json -> Either String Rectangle
decode json = do
  obj <- decodeJson json
  x <- obj .: "x"
  y <- obj .: "y"
  width <- obj .: "width"
  height <- obj .: "height"
  pure { x, y, width, height, empty: false }

topLeft :: Rectangle -> Point
topLeft rect = Point.create rect.x rect.y

topRight :: Rectangle -> Point
topRight rect = Point.create (rect.x + rect.width) rect.y

bottomLeft :: Rectangle -> Point
bottomLeft rect = Point.create rect.x (rect.y + rect.height)

bottomRight :: Rectangle -> Point
bottomRight rect = Point.create (rect.x + rect.width) (rect.y + rect.height)

center :: Rectangle -> Point
center rect = Point.create (rect.x + rect.width / 2.0) (rect.y + rect.height / 2.0)

cornerPoints :: Rectangle -> Array Point
cornerPoints rect = map (_ $ rect) [ topLeft, topRight, bottomLeft, bottomRight ]

addPoint :: Point -> Rectangle -> Rectangle
addPoint pt rect =
  bool (create x y width height) (create pt.x pt.y 0.0 0.0) rect.empty
  where
    x /\ width = case (pt.x < rect.x) /\ (rect.x + rect.width < pt.x) of
      true /\ _ -> pt.x /\ (rect.x + rect.width - pt.x)
      _ /\ true -> rect.x /\ (pt.x - rect.x)
      _ -> rect.x /\ rect.width

    y /\ height = case (pt.y < rect.y) /\ (rect.y + rect.height < pt.y) of
      true /\ _ -> pt.y /\ (rect.y + rect.height - pt.y)
      _ /\ true -> rect.y /\ (pt.y - rect.y)
      _ -> rect.y /\ rect.height

addRectangle :: Rectangle -> Rectangle -> Rectangle
addRectangle rect0 rect1 =
  Array.foldr addPoint rect0 $ cornerPoints rect1

fromPoints :: Array Point -> Rectangle
fromPoints = Array.foldr addPoint empty

inflate :: Number -> Rectangle -> Rectangle
inflate offset rect =
  create (rect.x - offset) (rect.y - offset) (rect.width + offset * 2.0) (rect.height + offset * 2.0)
