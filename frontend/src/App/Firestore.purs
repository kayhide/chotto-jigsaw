module App.Firestore where

import AppPrelude

import App.Command.Command (Command)
import App.Model.Game (GameId)
import Data.Argonaut (Json, decodeJson, encodeJson)
import Data.Newtype (class Newtype)


newtype FirebaseToken = FirebaseToken String

derive instance newtypeFirebaseToken :: Newtype FirebaseToken _
derive newtype instance eqFirebaseToken :: Eq FirebaseToken
derive newtype instance showFirebaseToken :: Show FirebaseToken


foreign import data Firestore :: Type

foreign import connect :: FirebaseToken -> GameId -> Effect Firestore
foreign import onSnapshotCommandAdd :: (Json -> Effect Unit) -> Firestore -> Effect Unit
foreign import addCommand :: Json -> Firestore -> Effect Unit


onCommandAdd :: (Command -> Effect Unit) -> Firestore -> Effect Unit
onCommandAdd listener firestore = do
  firestore # onSnapshotCommandAdd \json -> do
    cmd <- throwOnLeft $ decodeJson json
    listener cmd

postCommand :: Command -> Firestore -> Effect Unit
postCommand cmd firestore = do
  firestore # addCommand (encodeJson cmd)
