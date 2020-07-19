module App.View.Router where

import AppPrelude

import App.Api.Request (readToken, removeToken, verifyToken, writeToken)
import App.Data.Profile (Profile)
import App.Data.Route (routeCodec)
import App.Data.Route as Route
import App.Env (Env)
import App.View.Page.GamesPage as GamesPage
import App.View.Page.PicturesPage as PicturesPage
import App.View.Page.LoginPage as LoginPage
import App.View.Utils (navigate)
import React.Basic.Hooks (JSX, ReactComponent, component, element, useEffect, useState)
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)
import Routing.Duplex (parse)
import Routing.Hash (matchesWith)


make :: Env -> Effect (ReactComponent {})
make env = do
  loginPage <- LoginPage.make env
  gamesPage <- GamesPage.make env
  picturesPage <- PicturesPage.make env

  component "Router" \ _ -> React.do
    route /\ setRoute <- useState Route.Home
    currentUser /\ setCurrentUser <- useState Nothing

    initialized <- useAff unit do
      liftEffect readToken >>= traverse \ token -> do
        user <- verifyToken env.baseUrl token
        liftEffect $ setCurrentUser $ const $ hush user
        pure unit

    useEffect unit do
      matchesWith (parse routeCodec) \ src dst -> do
        case dst of
          Route.Logout -> do
            removeToken
            setCurrentUser $ const Nothing
            navigate Route.Home
          _ ->
            setRoute $ const dst

    useEffect (currentUser /\ route) do
      case currentUser, route of
        Just _, Route.Login -> navigate Route.Games
        Just _, Route.Home -> navigate Route.Games
        _, _ -> pure unit
      pure $ pure unit

    let context = { route, currentUser }
    let authorize content = case currentUser of
          Nothing -> do
            let onLogin (token /\ user) = do
                  writeToken token
                  setCurrentUser $ const $ Just user
            element loginPage { context, onLogin }
          Just _ -> content

    pure $ initialized # maybe mempty \ _ -> case route of
      Route.Home ->
        mempty # authorize
      Route.Games ->
        element gamesPage { context }
        # authorize
      Route.Pictures ->
        element picturesPage { context }
        # authorize
      Route.Login ->
        mempty # authorize
      Route.Logout ->
        mempty
