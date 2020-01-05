module App.EaselJS.Ticker where

import AppPrelude

foreign import getFramerate :: Effect Int
foreign import setFramerate :: Int -> Effect Unit
foreign import getMeasuredFPS :: Effect Number
foreign import onTick :: Effect Unit -> Effect Unit
