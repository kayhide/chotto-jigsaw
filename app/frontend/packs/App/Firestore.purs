module App.Firestore where

import AppPrelude

import App.Command.Command (Command)
import Data.Argonaut (Json, decodeJson, encodeJson)


foreign import data Firestore :: Type

foreign import connect :: Effect Firestore

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
