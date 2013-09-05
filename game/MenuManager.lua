require "Menu"
require "MenuTransitions"

module('MenuManager', Base.globalize)

function init()
	currentMenu = nil
	previousMenu = nil
	currentTransition = nil

	for _, file in ipairs(filesystem.enumerate 'menus') do
		local name = file:sub(0,file:len() - 4)
		require('menus.' .. name) -- get all menus
	end
end

function draw()
	if currentTransition then
		if previousMenu then currentTransition:drawPrevious() end
		if currentTransition and currentMenu then currentTransition:drawCurrent() end
	else
		if currentMenu then currentMenu:draw() end
	end
end

function update( dt )
	if previousMenu then previousMenu:update(dt) end
	if currentMenu then currentMenu:update(dt) end
end

function changeToMenu( menu, transition )
	if previousMenu then previousMenu:close() end
	previousMenu = currentMenu
	currentMenu = menu
	if menu then menu:open() end
	currentTransition = transition or MenuTransitions.Cut
	currentTransition:begin()
end