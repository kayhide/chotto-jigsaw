module App.Channel.GameChannel where

import AppPrelude

import App.Command.Command (Command)
import App.Command.CommandManager as CommandManager
import Data.Argonaut (Json, decodeJson, encodeJson)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Class (liftEffect)


foreign import data Consumer :: Type
foreign import data Subscription :: Type

foreign import createConsumer :: Effect Consumer

foreign import _createSubscription :: forall funcs. Identifier -> funcs -> Consumer -> EffectFnAff Subscription

createSubscription :: forall funcs. Identifier -> funcs -> Consumer -> Aff Subscription
createSubscription identifier funcs consumer =
  fromEffectFnAff $ _createSubscription identifier funcs consumer


foreign import _requestContent :: Subscription -> EffectFnAff Json

requestContent :: Subscription -> Aff Json
requestContent sub =
  fromEffectFnAff $ _requestContent sub


foreign import _requestUpdate :: Subscription -> EffectFnAff Unit

requestUpdate :: Subscription -> Aff Unit
requestUpdate sub =
  fromEffectFnAff $ _requestUpdate sub

foreign import perform :: Subscription -> String -> Json -> Effect Unit


type Identifier =
  { channel :: String
  , game_id :: Int
  }

type Data =
  { action :: String
  , commands :: Json
  }

subscribe :: Int -> Aff Subscription
subscribe gameId =
  liftEffect createConsumer
  >>= createSubscription
      { channel: "GameChannel", game_id: gameId }
      {}

reportProgress :: Subscription -> Number -> Effect Unit
reportProgress sub progress =
  perform sub "report_progress" $ encodeJson { progress }
