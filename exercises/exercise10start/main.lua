display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())

-- constants
STAGE_LEFT, STAGE_TOP = display.screenOriginX, display.screenOriginY
STAGE_WIDTH = display.contentWidth + STAGE_LEFT * -2
STAGE_HEIGHT = display.contentHeight + STAGE_TOP * -2
HALF_WIDTH = STAGE_WIDTH / 2
HALF_HEIGHT = STAGE_HEIGHT / 2

-- libraries
local Game = require("Game")

-- display objects
local game

game = Game.new()
game:startGame()