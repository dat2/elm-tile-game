import Text (asText)
import Window
import Signal (..)

import TileMap (..)
import Types (..)
import Decoders (..)

import Graphics.Element (..)
import Graphics.Collage (..)
import Http (sendGet, Response)
import Result
import String

loadMap : Signal (Response String)
loadMap = sendGet <| constant "map2.json"

main = map2 renderMap (Window.dimensions) (decodeMap <~ loadMap)

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