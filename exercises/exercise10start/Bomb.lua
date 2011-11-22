local Bomb = {}

local RADIANS_TO_DEGREES = 180 / math.pi
local BOMB_SHAPE = {-6,-1, 8,-1, 9,-1, 8,1, -6,1, -11,4, -11,-5}

local soundBombDrop = audio.loadSound("SoundBombDrop.wav")
local soundBombDestroyed = audio.loadSound("SoundBombDestroyed.wav")

function Bomb.new(targetX)
	
	assert(targetX, "Required parameter missing")
	
	local bomb = display.newImageRect( "Bomb.png", 25, 10 )
	bomb.id = "bomb"
	bomb.x = -1000
	
	local deltaX, deltaY
	local targetY, bombX, bombY
	
	physics.addBody(bomb, "dynamic", {isSensor = true, shape = BOMB_SHAPE})
	
	function bomb:fire(dropTime)
		bombX = math.random(_G.STAGE_WIDTH)
		bombY = -100
		targetY = _G.STAGE_HEIGHT
		local diffX = targetX - bombX
		local diffY = targetY - bombY
		deltaY = diffY / dropTime
		deltaX = diffX / dropTime
		local targetAngle = math.atan2(diffY, diffX) * RADIANS_TO_DEGREES
		bomb.rotation = targetAngle
		audio.play(soundBombDrop)
	end
	
	function bomb:move()
		bomb.x = bombX
		bomb.y = bombY
		bombX = bombX + deltaX
		bombY = bombY + deltaY
	end
	
	function bomb:destroy()
		audio.play(soundBombDestroyed)
		bomb:removeEventListener("collision", bomb)
		bomb:removeSelf()
		bomb = nil
	end
	
	return bomb
	
end

return Bomb