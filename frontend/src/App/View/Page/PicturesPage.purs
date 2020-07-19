module App.View.Page.PicturesPage where

import AppPrelude

import App.Context (Context)
import App.Data.Route as Route
import App.Env (Env)
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Skeleton.Wide as Wide
import App.View.Utils (navigate)
import React.Basic (element)
import React.Basic.DOM as R
import React.Basic.Events (handler_)
import React.Basic.Hooks (ReactComponent, component, useReducer)
import React.Basic.Hooks as React


type Props =
  { context :: Context
  }

type State =
  {
  }

data Action = Unit

make :: Env -> Effect (ReactComponent Props)
make env = do
  header <- HeaderMenu.make env
  alpha <- makeAlpha env
  component "PicturesPage" \ props@{ context } -> React.do
    let initialState =
          {
          }

    state /\ dispatch <- useReducer initialState handleAction

    pure
      $ Wide.render
      { header: element header { context }
      , alpha: element alpha props
      }

handleAction :: State -> Action -> State
handleAction state _ = state


makeAlpha :: Env -> Effect (ReactComponent Props)
makeAlpha env = do
  component "Alpha" \ props@{ context } -> React.do
    pure
      $ R.div
      { className: "alpha w-full mt-20"
      , children:
        [ R.div
          { className: "w-full flex justify-between space-x-3"
          , children:
            [ R.button
              { className: "block w-1/2 secondary-button"
              , onClick: handler_ $ navigate Route.Games
              , children:
                [ R.i { className: "fas fa-play px-2" }
                , R.text "Games"
                ]
              }
            , R.button
              { className: "block w-1/2 secondary-button active"
              , onClick: handler_ $ navigate Route.Pictures
              , children:
                [ R.i { className: "fas fa-image px-2" }
                , R.text "Pictures"
                ]
              }
            ]
          }
        ]
      }
