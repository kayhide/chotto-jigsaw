module App.View.Agent.GamesAgent where

import AppPrelude

import App.Api.Games (createGame, destroyGame, listGames, showGame, updateGame)
import App.Context (Context)
import App.Data (atOf)
import App.Data.Game (CreatingGame, Game, GameId, UpdatingGame)
import App.Data.Picture (PictureId)
import App.Env (Env)
import Control.Monad.Reader (runReaderT)
import Data.Array as Array
import Data.Lens (_Just)
import Data.Set (Set)
import Data.Set as Set
import React.Basic.Hooks (Render, useState)
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)


type GamesAgent =
  { items :: Array Game
  , item :: Maybe Game
  , lookup :: GameId -> Maybe Game
  , isLoading :: Boolean
  , isSubmitting :: Boolean
  , load :: Effect Unit
  , loadOne :: GameId -> Effect Unit
  , create :: PictureId /\ CreatingGame -> Effect Unit
  , update :: GameId /\ UpdatingGame -> Effect Unit
  , destroy :: GameId -> Effect Unit
  }

type Page = Int

useGamesAgent :: Env -> Context -> Render _ _ GamesAgent
useGamesAgent env context = React.do
  items /\ setItems <- useState ([] :: Array Game)
  item /\ setItem <- useState (Nothing :: Maybe Game)
  loadingItems /\ setLoadingItems <- useState (Set.empty :: Set GameId)
  loadingPage /\ setLoadingPage <- useState (Nothing :: Maybe Page)
  creating /\ setCreating <- useState (Nothing :: Maybe (PictureId /\ CreatingGame))
  updating /\ setUpdating <- useState (Nothing :: Maybe (GameId /\ UpdatingGame))
  destroying /\ setDestroying <- useState (Nothing :: Maybe GameId)

  useAff loadingPage do
    loadingPage # traverse_ \ page -> do
      xs <- env # runReaderT do
        listGames
      liftEffect $ do
        xs # traverse_ \ xs' -> setItems $ const xs'
        setLoadingPage $ const Nothing

  useAff loadingItems do
    loadingItems # traverse_ \ id' -> do
      x <- env # runReaderT do
        showGame id'
      liftEffect $ do
        setItems $ atOf id' .~ x
        setItem $ const x
    liftEffect $ do
      setLoadingItems $ const Set.empty

  useAff creating do
    creating # traverse_ \ (pictureId /\ creating') -> do
      x <- env # runReaderT do
        createGame pictureId creating'
      liftEffect do
        x # traverse_ \ x' -> do
          setItems $ \ xs -> Array.snoc xs x'
        setCreating $ const Nothing

  useAff updating do
    updating # traverse_ \ (id' /\ updating') -> do
      x <- env # runReaderT do
        updateGame id' updating'
      liftEffect do
        x # traverse_ \ x' ->
          setItems $ atOf id' <<< _Just .~ x'
        setUpdating $ const Nothing

  useAff destroying do
    destroying # traverse_ \ id' -> do
      x <- env # runReaderT do
        destroyGame id'
      liftEffect do
        x # traverse_ \ _ ->
          setItems $ atOf id' .~ Nothing
        setDestroying $ const Nothing

  pure
    { items
    , item
    , lookup: \ id' -> items ^? (atOf id' <<< _Just)
    , isLoading: isJust loadingPage || not (Set.isEmpty loadingItems)
    , isSubmitting: isJust creating || isJust updating || isJust destroying
    , load: setLoadingPage $ const $ Just 0
    , loadOne: \ id' -> setLoadingItems $ Set.insert id'
    , create: setCreating <<< const <<< Just
    , update: setUpdating <<< const <<< Just
    , destroy: setDestroying <<< const <<< Just
    }
