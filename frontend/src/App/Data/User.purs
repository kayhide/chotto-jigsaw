module App.Data.User where

import AppPrelude

import App.Data.DateTime (decodeDateTime, encodeDateTime)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)
import Data.DateTime (DateTime)
import Data.Newtype (class Newtype, wrap)
import Record as Record


newtype UserId = UserId Int

derive instance newtypeUserId :: Newtype UserId _
derive newtype instance eqUserId :: Eq UserId
derive newtype instance ordUserId :: Ord UserId
derive newtype instance showUserId :: Show UserId
derive newtype instance encodeJsonUserId :: EncodeJson UserId
derive newtype instance decodeJsonUserId :: DecodeJson UserId


newtype User =
  User
  { id :: UserId
  , email :: String
  , username :: String
  , created_at :: DateTime
  , updated_at :: DateTime
  }

derive instance newtypeUser :: Newtype User _
derive newtype instance eqUser :: Eq User
derive newtype instance showUser :: Show User

instance encodeJsonUser :: EncodeJson User where
  encodeJson x =
    encodeJson
    <<< Record.modify (SProxy :: _ "created_at") encodeDateTime
    <<< Record.modify (SProxy :: _ "updated_at") encodeDateTime
    $ unwrap x

instance decodeJsonUser :: DecodeJson User where
  decodeJson json = do
    obj <- decodeJson json
    createdAt <- decodeDateTime obj.created_at
    updatedAt <- decodeDateTime obj.updated_at
    pure $ wrap
      <<< Record.modify (SProxy :: _ "created_at") (const createdAt)
      <<< Record.modify (SProxy :: _ "updated_at") (const updatedAt)
      $ obj
