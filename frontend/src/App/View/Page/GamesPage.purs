module App.View.Page.GamesPage where

import AppPrelude

import App.Context (Context)
import App.Data.Game (Game(..))
import App.Data.Route as Route
import App.Env (Env)
import App.View.Agent.GamesAgent (GamesAgent, useGamesAgent)
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Skeleton.Wide as Wide
import App.View.Utils (navigate)
import React.Basic (element)
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture_)
import React.Basic.Events (handler_)
import React.Basic.Hooks (ReactComponent, component, useEffect, useReducer)
import React.Basic.Hooks as React


type Props =
  { context :: Context
  }

type State =
  {
  }

data Action = Unit

type ChildProps =
  { context :: Context
  , state :: State
  , games :: GamesAgent
  }

make :: Env -> Effect (ReactComponent Props)
make env = do
  header <- HeaderMenu.make env
  alpha <- makeAlpha env
  component "GamesPage" \ props@{ context } -> React.do
    let initialState =
          {
          }

    state /\ dispatch <- useReducer initialState handleAction
    games <- useGamesAgent env context

    useEffect unit do
      games.load
      pure $ pure unit

    pure
      $ Wide.render
      { header: element header { context }
      , alpha: element alpha { context, state, games }
      }

handleAction :: State -> Action -> State
handleAction state _ = state


makeAlpha :: Env -> Effect (ReactComponent ChildProps)
makeAlpha env = do
  component "Alpha" \ props@{ context, games } -> React.do
    let renderGame (Game game) =
          R.button
          { className: "relative pb-full w-full border border-white rounded overflow-hidden"
            <> " transition-transform duration-200 transform origin-center"
          , children: pure $ R.img
            { className: "absolute w-full h-full object-cover"
            , src: (unwrap game.puzzle).picture_thumbnail_url
            }
          }
    pure
      $ R.div
      { className: "alpha w-full mt-20"
      , children:
        [ R.div
          { className: "w-full flex justify-between space-x-3"
          , children:
            [ R.button
              { className: "block w-1/2 secondary-button active"
              , onClick: capture_ $ navigate Route.Games
              , children:
                [ R.i { className: "fas fa-play px-2" }
                , R.text "Games"
                ]
              }
            , R.button
              { className: "block w-1/2 secondary-button"
              , onClick: capture_ $ navigate Route.Pictures
              , children:
                [ R.i { className: "fas fa-image px-2" }
                , R.text "Pictures"
                ]
              }
            ]
          }
        , R.div
          { className: "grid grid-cols-3 gap-3 mt-3"
          , children: renderGame <$> games.items
          }
        ]
      }
