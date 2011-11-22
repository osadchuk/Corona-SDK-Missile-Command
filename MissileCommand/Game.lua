local Game = {}

physics = require("physics")
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode("hybrid")

function Game.new()
	
	local game = display.newGroup()
	game.id = "game"
	
	-- sound effects, channel
	local soundBackground = audio.loadStream("SoundBackground.mp3")
	local soundBackgroundChannel
	
	-- modules
	local Bomb = require("Bomb")
	local Missile = require("Missile")
	local Explosion = require("Explosion")
	local Lander = require("Lander")
	local MenuToggle = require("MenuToggle")
	local Slider = require("Slider")
	
	-- display objects
	local sky, ground, groundPhysics, scoreText
	local menuToggle, slider
	
	-- display groups
	local bombs
	local missiles
	local landers
	
	-- variables
	local frameCounter, bombSpeed, bombDropTimes
	local bombsThisLevel = 5
	local levelDuration = 600
	local currentLevel = 0
	local score = 0
	local shakeCounter = 0
	
	-- constants
	local BASE_SCORE = 50
	local BASE_DROP_TIME = 400
	local TARGET_RANGE = 50
	
	-- functions
	local initGround, initScore, initLanders, initMenuToggle
	local configureLevel, startListeners, run, fireMissile
	local checkForBombDrop, dropBomb, moveObjects
	local collisionHandler
	local groundHit, missileHit, explosionHit, landerHit
	local calculateScore, setScore
	local gameOver, removeListeners
	local onMenuToggle, onSliderChange
	local shakeScreen
	
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
	
	function initLanders()
		landers = display.newGroup()
		game:insert(landers)
		local distanceBetweenLanders = STAGE_WIDTH / 6
		local currentPosition = STAGE_LEFT + distanceBetweenLanders / 2
		for i = 1, 6 do
			local lander = Lander.new(currentPosition)
			landers:insert(lander)
			currentPosition = currentPosition + distanceBetweenLanders
		end
	end
	
	function initMenuToggle()
		menuToggle = MenuToggle.new()
		game:insert(menuToggle)
		menuToggle.x = STAGE_WIDTH - menuToggle.width + display.screenOriginX
		menuToggle.y = menuToggle.height
		menuToggle:addEventListener("toggle", onMenuToggle)
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
	
	function stopListeners()
		Runtime:removeEventListener("enterFrame", run)
		Runtime:removeEventListener("touch", fireMissile)
	end
	
	function run()
		moveObjects()
		frameCounter = frameCounter + 1
		checkForBombDrop()
		if shakeCounter > 0 then
			shakeScreen()
		end
		if landers.numChildren == 0 then
			gameOver()
		end
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
		if landers.numChildren == 0 then
			return
		end
		local index = math.random(landers.numChildren)
		local target = landers[index]
		local leftSide = target.x - TARGET_RANGE
		local rightSide = target.x + TARGET_RANGE
		local targetX = math.random(leftSide, rightSide)
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
	
	function shakeScreen()
		local randX = math.random(-3, 3)
		local randY = math.random(-3, 3)
		game.x = randX
		game.y = randY
		shakeCounter = shakeCounter - 1
		if shakeCounter == 0 then
			game.x = 0
			game.y = 0
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
			elseif id == "lander" then
				groundHit(self)
				landerHit(objectHit)
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
		shakeCounter = 30
	end
	
	function missileHit(bomb, missile)
		local explosion = Explosion.new("missile", missile.x, missile.y)
		game:insert(explosion)
		missile:destroy()
		bomb:destroy()
	end
	
	function explosionHit(bomb, explosion)
		bomb:destroy()
	end
	
	function landerHit(lander)
		lander:destroy()
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
	
	function gameOver()
		local gameOverSound = audio.loadSound("SoundGameOver.wav")
		audio.play(gameOverSound)
		audio.fadeOut{channel = soundBackgroundChannel, time = 2000}
		stopListeners()
		local gameOverImage = display.newImageRect( game, "GameOver.png", 425, 79 )
		gameOverImage.x = HALF_WIDTH
		gameOverImage.y = HALF_HEIGHT
	end
	
	function onMenuToggle(event)
		if not slider then
			slider = Slider.new(audio.getVolume())
			game:insert(slider)
			slider.x = HALF_WIDTH
			slider.y = HALF_HEIGHT
			slider:addEventListener("change", onSliderChange)
		end
		if event.showMenu == true then
			slider.isVisible = true
			stopListeners()
		else
			slider.isVisible = false
			startListeners()
		end
	end
	
	function onSliderChange(event)
		audio.setVolume(event.value)
	end
	
	function game:startGame()
		initGround()
		initScore()
		initLanders()
		initMenuToggle()
		bombs = display.newGroup()
		game:insert(bombs)
		missiles = display.newGroup()
		game:insert(missiles)
		configureLevel()
		startListeners()
		soundBackgroundChannel = audio.play(soundBackground, {loops = -1})
	end
	
	return game
	
end

return Game