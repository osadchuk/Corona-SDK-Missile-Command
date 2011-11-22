local Missile = {}

local MISSILE_SHAPE = {-6,-1, 8,-1, 9,-1, 8,1, -6,1, -11,4, -11,-5}
local BASE_SPEED = 4
local RADIANS_TO_DEGREES = math.pi / 180

local soundFire = audio.loadSound("SoundLauncher.wav")
local soundDestroy = audio.loadSound("SoundMissileDestroy.wav")

function Missile.new(targetX, targetY, originX, originY)
	
	assert(targetX or targetY or originX or originY, "Required parameter missing")

	local missile = display.newImageRect("Missile.png", 25, 10)
	missile.id = "missile"
	
	local deltaX, deltaY
	
	physics.addBody(missile, "static", {isSensor = true, shape = MISSILE_SHAPE})
	
	local function fire()
		missile.x, missile.y = originX, originY
		local diffX = originX - targetX
		local diffY = originY - targetY
		missile.rotation = math.atan2(diffY, diffX) / RADIANS_TO_DEGREES + 180
		local distance = math.sqrt(diffX * diffX + diffY * diffY)
		local theta = math.asin(diffX / distance)
		deltaX = BASE_SPEED * math.sin(theta)
		deltaY = BASE_SPEED * math.cos(theta)
		audio.play(soundFire)
	end
	
	function missile:move()
		local missileX, missileY = missile.x, missile.y
		missileX = missileX - deltaX
		missileY = missileY - deltaY
		missile.x, missile.y = missileX, missileY
		local diffX = math.abs(targetX - missileX)
		local diffY = math.abs(targetY - missileY)
		if diffX < 5 and diffY < 5 then
			deltaX, deltaY = 0, 0
			return true
		end
		return false
	end
	
	function missile:destroy()
		audio.play(soundDestroy)
		missile:removeSelf()
		missile = nil
	end
	
	fire()
	
	return missile
	
end

return Missile