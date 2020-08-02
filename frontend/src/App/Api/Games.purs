module App.Api.Games where

import AppPrelude

import Affjax.ResponseHeader as ResponseHeader
import App.Api.Endpoint as Endpoint
import App.Api.Request (BaseUrl, RequestMethod(..), makeAuthRequest, makeAuthRequest')
import App.Data.Game (Game, GameId, CreatingGame, UpdatingGame)
import App.Data.Picture (PictureId)
import App.Firestore (FirebaseToken)
import Data.Argonaut (decodeJson, encodeJson)
import Data.Array as Array


listGames ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  m (Maybe (Array Game))
listGames = do
  res <- makeAuthRequest { endpoint: Endpoint.Games, method: Get }
  pure $ res >>= (decodeJson >>> hush)

showGame ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  GameId -> m (Maybe (Game /\ FirebaseToken))
showGame id' = do
  res <- makeAuthRequest' { endpoint: Endpoint.Game id', method: Get }
  let
    game = res >>= (_.body >>> decodeJson >>> hush)
    token = do
      h <- res >>= (_.headers >>> Array.find ((_ == "firebase-token") <<< ResponseHeader.name))
      pure $ wrap $ ResponseHeader.value h
  pure $ (/\) <$> game <*> token


createGame ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  PictureId -> CreatingGame -> m (Maybe Game)
createGame pictureId creating = do
  let payload = Just $ encodeJson creating
  res <-
    makeAuthRequest
    { endpoint: Endpoint.PictureGames pictureId
    , method: Post payload
    }
  pure $ res >>= (decodeJson >>> hush)

updateGame ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  GameId -> UpdatingGame -> m (Maybe Game)
updateGame id' updating = do
  let payload = Just $ encodeJson updating
  res <- makeAuthRequest { endpoint: Endpoint.Game id', method: Put payload }
  pure $ res >>= (decodeJson >>> hush)

destroyGame ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  GameId -> m (Maybe Unit)
destroyGame id' = do
  res <- makeAuthRequest { endpoint: Endpoint.Game id', method: Delete }
  pure $ const unit <$> res
