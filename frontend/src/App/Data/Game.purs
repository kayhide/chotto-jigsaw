module App.Data.Game where

import AppPrelude

import App.Data (class Updating)
import App.Data.DateTime (decodeDateTime, encodeDateTime)
import App.Data.Picture (PictureId)
import App.Data.Puzzle (Puzzle, PuzzleId)
import App.Data.Puzzle as Puzzle
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)
import Data.DateTime (DateTime)
import Data.Lens (lens)
import Data.Newtype (class Newtype, wrap)
import Record as Record


newtype GameId = GameId Int

derive instance newtypeGameId :: Newtype GameId _
derive newtype instance eqGameId :: Eq GameId
derive newtype instance ordGameId :: Ord GameId
derive newtype instance showGameId :: Show GameId
derive newtype instance encodeJsonGameId :: EncodeJson GameId
derive newtype instance decodeJsonGameId :: DecodeJson GameId


newtype Game =
  Game
  { id :: GameId
  , picture_id :: PictureId
  , puzzle_id :: PuzzleId
  , puzzle :: Puzzle
  , is_ready :: Boolean
  , progress :: Number
  , created_at :: DateTime
  , updated_at :: DateTime
  }

derive instance newtypeGame :: Newtype Game _
derive newtype instance eqGame :: Eq Game
derive newtype instance showGame :: Show Game

instance encodeJsonGame :: EncodeJson Game where
  encodeJson x =
    encodeJson
    <<< Record.modify (SProxy :: _ "created_at") encodeDateTime
    <<< Record.modify (SProxy :: _ "updated_at") encodeDateTime
    $ unwrap x

instance decodeJsonGame :: DecodeJson Game where
  decodeJson json = do
    obj <- decodeJson json
    createdAt <- decodeDateTime obj.created_at
    updatedAt <- decodeDateTime obj.updated_at
    pure $ wrap
      <<< Record.modify (SProxy :: _ "created_at") (const createdAt)
      <<< Record.modify (SProxy :: _ "updated_at") (const updatedAt)
      $ obj


newtype CreatingGame =
  CreatingGame
  { difficulty :: Puzzle.Difficulty
  }

derive instance newtypeCreatingGame :: Newtype CreatingGame _
derive newtype instance eqCreatingGame :: Eq CreatingGame
derive newtype instance showCreatingGame :: Show CreatingGame
derive newtype instance encodeJsonCreatingGame :: EncodeJson CreatingGame
derive newtype instance decodeJsonCreatingGame :: DecodeJson CreatingGame


newtype UpdatingGame =
  UpdatingGame
  { progress :: Number
  }

derive instance newtypeUpdatingGame :: Newtype UpdatingGame _
derive newtype instance eqUpdatingGame :: Eq UpdatingGame
derive newtype instance showUpdatingGame :: Show UpdatingGame
derive newtype instance encodeJsonUpdatingGame :: EncodeJson UpdatingGame
derive newtype instance decodeJsonUpdatingGame :: DecodeJson UpdatingGame

instance updatingGame :: Updating Game UpdatingGame where
  _Updating = lens get set
    where
      get :: Game -> UpdatingGame
      get (Game { progress }) =
        UpdatingGame { progress }

      set :: Game -> UpdatingGame -> Game
      set (Game game) (UpdatingGame { progress }) =
        Game $ game { progress = progress }
