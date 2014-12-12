module Types where

import Dict

type alias Tile = Int
type alias DimensionF = (Float, Float)
type alias Dimension = (Int, Int)
type alias Coordinate = (Float, Float)

--type RenderOrder = RightDown | RightUp | LeftDown | LeftUp
--This is really an isometric tilemap.
type alias TileMap = {
 width: Int, height: Int,
 renderOrder: String,
 tileHeight: Int, tileWidth: Int,
 layers : List TileLayer,
 tilesets: List TileSet
}

-- The layers of the tilemap
type alias TileLayer = {
  width: Int,
  opacity: Float,
  visible: Bool,
  data: List Tile
}

-- the tile sets
type alias TileSet = {
  tileHeight: Int, tileWidth: Int,
  firstTileId: Int,
  -- this is really an implicit mapping of Int -> Filename
  tiles: List (String)
}
