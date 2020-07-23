module App.View.Agent.PicturesAgent where

import AppPrelude

import App.Api.Pictures (createPicture, destroyPicture, listPictures)
import App.Context (Context)
import App.Data (atOf)
import App.Data.Picture (CreatingPicture, Picture, PictureId)
import App.Env (Env)
import Control.Monad.Reader (runReaderT)
import Data.Array as Array
import Data.Lens (_Just)
import Data.Set (Set)
import Data.Set as Set
import React.Basic.Hooks (Render, useState)
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)


type PicturesAgent =
  { items :: Array Picture
  , item :: Maybe Picture
  , lookup :: PictureId -> Maybe Picture
  , isLoading :: Boolean
  , isSubmitting :: Boolean
  , load :: Effect Unit
  , loadOne :: PictureId -> Effect Unit
  , create :: CreatingPicture -> Effect Unit
  , destroy :: PictureId -> Effect Unit
  }

type Page = Int

usePicturesAgent :: Env -> Context -> Render _ _ PicturesAgent
usePicturesAgent env context = React.do
  items /\ setItems <- useState ([] :: Array Picture)
  item /\ setItem <- useState (Nothing :: Maybe Picture)
  loadingItems /\ setLoadingItems <- useState (Set.empty :: Set PictureId)
  loadingPage /\ setLoadingPage <- useState (Nothing :: Maybe Page)
  creating /\ setCreating <- useState (Nothing :: Maybe CreatingPicture)
  destroying /\ setDestroying <- useState (Nothing :: Maybe PictureId)

  useAff loadingPage do
    loadingPage # traverse_ \ page -> do
      xs <- env # runReaderT do
        listPictures
      liftEffect $ do
        xs # traverse_ \ xs' -> setItems $ const xs'
        setLoadingPage $ const Nothing

  -- useAff creating do
  --   creating # traverse_ \ creating' -> do
  --     x <- env # runReaderT do
  --       createPicture creating'
  --     liftEffect do
  --       x # traverse_ \ x' -> do
  --         setItems $ \ xs -> Array.snoc xs x'
  --       setCreating $ const Nothing

  useAff destroying do
    destroying # traverse_ \ id' -> do
      x <- env # runReaderT do
        destroyPicture id'
      liftEffect do
        x # traverse_ \ _ ->
          setItems $ atOf id' .~ Nothing
        setDestroying $ const Nothing

  pure
    { items
    , item
    , lookup: \ id' -> items ^? (atOf id' <<< _Just)
    , isLoading: isJust loadingPage || not (Set.isEmpty loadingItems)
    , isSubmitting: isJust creating || isJust destroying
    , load: setLoadingPage $ const $ Just 0
    , loadOne: \ id' -> setLoadingItems $ Set.insert id'
    , create: setCreating <<< const <<< Just
    , destroy: setDestroying <<< const <<< Just
    }
