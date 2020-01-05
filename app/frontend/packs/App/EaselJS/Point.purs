module App.EaselJS.Point where

import AppPrelude

import Math (pow)
import Math as Math

type Point = { x :: Number, y :: Number }

foreign import create :: Number -> Number -> Point

zero :: Point
zero = create 0.0 0.0

isZero :: Point -> Boolean
isZero { x, y } = x == 0.0 && y == 0.0

add :: Point -> Point -> Point
add pt1 pt0 = create (pt1.x + pt0.x) (pt1.y + pt0.y)

subtract :: Point -> Point -> Point
subtract pt1 pt0 = create (pt1.x - pt0.x) (pt1.y - pt0.y)

scale :: Number -> Point -> Point
scale d pt = create (pt.x * d) (pt.y * d)

distance :: Point -> Point -> Number
distance pt1 pt0 =
  Math.sqrt $ (pow (pt1.x - pt0.x) 2.0) + (pow (pt1.y - pt0.y) 2.0)
