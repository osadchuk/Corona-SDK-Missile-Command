local Game = {}

physics = require("physics")
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode("hybrid")

function Game.new()
	
	local game = display.newGroup()
	game.id = "game"
	
	-- display objects
	local sky, ground
	
	-- variables
	local frameCounter, bombSpeed, bombDropTimes
	local bombsThisLevel = 5
	local levelDuration = 600
	local currentLevel = 0
	
	-- constants
	local BASE_DROP_TIME = 400
	
	-- functions
	local initGround
	local configureLevel, startListeners, run
	local checkForBombDrop, dropBomb, moveObjects
	
	function initGround()
		sky = display.newRect( game, _G.STAGE_LEFT, _G.STAGE_TOP, _G.STAGE_WIDTH, _G.STAGE_HEIGHT )
		sky:setFillColor(25, 25, 55)
		
		ground = display.newImageRect( game, "Ground.png", 600, 86 )
		ground.x = _G.HALF_WIDTH
		ground.y = _G.STAGE_TOP + _G.STAGE_HEIGHT
	end
	
	function configureLevel()
		bombsThisLevel = bombsThisLevel + 2
		levelDuration = levelDuration - 10
		if levelDuration < 200 then
			levelDuration = 200
		end
		bombDropTimes = {}
		local interval = 1 / bombsThisLevel
		for i = interval, 1, interval do
			local dropTime = math.round(math.sin(i * (math.pi / 2)) * levelDuration)
			bombDropTimes[#bombDropTimes + 1] = dropTime
		end
		bombSpeed = BASE_DROP_TIME - currentLevel * 10
		currentLevel = currentLevel + 1
		frameCounter = 0
	end
	
	function startListeners()
		Runtime:addEventListener("enterFrame", run)
	end
	
	function run()
		moveObjects()
		frameCounter = frameCounter + 1
		checkForBombDrop()
	end
	
	function checkForBombDrop()
		if #bombDropTimes == 0 then
			return
		end
		if frameCounter == bombDropTimes[1] then
			table.remove(bombDropTimes, 1)
			dropBomb()
		end
	end
	
	function dropBomb()
		print("dropBomb")
	end
	
	function moveObjects()
	end
	
	function game:startGame()
		initGround()
		configureLevel()
		startListeners()
	end
	
	return game
	
end

return Game