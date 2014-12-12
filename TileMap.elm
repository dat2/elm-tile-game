module TileMap where

import Graphics.Element (Element, image, opacity)
import Graphics.Collage (Form, collage, move, toForm)
import List (reverse, scanl, concat, map, scanl1, repeat, indexedMap, map2, tail, length)

import Array
import String
import Maybe

import Types (..)

import Text (asText)

-- some tiles are different heights and widths, so we need to have dimensions
-- between coordinates for them
-- these are pixels (horizontal, vertical) difference so that tiles line up
-- correctly
regularTile : DimensionF
regularTile = (65.0, 33.0)

-- the map coordinates are generated from [0,width-1], so we need to scale it
-- to pixel coordinates
scale : DimensionF -> Coordinate -> Coordinate
scale (sx, sy) (x,y) = (x * sx, y * sy)

{-
  convert a map that is in this order
     -3 -2 -1  0  1  2  3
  0            0
  1         4     1
  2      8     5     2
  3  12     9     6     3
  4     13    10     7
  5        14     11
  6           15
  to the proper rendering order (0,1,4,2,5,8,3,6,9,12,7,10,13,11,14)
  that snakes around from back to front (read TileMap.elm to see the order)
-}
renderIndices : Int -> List Int
renderIndices width = let
    diff = bitonicList width
    list = [0..width-1] ++ (tail <| scanl (+) (width-1) <| repeat (width-1) width)
  in
    concat <| map2 (curry (\(x,repeatTimes) -> scanl (+) x <| repeat (repeatTimes-1) (width-1))) list diff

renderRightDown : Int -> List Tile -> List Tile
renderRightDown width list = let
    indices = Array.fromList <| renderIndices width
    array = Array.fromList list
  in
    Array.toList
      <| Array.map (\x -> Maybe.withDefault 0 <| (Array.get x indices) `Maybe.andThen` (flip Array.get <| array))
      <| (Array.initialize (width*width) identity)

{-
in a 2d tilemap, this is the render order for an isometric map
       -3 -2 -1  0  1  2  3
    0            0
    1         2     1
    2      5     4     3
    3   9     8     7     6
    4     12    11    10
    5        14     13
    6           15
the points 0, 1, 3, 6, 10, 13, 15 are "trigger points" where
the x coordinate and the y coordinate change
-}

-- bitonicList is a helper to generate the list that scanl
-- needs to generate the actual trigger point indices
bitonicList : Int -> List Int
bitonicList width = [1..width] ++ reverse [1..width-1]

--generate a list of coordinates from a tilemap with a certain width
renderCoordinates : Int -> List Coordinate
renderCoordinates mapWidth = let
    diff = bitonicList mapWidth
    xs = concat <| map (\x -> scanl1 (\_ -> \a -> a - 2) <| repeat (x) (x-1)) <| diff
    ys = reverse <| concat <| indexedMap (\idx -> \x -> repeat x idx) diff
  in
    map2 (\x -> \y -> (toFloat x, toFloat y)) xs ys

-- convert a tile to a moveable image
tileForm : Dimension -> String -> Form
tileForm (tileWidth, tileHeight) tile = toForm <| image tileWidth tileHeight tile

-- render each layer
renderLayer : TileLayer -> TileSet -> (Int, Int) -> Element
renderLayer layer tileset (width, height) = let
    layerWidth = layer.width
    layerData = layer.data
    tileDimensions = (tileset.tileWidth, tileset.tileHeight)
    tileToImage tile = Maybe.withDefault "assets/blank.jpg" <| Array.get (tile-tileset.firstTileId) (Array.fromList tileset.tiles)
  in
    collage width height
      <| map (\(tile, coords) -> move (0, toFloat -height/2 + toFloat tileset.tileHeight / 2) <| move (scale regularTile coords) (tileForm tileDimensions <| tileToImage tile))
      <| map2 (,) (renderRightDown layerWidth layerData) <| renderCoordinates layerWidth

-- render the whole map
-- currently, it expects tilelayers to be paired with tilesets, it will not work
-- if you have a tile layer using tiles from many sets
-- also tilemaps must be square
renderMap : Dimension -> Result String TileMap -> Element
renderMap (width, height) result = case result of
  Ok tilemap ->
    collage width height <|
        map
          (\(layer, tileset) -> toForm (renderLayer layer tileset (width, height)))
          <| map2 (,) tilemap.layers tilemap.tilesets
  Err x -> asText x