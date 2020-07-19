module App.Data.Picture where

import AppPrelude

import App.Data.DateTime (decodeDateTime, encodeDateTime)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)
import Data.DateTime (DateTime)
import Data.Newtype (class Newtype, wrap)
import Record as Record


newtype PictureId = PictureId Int

derive instance newtypePictureId :: Newtype PictureId _
derive newtype instance eqPictureId :: Eq PictureId
derive newtype instance ordPictureId :: Ord PictureId
derive newtype instance showPictureId :: Show PictureId
derive newtype instance encodeJsonPictureId :: EncodeJson PictureId
derive newtype instance decodeJsonPictureId :: DecodeJson PictureId


newtype Picture =
  Picture
  { id :: PictureId
  , name :: String
  , created_at :: DateTime
  }

derive instance newtypePicture :: Newtype Picture _
derive newtype instance eqPicture :: Eq Picture
derive newtype instance showPicture :: Show Picture

instance encodeJsonPicture :: EncodeJson Picture where
  encodeJson x =
    encodeJson
    <<< Record.modify (SProxy :: _ "created_at") encodeDateTime
    $ unwrap x

instance decodeJsonPicture :: DecodeJson Picture where
  decodeJson json = do
    obj <- decodeJson json
    createdAt <- decodeDateTime obj.created_at
    pure $ wrap
      <<< Record.modify (SProxy :: _ "created_at") (const createdAt)
      $ obj
