module App.Api.Pictures where

import AppPrelude

import App.Api.Endpoint as Endpoint
import App.Api.Request (BaseUrl, RequestMethod(..), makeAuthRequest)
import App.Data.Picture (Picture, PictureId, CreatingPicture)
import Data.Argonaut (decodeJson, encodeJson)


listPictures ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  m (Maybe (Array Picture))
listPictures = do
  res <- makeAuthRequest { endpoint: Endpoint.Pictures, method: Get }
  pure $ res >>= (decodeJson >>> hush)

createPicture ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  CreatingPicture -> m (Maybe Unit)
createPicture creating = do
  let payload = Just $ encodeJson creating
  res <- makeAuthRequest { endpoint: Endpoint.Pictures, method: Post payload }
  pure $ res >>= (decodeJson >>> hush)

destroyPicture ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  PictureId -> m (Maybe Unit)
destroyPicture id' = do
  res <- makeAuthRequest { endpoint: Endpoint.Picture id', method: Delete }
  pure $ res >>= (decodeJson >>> hush)
