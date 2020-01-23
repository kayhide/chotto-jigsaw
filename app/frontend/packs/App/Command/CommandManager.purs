module App.Command.CommandManager where

import AppPrelude

import App.Command.Command (Command)
import App.Command.Command as Command
import App.Command.CommandGroup (CommandGroup)
import App.Command.CommandGroup as CommandGroup
import App.GameManager (GameManager)
import Data.Array as Array
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Effect.Unsafe (unsafePerformEffect)

type CommandManager =
  { game :: Maybe GameManager
  , current :: CommandGroup
  , postHandlers :: Array (Command -> Effect Unit)
  , commitHandlers :: Array (CommandGroup -> Effect Unit)
  }

self :: Ref CommandManager
self = unsafePerformEffect do
  current <- CommandGroup.create
  Ref.new
    { game: Nothing
    , current
    , postHandlers: []
    , commitHandlers: []
    }

register :: GameManager -> Effect Unit
register game =
  self # Ref.modify_ _{ game = pure game }

onPost :: (Command -> Effect Unit) -> Effect Unit
onPost f = self # Ref.modify_ \obj ->
  obj { postHandlers = Array.snoc obj.postHandlers f }

onCommit :: (CommandGroup -> Effect Unit) -> Effect Unit
onCommit f = self # Ref.modify_ \obj ->
  obj { commitHandlers = Array.snoc obj.commitHandlers f }

commit :: Effect Unit
commit = do
  obj <- Ref.read self
  let group = obj.current
  next <- CommandGroup.create
  self # Ref.write obj { current = next }
  traverse_ (_ $ group) obj.commitHandlers

post :: Command -> Effect Unit
post cmd = do
  game <- _.game <$> Ref.read self >>= throwOnNothing "GameManager is not registered"
  b <- Command.isValid game cmd
  when b do
    Command.execute game cmd
    obj <- Ref.read self
    CommandGroup.squash cmd obj.current
    traverse_ (_ $ cmd) obj.postHandlers

receive :: Array Command -> Effect Unit
receive cmds = do
  obj <- Ref.read self
  game <- _.game <$> Ref.read self >>= throwOnNothing "GameManager is not registered"
  traverse_ (Command.execute game) cmds
  group <- CommandGroup.createExtrinsic
  traverse_ (\cmd -> CommandGroup.squash cmd group) cmds
  traverse_ (_ $ group) obj.commitHandlers

