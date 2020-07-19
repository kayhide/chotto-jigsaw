module App.View.Page.HomePage where

import AppPrelude

import App.Context (Context)
import App.Env (Env)
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Skeleton.Narrow as Narrow
import React.Basic (element)
import React.Basic.DOM as R
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
  component "HomePage" \ { context } -> React.do
    let initialState =
          {
          }

    state /\ dispatch <- useReducer initialState handleAction

    pure
      $ Narrow.render
        { header: element header { context }
        , alpha: R.text "OK"
        }

handleAction :: State -> Action -> State
handleAction state _ = state
