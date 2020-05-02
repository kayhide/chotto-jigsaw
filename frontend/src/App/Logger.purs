module App.Logger where

import AppPrelude

import Data.Array as Array
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Effect.Unsafe (unsafePerformEffect)

handlers :: Ref (Array (String -> Effect Unit))
handlers = unsafePerformEffect $ Ref.new []

append :: (String -> Effect Unit) -> Effect Unit
append handler =
  Ref.modify_ (flip Array.snoc handler) handlers

trace :: forall m. MonadEffect m => String -> m Unit
trace msg =
  liftEffect $ traverse_ (_ $ msg) =<< Ref.read handlers

traceShow
  :: forall a m.
     Show a =>
     MonadEffect m =>
     a -> m Unit
traceShow x = trace $ show x

traceShowId
  :: forall a m.
     Show a =>
     MonadEffect m =>
     a -> m a
traceShowId x = x <$ trace (show x)


debug :: forall m. MonadEffect m => String -> m Unit
debug = trace

info :: forall m. MonadEffect m => String -> m Unit
info = trace
