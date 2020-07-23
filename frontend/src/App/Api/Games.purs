module App.Api.Games where

import AppPrelude

import App.Api.Endpoint as Endpoint
import App.Api.Request (BaseUrl, RequestMethod(..), makeAuthRequest)
import App.Data.Game (Game, GameId, CreatingGame, UpdatingGame)
import App.Data.Picture (PictureId)
import Data.Argonaut (decodeJson, encodeJson)


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
  GameId -> m (Maybe Game)
showGame id' = do
  res <- makeAuthRequest { endpoint: Endpoint.Game id', method: Get }
  pure $ res >>= (decodeJson >>> hush)

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
