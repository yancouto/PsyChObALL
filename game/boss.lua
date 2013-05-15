require 'body'

boss = body:new {
	size = 40,
	variance = 13,
	__type = 'boss'
}

function boss:__init()
	self.position = vector:new {50, 50}
	self.speed	  = vector:new {-math.random(v,v+50), -math.random(v,v+50)}
	self.shoottimer = timer:new {
		timelimit = 1,
		works_on_gamelost = false
	}
	function self.shoottimer.funcToCall()
		local e = enemy:new{}
		e.position = self.position:clone()
		local pos = psycho.position:clone()
		if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
		e.speed = (pos:sub(self.position)):normalize():mult(2 * v, 2 * v)
		table.insert(enemy.bodies,e)
	end
end

function boss:draw()
	graphics.setColor(color(self.color, self.variance + colortimer.time))
	graphics.circle(self.mode, self.x, self.y, self.size)
end

function boss:update(dt)
	boss:__super().update(self, dt)
	if self.x  + self.size > width then self.speed:set(-math.abs(self.Vx))
	elseif self.x - self.size < 0  then self.speed:set( math.abs(self.Vx)) end

	if self.y + self.size > height then self.speed:set(nil, -math.abs(self.Vy))
	elseif self.y - self.size < 0  then self.speed:set(nil,  math.abs(self.Vy)) end
end