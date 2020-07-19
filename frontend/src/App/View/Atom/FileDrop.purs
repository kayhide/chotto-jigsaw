module App.View.Atom.FileDrop where

import AppPrelude

import Data.Nullable as Nullable
import React.Basic.DOM as R
import React.Basic.DOM.Events (preventDefault, stopPropagation)
import React.Basic.Events (EventFn, SyntheticEvent, handler, unsafeEventFn)
import React.Basic.Hooks (ReactComponent, component)
import React.Basic.Hooks as React
import Unsafe.Coerce (unsafeCoerce)
import Web.File.FileList (FileList)


type PropsRow =
  ( onDrop :: FileList -> Effect Unit
  )

type Props = { | PropsRow }

make :: Effect (ReactComponent Props)
make = do
  component "FileDrop" \ { onDrop } -> React.do
    pure $ R.div
      { className: "absolute inset-0 "
      , onDragEnter: handler (preventDefault >>> stopPropagation) $ const $ pure unit
      , onDragOver: handler (preventDefault >>> stopPropagation) $ const $ pure unit
      , onDrop: handler (preventDefault >>> stopPropagation >>> dataTransferFiles) $ traverse_ onDrop
      }

dataTransferFiles :: EventFn SyntheticEvent (Maybe FileList)
dataTransferFiles =
  unsafeEventFn \ e -> Nullable.toMaybe (unsafeCoerce e).dataTransfer.files
