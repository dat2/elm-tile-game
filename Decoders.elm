module Decoders where
import Json.Decode (..)

import Types (..)
import Http (..)
import Dict
import List

tilelayerDecoder : Decoder TileLayer
tilelayerDecoder = object4 TileLayer
  ("width" := int)
  ("opacity" := float)
  ("visible" := bool)
  ("data" := list int)

tilesetDecoder : Decoder TileSet
tilesetDecoder = object4 TileSet
  ("tileheight" := int)
  ("tilewidth" := int)
  ("firstgid" := int)
  -- this last one converts "tiles": { "0" : "filename", "1": "filename2" } -> tiles: ["filename", "filename2"]
  ("tiles" := map
    (List.map snd)
    (map Dict.toList (dict ("image" := string))))

tilemapDecoder : Decoder TileMap
tilemapDecoder = object7 TileMap
  ("width" := int)
  ("height" := int)
  ("renderorder" := string)
  ("tileheight" := int)
  ("tilewidth" := int)
  ("layers" := list tilelayerDecoder)
  ("tilesets" := list tilesetDecoder)

decodeMap : Response String -> Result String TileMap
decodeMap resp = case resp of
  Success res -> decodeString tilemapDecoder res
  Waiting -> Err "Waiting"
  Failure code msg -> Err <| "Error: [" ++ (toString code) ++ "]" ++ msg