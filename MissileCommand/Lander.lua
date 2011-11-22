local Lander = {}

local soundLanderDestroyed = audio.loadSound("SoundTargetHit.wav")

function Lander.new(landerX)
	
	assert(landerX, "Required parameter missing")
	
	local imageNumber = math.random(4)
	local imageFile = "lander" .. imageNumber .. ".png"
	
	local lander = display.newImageRect(imageFile, 50, 41)
	lander.id = "lander"

	local halfHeight = lander.height / 2
	local halfWidth = lander.width / 2
	
	lander.x = landerX
	lander.y = _G.STAGE_TOP + _G.STAGE_HEIGHT - halfHeight
	
	local physicsShape = {
		-halfWidth, halfHeight - 5,
		halfWidth, halfHeight - 5,
		halfWidth, halfHeight,
		-halfWidth, halfHeight
	}

	physics.addBody(lander, "static", {isSensor = true, shape = physicsShape})
	
	function lander:destroy()
		local function onComplete(event)
			lander:removeSelf()
			lander = nil
		end
		local targetY = STAGE_TOP + STAGE_HEIGHT + lander.height
		transition.to(lander, {time = 500, y = targetY, onComplete = onComplete})
		audio.play(soundLanderDestroyed)
	end

	return lander
	
end

return Lander