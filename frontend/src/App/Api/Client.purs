module App.Api.Client where

import AppPrelude

import Affjax as AX
import Affjax.RequestBody as RequestBody
import Affjax.ResponseFormat as ResponseFormat
import App.Data.Game (Game, GameId(..))
import App.Data.Puzzle (Puzzle, PuzzleId(..))
import Data.Argonaut (class EncodeJson, decodeJson, encodeJson, (:=), (~>))
import Data.Bifunctor (lmap)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Effect (Effect)
import Effect.Aff (Aff)


foreign import _lookupAuthenticityToken :: Effect (Nullable { name :: String, value :: String })

lookupAuthenticityToken :: Effect (Maybe { name :: String, value :: String })
lookupAuthenticityToken = Nullable.toMaybe <$> _lookupAuthenticityToken


getGame :: GameId -> Aff Game
getGame (GameId id) = do
  res <- AX.get ResponseFormat.json $ "/api/games/" <> show id
  res' <- lmap AX.printError res # throwOnLeft
  decodeJson res'.body # throwOnLeft

updateGame
  :: forall attrs.
     EncodeJson attrs =>
     GameId -> attrs -> Aff Unit
updateGame (GameId id) attrs = do
  token <- liftEffect $ lookupAuthenticityToken >>= throwOnNothing "Authenticity token is missing"
  let json = token.name := token.value ~> encodeJson { game: attrs }
  res <- AX.patch_ ("/api/games/" <> show id) (RequestBody.json json)
  lmap AX.printError res # throwOnLeft


getPuzzle :: PuzzleId -> Aff Puzzle
getPuzzle (PuzzleId id) = do
  res <- AX.get ResponseFormat.json $ "/api/puzzles/" <> show id
  res' <- lmap AX.printError res # throwOnLeft
  decodeJson res'.body # throwOnLeft
