import Text (asText)
import Window
import Signal ((<~))

import TileMap (..)

main = (renderTilemap 4) <~ Window.dimensions