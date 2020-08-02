module App.View.Page.GamePage where

import AppPrelude

import App.App as App
import App.Context (Context)
import App.Data.Game (Game(..), GameId)
import App.Env (Env)
import App.View.Agent.GamesAgent (GamesAgent, useGamesAgent)
import App.View.Atom.Icon as Icon
import Data.String as String
import Data.Tuple (fst)
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture_)
import React.Basic.Hooks (JSX, ReactComponent, component, fragment, useEffect, useReducer)
import React.Basic.Hooks as React


type Props =
  { context :: Context
  , gameId :: GameId
  }

type State =
  { logOpen :: Boolean
  }

data Action
  = ToggleLog

type Dispatch = Action -> Effect Unit

type ChildProps =
  { context :: Context
  , state :: State
  , games :: GamesAgent
  }

make :: Env -> Effect (ReactComponent Props)
make env = do
  component "GamesPage" \ props@{ context, gameId } -> React.do
    let initialState =
          { logOpen: false
          }
    state /\ dispatch <- useReducer initialState handleAction
    games <- useGamesAgent env context

    useEffect unit do
      games.loadOne gameId
      pure $ pure unit

    useEffect games.item do
      games.item # traverse_ \ (game' /\ token') -> do
        App.init game' token'
      pure $ pure unit

    pure
      $ maybe mempty (renderPlayboard state dispatch) $ fst <$> games.item

handleAction :: State -> Action -> State
handleAction state = case _ of
  ToggleLog -> state { logOpen = not state.logOpen }


renderPlayboard :: State -> Dispatch -> Game -> JSX
renderPlayboard state dispatch (Game game) = do
  let puzzle = unwrap game.puzzle
  fragment
    [ R.div
      { id: "playboard"
      , className: "playboard bg-lawrencium"
      , children:
        [ R.canvas
          { id: "base-canvas"
          , className: "hidden"
          }
        , R.canvas
          { id: "active-canvas"
          , className: "hidden"
          }
        , R.div
          { id: "game-progress"
          , className: "progress"
            <> (" bg-" <> String.toLower (show puzzle.difficulty) <> "-300")
          }
        , R.div
          { id: "info"
          , className: "text-white"
          , children:
            [ R.p
              { className: "fps"
              }
            , R.p_ $ pure $ R.text $ show puzzle.pieces_count
            ]
          }
        , R.div
          { id: "log"
          , className: ""
            <> bool " opacity-0" "" state.logOpen
          }
        , R.button
          { id: "log-button"
          , className: "text-white transform transition duration-200"
            <> bool "" " rotate-180" state.logOpen
          , onClick: capture_ $ dispatch ToggleLog
          , children: pure $ Icon.render "fas fa-caret-up"
          }
        ]
      }
    , R.div
      { id: "picture"
      , className: "absolute inset-0 flex items-center justify-center pointer-events-none select-none"
      , children: pure $ R.img
        { className: "block w-full object-contain transform scale-50"
        , src: puzzle.picture_url
        }
      }
    , R.div
      { id: "sounds"
      , className: ""
      }
    ]
