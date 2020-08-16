module App.Api.Pieces where

import AppPrelude

import App.Api.Endpoint as Endpoint
import App.Api.Request (BaseUrl, RequestMethod(..), makeAuthRequest)
import App.Data.Piece (Piece)
import App.Data.Puzzle (PuzzleId)
import Data.Argonaut (decodeJson)


listPieces ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  PuzzleId -> m (Maybe (Array Piece))
listPieces puzzleId = do
  res <- makeAuthRequest { endpoint: Endpoint.PuzzlePieces puzzleId, method: Get }
  pure $ res >>= (decodeJson >>> hush)
