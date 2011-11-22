local Explosion = {}

local sprite = require("sprite")

local image, dataModule

if display.contentScaleX == 1 then
	image = "SpriteSheet.png"
	dataModule = "SpriteSheet"
elseif display.contentScaleX < 1 then
	image = "SpriteSheet@2x.png"
	dataModule = "SpriteSheet@2x"
end

local zwoptexData = require(dataModule)
local data = zwoptexData.getSpriteSheetData()
local spriteSheet = sprite.newSpriteSheetFromData( image, data )
local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 42)
sprite.add(spriteSet, "bomb", 1, 21, 1, 1)
sprite.add(spriteSet, "missile", 22, 21, 1, 1)

function Explosion.new(explosionType, explosionX, explosionY)
	
	assert(explosionType or explosionX or explosionY, "Required parameter missing")
	
	local explosion = sprite.newSprite(spriteSet)
	explosion.id = "explosion"
	
	if display.contentScaleX < 1 then
		explosion.xScale = 0.5
		explosion.yScale = 0.5
	end
	
	local function spriteEventHandler(self, event)
		if event.phase == "end" then
			explosion:removeEventListener("sprite", explosion)
			explosion:removeSelf()
			explosion = nil
		end
	end
	
	local function addPhysics()
		physics.addBody(explosion, "static", {isSensor = true, radius = 15})
	end
	
	if explosionType == "bomb" then
		explosion:setReferencePoint(display.BottomCenterReferencePoint)
	else
		timer.performWithDelay(0, addPhysics)
		explosion.rotation = math.random(360)
	end
	
	explosion.x = explosionX
	explosion.y = explosionY

	explosion.sprite = spriteEventHandler
	explosion:addEventListener("sprite", explosion)
	explosion:prepare(explosionType)
	explosion:play()
	
	return explosion
	
end

return Explosion