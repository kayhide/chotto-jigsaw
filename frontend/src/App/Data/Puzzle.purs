module App.Data.Puzzle where

import AppPrelude

import App.Data.DateTime (decodeDateTime, encodeDateTime)
import App.Pixi.Rectangle (Rectangle)
import App.Pixi.Rectangle as Rectangle
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)
import Data.DateTime (DateTime)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Newtype (class Newtype)
import Record as Record


newtype PuzzleId = PuzzleId Int

derive instance newtypePuzzleId :: Newtype PuzzleId _
derive newtype instance eqPuzzleId :: Eq PuzzleId
derive newtype instance showPuzzleId :: Show PuzzleId
derive newtype instance encodeJsonPuzzleId :: EncodeJson PuzzleId
derive newtype instance decodeJsonPuzzleId :: DecodeJson PuzzleId


newtype Puzzle =
  Puzzle
  { id :: PuzzleId
  , pieces_count :: Int
  , linear_measure :: Number
  , difficulty :: Difficulty
  , boundary :: Rectangle
  , picture_url :: String
  , picture_thumbnail_url :: String
  , created_at :: DateTime
  , updated_at :: DateTime
  }

derive instance newtypePuzzle :: Newtype Puzzle _
derive newtype instance eqPuzzle :: Eq Puzzle
derive newtype instance showPuzzle :: Show Puzzle

instance encodeJsonPuzzle :: EncodeJson Puzzle where
  encodeJson x =
    encodeJson
    <<< Record.modify (SProxy :: _ "created_at") encodeDateTime
    <<< Record.modify (SProxy :: _ "updated_at") encodeDateTime
    $ unwrap x

instance decodeJsonPuzzle :: DecodeJson Puzzle where
  decodeJson json = do
    obj <- decodeJson json
    boundary <- Rectangle.decode obj.boundary
    createdAt <- decodeDateTime obj.created_at
    updatedAt <- decodeDateTime obj.updated_at
    pure $ wrap
      <<< Record.modify (SProxy :: _ "created_at") (const createdAt)
      <<< Record.modify (SProxy :: _ "updated_at") (const updatedAt)
      <<< Record.modify (SProxy :: _ "boundary") (const boundary)
      $ obj



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
