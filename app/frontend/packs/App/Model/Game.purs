module App.Model.Game where

import Data.Argonaut (class DecodeJson, class EncodeJson)
import Data.Newtype (class Newtype)


newtype GameId = GameId Int

derive instance newtypeGameId :: Newtype GameId _
derive newtype instance encodeJsonGameId :: EncodeJson GameId
derive newtype instance decodeJsonGameId :: DecodeJson GameId


newtype Game =
  Game
  { id :: GameId
  , progress :: Number
  }

derive instance newtypeGame :: Newtype Game _
derive newtype instance encodeJsonGame :: EncodeJson Game
derive newtype instance decodeJsonGame :: DecodeJson Game
