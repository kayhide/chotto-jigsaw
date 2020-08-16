module App.View.Agent.PiecesAgent where

import AppPrelude

import App.Api.Pieces (listPieces)
import App.Context (Context)
import App.Data.Piece (Piece)
import App.Data.Puzzle (PuzzleId)
import App.Env (Env)
import Control.Monad.Reader (runReaderT)
import React.Basic.Hooks (Render, useState)
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)


type PiecesAgent =
  { items :: Array Piece
  , isLoading :: Boolean
  , load :: PuzzleId -> Effect Unit
  }

type Page = Int

usePiecesAgent :: Env -> Context -> Render _ _ PiecesAgent
usePiecesAgent env context = React.do
  items /\ setItems <- useState ([] :: Array Piece)
  loadingPage /\ setLoadingPage <- useState (Nothing :: Maybe PuzzleId)

  useAff loadingPage do
    loadingPage # traverse_ \ puzzleId -> do
      xs <- env # runReaderT do
        listPieces puzzleId
      liftEffect $ do
        xs # traverse_ \ xs' -> setItems $ const xs'
        setLoadingPage $ const Nothing

  pure
    { items
    , isLoading: isJust loadingPage
    , load: setLoadingPage <<< const <<< Just
    }
