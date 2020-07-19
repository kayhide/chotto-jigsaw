module App.View.Atom.LoadableButton where

import AppPrelude

import Data.Monoid as Monoid
import Prim.Row as Row
import React.Basic (JSX)
import React.Basic.DOM as R
import React.Basic.DOM.Events (preventDefault, stopPropagation)
import React.Basic.Events (handler)
import Record as Record


type PropsRow =
  ( text :: String
  | PropsRowOptional
  )

type PropsRowOptional =
  ( className :: String
  , type_ :: String
  , disabled :: Boolean
  , loading :: Boolean
  , onClick :: Effect Unit
  )

type Props = { | PropsRow }

render ::
  forall props props'.
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  { | props } -> JSX
render props = do
  let def =
        { className: ""
        , type_: "button"
        , disabled: false
        , loading: false
        , onClick: pure unit
        } :: { | PropsRowOptional }

  let { className, type_, text, onClick, disabled, loading } = Record.merge props def :: Props
  R.button
    { className: "loadable-button relative"
      <> Monoid.guard loading " loading"
      <> (mmap (append " ") className)
    , type: type_
    , disabled: disabled || loading
    , onClick: handler (preventDefault >>> stopPropagation) \ _ -> onClick
    , children:
      [ R.span_ $ pure $ R.text text
      , R.div
        { className: "absolute flex items-center justify-center left-0 top-0 w-full h-full"
        , children: pure $ R.i { className: "fas fa-spinner fa-pulse" }
        }
      ]
    }
