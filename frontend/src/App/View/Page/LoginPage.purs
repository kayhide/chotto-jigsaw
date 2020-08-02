module App.View.Page.LoginPage where

import AppPrelude

import App.Api.Request (Token, login, writeToken)
import App.Context (Context)
import App.Data.Profile (Profile)
import App.Env (Env)
import App.View.Atom.LoadableButton as LoadableButton
import App.View.Skeleton.Narrow as Narrow
import Data.String as String
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture, preventDefault, stopPropagation, targetValue)
import React.Basic.Events (handler, handler_)
import React.Basic.Hooks (JSX, ReactComponent, component, element, fragment, useReducer)
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)


type Props =
  { context :: Context
  , onLogin :: Token /\ Profile -> Effect Unit
  }

type State =
  { submitting :: Boolean
  , email :: String
  , password :: String
  , errorMessage :: Maybe String
  }

data Action
  = Submit
  | Succeeded (Token /\ Profile)
  | Failed String
  | SetEmail String
  | SetPassword String


make :: Env -> Effect (ReactComponent Props)
make env = do
  form <- makeForm
  component "LoginPage" \ props -> React.do
    let initialState =
          { submitting: false
          , email: ""
          , password: ""
          , errorMessage: Nothing
          }

    state /\ dispatch <- useReducer initialState handleAction

    useAff state.submitting do
      when state.submitting do
        let { email, password } = state
        res <- login env.baseUrl { email, password }
        liftEffect $ case res of
          Left err -> dispatch $ Failed err
          Right x -> props.onLogin x


    pure $ Narrow.render
        { alpha: fragment
          [ maybe mempty renderMessage state.errorMessage
          , R.div
            { className: "mt-24"
            , children: pure $ element form { state, dispatch }
            }
          ]
        }

  where
    renderMessage :: String -> JSX
    renderMessage msg =
      R.div
      { className: "absolute inset-x-0 top-0"
      , children:
        [ R.div
          { className: "w-full max-w-screen-md text-red-900 bg-red-300 border-red-900 py-3 px-5 mt-3 mx-auto rounded"
          , children: [ R.text msg ]
          }
        ]
      }

handleAction :: State -> Action -> State
handleAction state = case _ of
  Submit -> state { submitting = true }
  Succeeded _ -> state { submitting = false, errorMessage = Just "OK" }
  Failed msg -> state { submitting = false, errorMessage = Just msg }
  SetEmail email -> state { email = email }
  SetPassword password -> state { password = password }


makeForm :: Effect (ReactComponent { state :: State, dispatch :: Action -> Effect Unit })
makeForm = do
  component "LoginForm" \ { state, dispatch } -> React.do
    pure $ fragment
      [ R.form
        { className: "glassy rounded p-8"
          <> bool "" " submitting" state.submitting
        , onSubmit: handler (preventDefault >>> stopPropagation) $ const (pure unit)
        , children:
          [ renderInput "Email" { type_: "text", value: state.email, update: dispatch <<< SetEmail }
          , renderInput "Password" { type_: "password", value: state.password, update: dispatch <<< SetPassword }
          , R.div
            { className: "w-full mt-6"
            , children:
              [ LoadableButton.render
                { className: "w-1/3 primary-button"
                , type_: "submit"
                , disabled: String.null state.email || String.null state.password
                , loading: state.submitting
                , onClick: dispatch Submit
                , text: "Login"
                }
              ]
            }
          ]
        }
      ]

  where
    renderInput :: String -> _ -> JSX
    renderInput label { type_, value, update } =
      R.div
      { className: "mb-4"
      , children:
        [ R.label_ [ R.text label ]
        , R.input
          { type: type_
          , placeholder: label
          , value
          , onChange: capture (preventDefault >>> stopPropagation >>> targetValue) $ traverse_ update
          }
        ]
      }
