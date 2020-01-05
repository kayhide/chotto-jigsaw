module App.EaselJS.Matrix2D where

import AppPrelude

import App.EaselJS.Point (Point)


type Matrix2D =
  { a :: Number
  , b :: Number
  , c :: Number
  , d :: Number
  , tx :: Number
  , ty :: Number
  }

type Decomposition =
  { x :: Number
  , y :: Number
  , scaleX :: Number
  , scaleY :: Number
  , rotation :: Number
  }

foreign import create :: Matrix2D
foreign import from :: forall attrs. attrs -> Matrix2D

foreign import toString :: Matrix2D -> String
foreign import translate :: Number -> Number -> Matrix2D -> Matrix2D
foreign import rotate :: Number -> Matrix2D -> Matrix2D
foreign import scale :: Number -> Matrix2D -> Matrix2D
foreign import invert :: Matrix2D -> Matrix2D
foreign import decompose :: Matrix2D -> Decomposition
foreign import appendMatrix :: Matrix2D -> Matrix2D -> Matrix2D
foreign import appendTransform :: Decomposition -> Matrix2D -> Matrix2D
foreign import apply :: Point -> Matrix2D -> Point
