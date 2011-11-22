local MenuToggle = {}

function MenuToggle.new()

	local toggle = display.newGroup()

	local menuOnButton, menuOffButton

	local createUI, dispatch, onTouch

	function createUI()
		menuOnButton = display.newImageRect( toggle, "menuOn.png", 30, 30 )
		menuOffButton = display.newImageRect( toggle, "menuOff.png", 30, 30 )
		menuOffButton.isVisible = false
		toggle:addEventListener("touch", onTouch)
	end

	function onTouch(event)
		if event.phase == "ended" then
			dispatch()
			menuOffButton.isVisible, menuOnButton.isVisible = menuOnButton.isVisible, menuOffButton.isVisible
		end
		return true
	end

	function dispatch()
		local showMenu = menuOnButton.isVisible
		toggle:dispatchEvent{ name = "toggle", showMenu = showMenu}
	end
	
	function toggle:destroy()
		toggle:removeEventListener("touch", onTouch)
		toggle:removeSelf()
	end

	createUI()
	
	return toggle

end

return MenuToggle