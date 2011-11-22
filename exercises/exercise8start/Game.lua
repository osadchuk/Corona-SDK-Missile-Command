local Game = {}

physics = require("physics")
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode("hybrid")

function Game.new()
	
	local game = display.newGroup()
	game.id = "game"
	
	-- modules
	local Bomb = require("Bomb")
	local Missile = require("Missile")
	local Explosion = require("Explosion")
	
	-- display objects
	local sky, ground, groundPhysics, scoreText
	
	-- display groups
	local bombs
	local missiles
	
	-- variables
	local frameCounter, bombSpeed, bombDropTimes
	local bombsThisLevel = 5
	local levelDuration = 600
	local currentLevel = 0
	local score = 0
	
	-- constants
	local BASE_SCORE = 50
	local BASE_DROP_TIME = 400
	
	-- functions
	local initGround, initScore
	local configureLevel, startListeners, run, fireMissile
	local checkForBombDrop, dropBomb, moveObjects
	local collisionHandler
	local groundHit, missileHit, explosionHit
	local calculateScore, setScore
	
	function initGround()
		sky = display.newRect( game, _G.STAGE_LEFT, _G.STAGE_TOP, _G.STAGE_WIDTH, _G.STAGE_HEIGHT )
		sky:setFillColor(25, 25, 55)
		
		ground = display.newImageRect( game, "Ground.png", 600, 86 )
		ground.x = _G.HALF_WIDTH
		ground.y = _G.STAGE_TOP + _G.STAGE_HEIGHT
		
		groundPhysics = display.newRect(
			game, _G.STAGE_LEFT,_G.STAGE_HEIGHT + _G.STAGE_TOP - 2,
			_G.STAGE_WIDTH, 2 )
		groundPhysics.isVisible = false
		physics.addBody(groundPhysics, "static")
		groundPhysics.id = "ground"
	end
	
	function initScore()
		scoreText = display.newText(game, "0", 0, 0, "ArmorPiercing", 48)
		scoreText.x = _G.HALF_WIDTH
		scoreText.y = 20
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
		Runtime:addEventListener("touch", fireMissile)
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
		local targetX = math.random(0, _G.STAGE_WIDTH) + _G.STAGE_LEFT
		local bomb = Bomb.new(targetX)
		bombs:insert(bomb)
		bomb:fire(bombSpeed)
		bomb.collision = collisionHandler
		bomb:addEventListener("collision", bomb)
	end
	
	function moveObjects()
		for i = bombs.numChildren, 1, -1 do
			local bomb = bombs[i]
			bomb:move()
		end
		for i = missiles.numChildren, 1, -1 do
			local missile = missiles[i]
			local atTarget = missile:move()
			if atTarget == true then
				local explosion = Explosion.new("missile", missile.x, missile.y)
				game:insert(explosion)
				missile:destroy()
			end
		end
	end
	
	function fireMissile(event)
		if event.phase == "ended" then
			local missile = Missile.new(event.x, event.y, HALF_WIDTH, STAGE_TOP + STAGE_HEIGHT)
			missiles:insert(missile)
			setScore(-25)
		end
	end
	
	function collisionHandler(self, event)
		if event.phase == "began" then
			local objectHit = event.other
			local id = objectHit.id
			if id == "ground" then
				groundHit(self)
			elseif id == "missile" then
				calculateScore(self.y)
				missileHit(self, objectHit)
			elseif id == "explosion" then
				calculateScore(self.y)
				explosionHit(self, objectHit)
			end
			if #bombDropTimes == 0 then
				configureLevel()
			end
		end
	end
	
	function groundHit(bomb)
		local explosion = Explosion.new("bomb", bomb.x, STAGE_HEIGHT + STAGE_TOP)
		game:insert(explosion)
		bomb:destroy()
	end
	
	function missileHit(bomb, missile)
		local explosion = Explosion.new("missile", missile.x, missile.y)
		game:insert(explosion)
		missile:destroy()
		bomb:destroy
	end
	
	function explosionHit(bomb, explosion)
		bomb:destroy
	end
	
	function calculateScore(bombY)
		local heightMultiplier = 1 + (_G.STAGE_HEIGHT + _G.STAGE_TOP - bombY) / (_G.STAGE_HEIGHT + _G.STAGE_TOP)
		local scoreToAdd = math.floor(BASE_SCORE * heightMultiplier)
		setScore(scoreToAdd)
	end
	
	function setScore(amount)
		score = score + amount
		scoreText.text = score
	end
	
	function game:startGame()
		initGround()
		initScore()
		bombs = display.newGroup()
		game:insert(bombs)
		missiles = display.newGroup()
		game:insert(missiles)
		configureLevel()
		startListeners()
	end
	
	return game
	
end

return Game