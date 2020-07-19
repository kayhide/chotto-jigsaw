module App.View.Organism.HeaderMenu where

import AppPrelude

import App.Context (Context)
import App.Data.Route as Route
import App.Env (Env)
import App.View.Utils (hrefTo)
import App.View.Molecule.Dropdown as Dropdown
import React.Basic.DOM as R
import React.Basic.Hooks (ReactComponent, component, element)
import React.Basic.Hooks as React


type Props =
  { context :: Context
  }


make :: Env -> Effect (ReactComponent Props)
make env = do
  dropdown <- Dropdown.make
  component "HeaderMenu" \ props -> React.do
    let route = props.context.route
    pure
      $ R.nav_
      [ R.div
        { className: "flex items-center flex-shrink-0 mr-6"
        , children:
          [ R.a
            { className: "text-xl tracking-tight text-gray-900"
            , href: hrefTo Route.Home
            , children:
              [ R.text "Chotto Jigsaw"
              ]
            }
          ]
        }
      , props.context.currentUser # maybe mempty \ user ->
        R.div
        { className: "w-full block flex-grow justify-end sm:flex sm:items-center sm:w-auto"
        , children:
          [ element dropdown
            { align: Dropdown.AlignRight
            , trigger: R.button
              { className: "block ml-auto focus:outline-none"
              , children:
                [ R.text user.username
                , R.i
                  { className: "fas fa-angle-down ml-3"
                  }
                ]
              }
            , content: R.div
              { className: "bg-white w-48 py-3 rounded-md"
              , children:
                [ R.a
                  { className: "block px-3 text-cyan-900 hover:bg-gray-200"
                  , href: hrefTo Route.Logout
                  , children: pure $ R.text "Logout"
                  }
                ]
              }
            }
          ]
        }
      ]
