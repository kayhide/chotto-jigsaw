module App.Model.Puzzle where

import AppPrelude

import App.EaselJS.Rectangle (Rectangle)
import App.EaselJS.Rectangle as Rectangle
import App.Model.Piece (Piece)
import App.Model.Piece as Piece
import Data.Argonaut (Json, decodeJson, jsonParser, (.:))
import Data.Array as Array

type Puzzle =
  { pieces :: Array Piece
  , linearMeasure :: Number
  , boundary :: Rectangle
  }

parse :: String -> Effect Puzzle
parse str =
  jsonParser str >>= decode # throwOnLeft

decode :: Json -> Either String Puzzle
decode json = do
  obj <- decodeJson json
  pieces <- traverse Piece.decode =<< obj .: "pieces"
  linearMeasure <- obj .: "linear_measure"
  let boundary =
        Array.foldr Rectangle.addPoint Rectangle.empty
        <<< Array.catMaybes <<< Array.concat <<< Array.concat $ _.loops <$> pieces
  pure { pieces, linearMeasure, boundary }
