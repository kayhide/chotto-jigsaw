module App.Data.Puzzle where

import AppPrelude

import App.Data.Piece (Piece)
import App.Data.Piece as Piece
import App.Pixi.Rectangle (Rectangle)
import App.Pixi.Rectangle as Rectangle
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson, (.:))
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
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
  , difficulty :: Difficulty
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



data Difficulty
  = Trivial
  | Easy
  | Normal
  | Hard
  | Extreme
  | Lunatic

derive instance genericDifficulty :: Generic Difficulty _
derive instance eqDifficulty :: Eq Difficulty
derive instance ordDifficulty :: Ord Difficulty

instance showDifficulty :: Show Difficulty where
  show = genericShow

instance encodeJsonDifficulty :: EncodeJson Difficulty where
  encodeJson x = encodeJson case x of
    Trivial -> "trivial"
    Easy -> "easy"
    Normal -> "normal"
    Hard -> "hard"
    Extreme -> "extreme"
    Lunatic -> "lunatic"

instance decodeJsonDifficulty :: DecodeJson Difficulty where
  decodeJson json = decodeJson json >>= case _ of
    "trivial" -> pure Trivial
    "easy" -> pure Easy
    "normal" -> pure Normal
    "hard" -> pure Hard
    "extreme" -> pure Extreme
    "lunatic" -> pure Lunatic
    x -> Left $ "Could not decode Difficulty from " <> x
