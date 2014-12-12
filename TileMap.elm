module TileMap where

import Graphics.Element (Element, image, opacity)
import Graphics.Collage (Form, collage, move, toForm)
import List (reverse, scanl, concat, map, scanl1, repeat, indexedMap, map2)
import String

--type RenderOrder = RightDown | RightUp | LeftDown | LeftUp
--This is really an isometric tilemap.
type alias TileMap = {
 width: Int, height: Int,
 renderOrder: String,
 tileHeight: Int, tileWidth: Int,
 layers : List TileLayer,
 tilesets: List TileSet,
 x: Int, y: Int
}

-- The layers of the tilemap
type alias TileLayer = {
  width: Int, height: Int,
  opacity: Float,
  visible: Bool
}

-- the tile sets
type alias TileSet = {
  tileHeight: Int, tileWidth: Int,
  -- this is really a mapping of Int -> Filename
  tiles: List String
}

-- the actual tilemap
type alias Tile = Int
getTilemap : List Tile
getTilemap = [
-- 0    1    2    3
  114, 080, 087, 080,
-- 4    5    6    7
  081, 087, 119, 081,
-- 8    9    10   11
  081, 118, 088, 081,
-- 12   13   14   15
  095, 088, 095, 122]

-- some tiles are different heights and widths, so we need to have dimensions
-- between coordinates for them
type alias Dimension = (Float, Float)
regularTile : Dimension
regularTile = (65, 27)

-- coordinates type
type alias Coordinate = (Float, Float)
scale : Dimension -> Coordinate -> Coordinate
scale (sx, sy) (x,y) = (x * sx, y * sy)

-- add zeros to the beginning of the strings
padZero : Int -> String -> String
padZero numZeros str = let
    len = String.length str
    diff = numZeros - len
  in
    if len < numZeros then (String.repeat diff "0") ++ str else str

-- convert a tilemap number to the filename
tileForm : Tile -> Form
tileForm tile = toForm <| opacity 0.5 <| image 132 83 <| "assets/landscapeTiles_" ++ (padZero 3 <| toString tile) ++ ".png"

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

-- differences is a helper to generate the list that scanl
-- needs to generate the actual trigger point indices
differences : Int -> List Int
differences width = let
    numPoints = 2 * width - 2
  in
    [1..numPoints//2+1] ++ reverse [2..numPoints//2]

-- the indices in the list where the coordinates change
-- trigger points depend on the width
triggerPoints : Int -> List Int
triggerPoints width = scanl (+) 0 <| differences width

--generate a list of coordinates from a tilemap with a certain width
mapCoordinates : Int -> List Coordinate
mapCoordinates mapWidth = let
    points = triggerPoints mapWidth
    diff = differences mapWidth ++ [1]
    xs = concat <| map (\x -> scanl1 (\_ -> \a -> a - 2) <| repeat (x) (x-1)) <| diff
    ys = reverse <| concat <| indexedMap (\idx -> \x -> repeat x idx) diff
  in
    map2 (\x -> \y -> (toFloat x, toFloat y)) xs ys


-- render the actual tilemap
renderTilemap : Int -> (Int, Int) -> Element
renderTilemap mapWidth (width,height) =
  collage width height <|
    map (\(tile, coords) -> move (scale regularTile coords) (tileForm tile) ) <|
    map2 (,) (getTilemap) (mapCoordinates mapWidth)