local JumpProfile = "Default"

-- Global variables used to store reference to UI elements, so they can reaches by any functions
local JumpWindow = nil
local JumpWindowButton = nil
local JumpButton = nil
-- Global variable used to store reference scheduleEvent, so it can be removed later
LoopEvent = nil

-- This functions moves the button to the right side of the window, and randomly set the button vertically within the border of the window
function ResetButton()
	-- When getting X and Y from a JumpWindow, it returns the top left point of the window
	-- So we add the width of the window and minus the width of the button to set the button at the right edge of the screen
	JumpButton:setX(JumpWindow:getX() + JumpWindow:getWidth() - JumpButton:getWidth())

	local JumpWindowMinY = JumpWindow:getY()
	local newYValue = math.random(
		JumpWindowMinY + JumpButton:getHeight(),
		JumpWindowMinY + JumpWindow:getHeight() - JumpButton:getHeight()
	)
	JumpButton:setY(newYValue)
end

-- This functions starts the button moving procedure and continues calls itself to update the button position
function startLoop()
	updatebuttonLocation()
	LoopEvent = scheduleEvent(startLoop, 100)
end

-- Function called when the UI module first initialized
function init()
	connect(g_game, { onGameStart = online, onGameEnd = offline })
	-- Create the UI window and set it to be visible on initialized
	JumpWindow = g_ui.displayUI("jump", modules.game_interface.getRightPanel())
	JumpWindow:show()

	-- Adding this UI module to the top right game menu, using the spell list icon as placeholder
	JumpWindowButton = modules.client_topmenu.addRightGameToggleButton(
		"jumpWindowButton",
		tr("jump window"),
		"/images/topbuttons/spelllist",
		toggle
	)
	-- This ensure that when the UI moudle first loaded by the package manager, it is opened
	JumpWindowButton:setOn(true)

	JumpButton = JumpWindow:getChildById("jumpButton")
	startLoop()
end

-- Function called when the UI module is terminated
function terminate()
	disconnect(g_game, { onGameStart = online, onGameEnd = offline })
	-- Remove the recursive calling event to stop updating the button location
	removeEvent(LoopEvent)
	-- Remove empty reference
	-- Same thing with the rest of the UI elements
	LoopEvent = nil
	JumpWindow:destroy()
	JumpWindow = nil
	JumpWindowButton:destroy()
	JumpWindowButton = nil
	JumpButton:destroy()
	jumpButton = nil
end

-- Called when the button on the top right panel is clicked
function toggle()
	-- If the button is already on, then turn everything off, and remove event
	if JumpWindowButton:isOn() then
		JumpWindowButton:setOn(false)
		JumpWindow:hide()
		removeEvent(LoopEvent)
		LoopEvent = nil
	else
		-- Vice versa, start the event
		JumpWindowButton:setOn(true)
		JumpWindow:show()
		JumpWindow:raise()
		JumpWindow:focus()
		ResetButton()
		startLoop()
	end
end

-- The function that gets called every 100ms, handles the logic of updating the location of the jump button
function updatebuttonLocation()
	-- First check if the jump button is valid
	if JumpButton then
		local currentX = JumpButton:getX()
		local jumpWindowMin = JumpWindow:getX()
		-- Make sure that the jump button is not too close to the left side of the window
		if currentX > jumpWindowMin + JumpButton:getWidth() / 2 then
			-- Update the jump button location is not too close
			JumpButton:setX(currentX - 20)
		else
			-- Else reset the button
			ResetButton()
		end
	end
end
