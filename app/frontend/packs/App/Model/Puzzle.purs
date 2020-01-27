module App.Model.Puzzle where

import AppPrelude

import App.Pixi.Rectangle (Rectangle)
import App.Pixi.Rectangle as Rectangle
import App.Model.Piece (Piece)
import App.Model.Piece as Piece
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, (.:))
import Data.Array as Array
import Data.Newtype (class Newtype)


newtype PuzzleId = PuzzleId Int

derive instance newtypePuzzleId :: Newtype PuzzleId _
derive newtype instance eqPuzzleId :: Eq PuzzleId
derive newtype instance showPuzzleId :: Show PuzzleId
derive newtype instance encodeJsonPuzzleId :: EncodeJson PuzzleId
derive newtype instance decodeJsonPuzzleId :: DecodeJson PuzzleId


newtype Puzzle =
  Puzzle
  { id :: PuzzleId
  , pieces :: Array Piece
  , piecesCount :: Number
  , linearMeasure :: Number
  , difficulty :: String
  , boundary :: Rectangle
  }

derive instance newtypePuzzle :: Newtype Puzzle _

instance decodeJsonPuzzle :: DecodeJson Puzzle where
  decodeJson json = do
    obj <- decodeJson json
    id <- decodeJson =<< obj .: "id"
    pieces <- traverse Piece.decode =<< obj .: "pieces"
    piecesCount <- decodeJson =<< obj .: "pieces_count"
    linearMeasure <- obj .: "linear_measure"
    difficulty <- decodeJson =<< obj .: "difficulty"
    let boundary =
          Array.foldr Rectangle.addPoint Rectangle.empty
          <<< Array.catMaybes <<< Array.concat <<< Array.concat $ _.loops <$> pieces
    pure $ Puzzle { id, pieces, piecesCount, linearMeasure, difficulty, boundary }
