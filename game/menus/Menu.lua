require 'base.Group'

Menu = Group:new {
	index = nil,
	__type = 'Menu'
}

Menu.__init = {
	drawableParts = {},
	alphaFollows = VarTimer:new{var = 255, pausable = false}
}

function Menu:add( component )
	component.alphaFollows = self.alphaFollows
	component:start()
	component.menu = self.index
	Group.add(self, component)
end

function Menu:completeDraw()
	self:draw()
	for drawFunc in pairs(self.drawableParts) do
		drawFunc()
	end
end

function Menu:draw()
	for i = self.length, 1, -1 do
		self[i]:draw()
	end
end

function Menu:addDrawablePart( drawFunc )
	self.drawableParts[drawFunc] = true
end

function Menu:load()
	self.alphaFollows.var = 255
	state = self.index
end

function Menu:close()
	self:kill()
	self:clearAll()
end