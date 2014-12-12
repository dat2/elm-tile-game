elm-tile-game
=============

A tile game written in elm. If there is enough interest I will extract the tile map code for others to use.
This game loads in [Tiled](http://www.mapeditor.org/) maps (only isometric right now) and renders them in the 
correct order on screen. (Snaking right to left from the back). While this does have an implementation for
isometric tilemaps, this is mainly a toy project and is probably better to just make the game in 3D. 

# Assets
The game uses the Kenney [Isometric Landscape](http://opengameart.org/content/isometric-landscape) assets right now.
Create an `assets` folder in the root directory of this repository, download the zip file, and copy all files from the `PNG` folder into the assets folder you just created.

# Draw order versus Render order

A little bit of glossary here:

Render order : The directions that represent where each tile gets placed in the final picture.

Draw order: The order to draw tiles so they do not overlap each other. You draw tiles from the back, different
than the render order.

Currently, the game expects an array of tile ids expecting to look like this:
<pre>
   -3 -2 -1  0  1  2  3
0            0
1         4     1
2      8     5     2
3  12     9     6     3
4     13    10     7
5        14     11
6           15

the correct draw order: [0,1,4,2,5,8,3,6,9,12,7,10,13,11,14,15]
</pre>

For a 4x4 map, the array [0..16] will render from the top and go down and right.

However, if you drew the tiles in that order, you'd get some tiles overlapping others and an overall weird picture. So, the `renderRightDown` function takes the tiles and converts it to the correct draw order.

The `renderCoordinates` function will give you an array of coordinates for each point from [0..16] in the following
draw order.
<pre>
   -3 -2 -1  0  1  2  3
0            0
1         2     1
2      5     4     3
3   9     8     7     6
4     12    11    10
5        14     13
6           15
</pre>

<pre>
  0        1       2        3      4
[(0, 0), (1, 1), (-1, 1), (2, 2), (2, 0), ...]
</pre>

This design may seem a bit complex, but then you can re order the array in any direction, for example left up
<pre>
   -3 -2 -1  0  1  2  3
0            12
1         11    13
2      7     10    14
3   3     6     9     15
4      2     5     8
5         1     4
6            0

the correct draw order of tiles 
[12, 13, 11, 14, 10, 7, 15, 9, 6, 3, 8, 5, 2, 4, 1, 0]
</pre>
as long as you move the tiles around in this array so that they draw in the correct order.

# Building
Just clone this repository and then run `elm-reactor` and it will automatically download everything for you.

# Credit
If you do want to extract the tile map code on your own, please credit me.
