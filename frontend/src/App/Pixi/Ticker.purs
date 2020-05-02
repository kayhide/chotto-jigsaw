module App.Pixi.Ticker where

import AppPrelude

foreign import getFPS :: Effect Number
foreign import getMeasuredFPS :: Effect Number
foreign import onTick :: (Number -> Effect Unit) -> Effect Unit
