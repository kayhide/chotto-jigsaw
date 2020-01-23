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
  { manager :: Maybe GameManager
  , current :: CommandGroup
  , postHandlers :: Array (Command -> Effect Unit)
  , executeHandlers :: Array (Command -> Effect Unit)
  , commitHandlers :: Array (CommandGroup -> Effect Unit)
  }

self :: Ref CommandManager
self = unsafePerformEffect do
  current <- CommandGroup.create
  Ref.new
    { manager: Nothing
    , current
    , postHandlers: []
    , executeHandlers: []
    , commitHandlers: []
    }

register :: GameManager -> Effect Unit
register manager =
  self # Ref.modify_ _{ manager = pure manager }

onPost :: (Command -> Effect Unit) -> Effect Unit
onPost f = self # Ref.modify_ \obj ->
  obj { postHandlers = Array.snoc obj.postHandlers f }

onExecute :: (Command -> Effect Unit) -> Effect Unit
onExecute f = self # Ref.modify_ \obj ->
  obj { executeHandlers = Array.snoc obj.executeHandlers f }

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
  manager <- verifyGameManager
  b <- Command.isValid manager cmd
  when b do
    Command.execute manager cmd
    obj <- Ref.read self
    CommandGroup.squash cmd obj.current
    traverse_ (_ $ cmd) obj.executeHandlers
    traverse_ (_ $ cmd) obj.postHandlers

execute :: Command -> Effect Unit
execute cmd = do
  manager <- verifyGameManager
  b <- Command.isValid manager cmd
  when b do
    Command.execute manager cmd
    obj <- Ref.read self
    traverse_ (_ $ cmd) obj.executeHandlers

verifyGameManager :: Effect GameManager
verifyGameManager = do
  obj <- Ref.read self
  _.manager <$> Ref.read self >>= throwOnNothing "GameManager is not registered"
