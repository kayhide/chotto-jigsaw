module App.Pixi.Matrix where

import AppPrelude

import App.Pixi.Point (Point)


type Matrix =
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

foreign import create :: Matrix
foreign import from :: forall attrs. attrs -> Matrix

foreign import toString :: Matrix -> String
foreign import translate :: Number -> Number -> Matrix -> Matrix
foreign import rotate :: Number -> Matrix -> Matrix
foreign import scale :: Number -> Matrix -> Matrix
foreign import invert :: Matrix -> Matrix
foreign import decompose :: Matrix -> Decomposition
foreign import appendMatrix :: Matrix -> Matrix -> Matrix
foreign import appendTransform :: Decomposition -> Matrix -> Matrix
foreign import apply :: Point -> Matrix -> Point
