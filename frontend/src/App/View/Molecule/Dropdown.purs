module App.View.Molecule.Dropdown where

import AppPrelude

import Data.String as String
import Prim.Row as Row
import React.Basic.DOM as R
import React.Basic.Events (handler_)
import React.Basic.Hooks (JSX, ReactComponent, component, fragment, useState)
import React.Basic.Hooks as React
import Record as Record


type PropsRow =
  ( trigger :: JSX
  , content :: JSX
  , align :: Align
  )

data Align = AlignLeft | AlignRight

derive instance eqAlign :: Eq Align
derive instance ordAlign :: Ord Align


type PropsRowOptional =
  ( align :: Align
  )

type Props = { | PropsRow }

make ::
  forall props props'.
  Row.Lacks "key" props =>
  Row.Lacks "children" props =>
  Row.Lacks "ref" props =>
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  Effect (ReactComponent { | props })
make = do
  component "Dropdown" \ props -> React.do
    let { trigger, content, align } = Record.merge props def :: Props
    open /\ setOpen <- useState false

    pure $ fragment
      [ R.div
        { className: "dropdown relative"
        , children:
          [ R.div
            { className: "dropdown-trigger"
            , onClick: handler_ $ setOpen not
            , children:
              [ trigger
              ]
            }
          , R.div
            { className: String.joinWith " "
              $ [ "dropdown-children absolute" ]
              <> ("active" <$ guard open)
              <> ("right-0" <$ guard (align == AlignRight))
            , children: pure content
            }
          ]
        }
      ]

  where
    def :: { | PropsRowOptional }
    def = {
      align: AlignLeft
    }
