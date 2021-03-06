--use this to change variables with time
vartimer = timer:new {
	persistent = true,
	var = 0,
	limit = 100,
	backwards = false,
	speed = 100,
	pausable = true
}

function vartimer:funcToCall( dt )
	if self.backwards then
		if self.var > self.limit then 
			self.var = self.var - self.speed*dt
		else
			self.var = self.limit
			self:stop()
			if self.alsoCall then self:alsoCall() end
		end
	else
		if self.var < self.limit then 
			self.var = self.var + self.speed*dt
		else
			self.var = self.limit
			self:stop()
			if self.alsoCall then self:alsoCall() end
		end
	end
end

function vartimer:set( starts, ends, speed )
	self.var = starts or self.var
	self.limit = ends or self.limit
	self.backwards = self.limit < self.var
	self.speed = speed or self.speed
end

function vartimer:setAndGo( ... )
	self:set(...)
	self:start()
end