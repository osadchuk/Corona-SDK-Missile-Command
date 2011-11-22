local Slider = {}

function Slider.new(initialValue)
	
	local slider = display.newGroup()
	local track, thumb
	
	local createUI, sliderTouch, dispatch
	local halfTrack

	function createUI()

		track = display.newRoundedRect( slider, -100, -10, 200, 20, 10 )
		track:setFillColor(64, 64, 64)
		halfTrack = track.width / 2

		thumb = display.newCircle( 0, 0, 10 )
		thumb:setFillColor(0, 0, 128)
		slider:insert(thumb)

		if initialValue then
			thumb.x = track.width * initialValue - halfTrack
		end

		track:addEventListener("touch", sliderTouch)
	end
	
	function sliderTouch(event)
		if event.phase == "began" then
			display.getCurrentStage():setFocus(track)
		elseif event.phase == "ended" then
			display.getCurrentStage():setFocus(nil)
		end
		thumb.x = slider:contentToLocal(event.x, event.y)
		if thumb.x < track.x - halfTrack then
			thumb.x = track.x - halfTrack
		elseif thumb.x > track.x + halfTrack then
			thumb.x = track.x + halfTrack
		end
		dispatch()
	end

	function dispatch()
		local val = (thumb.x + track.width / 2)  / track.width
		slider:dispatchEvent{ name = "change", value = val}
	end
	
	function slider:destroy()
		track:removeEventListener("touch", sliderTouch)
		slider:removeSelf()
	end
	
	createUI()
	
	return slider

end

return Slider