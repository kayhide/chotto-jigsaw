module App.Data.Game where

import AppPrelude

import Data.Argonaut (class DecodeJson, class EncodeJson)
import Data.Newtype (class Newtype)


newtype GameId = GameId Int

derive instance newtypeGameId :: Newtype GameId _
derive newtype instance eqGameId :: Eq GameId
derive newtype instance showGameId :: Show GameId
derive newtype instance encodeJsonGameId :: EncodeJson GameId
derive newtype instance decodeJsonGameId :: DecodeJson GameId


newtype Game =
  Game
  { id :: GameId
  , is_ready :: Boolean
  , progress :: Number
  }

derive instance newtypeGame :: Newtype Game _
derive newtype instance encodeJsonGame :: EncodeJson Game
derive newtype instance decodeJsonGame :: DecodeJson Game
