import Text (asText)
import Window
import Signal

import TileMap (..)
import Types (..)
import Decoders (..)

import Graphics.Element (..)
import Graphics.Collage (..)
import List (..)
import Http (sendGet, Response)
import Result

loadMap : Signal (Response String)
loadMap = sendGet <| Signal.constant "map2.json"

main = Signal.map2 renderMap (Window.dimensions) (Signal.map decodeMap loadMap)

{-
modifyLayer : TileLayer -> TileLayer
modifyLayer layer = { layer | data <- renderOrder layer.width layer.data }

main = Signal.map
  (\result -> asText <|
    Result.map
    --identity
    (\tilemap -> { tilemap | layers <- map modifyLayer tilemap.layers })
    result)
  (Signal.map decodeMap loadMap)
  -}