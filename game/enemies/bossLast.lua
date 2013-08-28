bossLast = Body:new{
	size = 100,
	width = 200,
	height = 200,
	variance = 5,
	visible = true,
	maxhealth = 10,
	collides = true,
	ord = 8,
	angle = nil, --VarTimer
	__type = 'bossLast'
}

Body.makeClass(bossLast)

function bossLast:draw()
	if not self.visible then return end
	graphics.setPixelEffect()
	graphics.push()
	graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time + self.variance, self.alphafollows.var, self.coloreffect))
	graphics.translate(self.x, self.y)
	graphics.rotate(self.angle.var)
	graphics.rectangle(self.mode, -self.width/2, -self.height/2, self.width, self.height)
	graphics.pop()
	graphics.setPixelEffect(base.circleShader)
end

function bossLast:update( dt )
	Body.update(self, dt)
	if not self.visible then return end

	if self.collides then
		if self.x  + self.size > width then self.speed:set(-math.abs(self.Vx))
		elseif self.x - self.size < 0  then self.speed:set( math.abs(self.Vx)) end

		if self.y + self.size > height then self.speed:set(nil, -math.abs(self.Vy))
		elseif self.y - self.size < 0  then self.speed:set(nil,  math.abs(self.Vy)) end
	end

	for _, s in pairs(Shot.bodies) do
		if self:collidesWith(s) then
			s.collides = true
			s.explosionEffects = true
			if self.health > 0 then
				self.health = self.health - 1
				local d = self.health/bossLast.maxhealth
				self.colorchange.var = 255*d
				--stuff
			end
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end
end

function bossLast.getShot()
	return enemies.multiball:new{}
end

function bossLast:__init()
	self.position:set(width/2, height/2)
	self.angle = VarTimer:new{var = 0}
	self.visible = false
	self.alphafollows = VarTimer:new{var = 0}
	self.health = bossLast.maxhealth
	self.colorchange = VarTimer:new{var = 255}
	self.coloreffect = ColorManager.ColorManager.getColorEffect({var = 255}, {var = 0}, {var = 0}, self.colorchange)

	local components = {{},{},{},{}}
	local updateFunc =  function (e, dt)
			enemies.grayball.update(e, dt)
			if not e.inBox and base.collides(e, self) then e.inBox = true end
			if not e.inBox then return end
			if e.x  + e.size > width/2 + 120 then e.speed:set(-math.abs(e.Vx))
			elseif e.x - e.size < width/2 - 120 then e.speed:set( math.abs(e.Vx)) end

			if e.y + e.size > height/2 + 120 then e.speed:set(nil, -math.abs(e.Vy))
			elseif e.y - e.size < height/2 - 120 then e.speed:set(nil,  math.abs(e.Vy)) end
		end
	local ballsalpha = VarTimer:new{var = 255}
	for i = 1, 160 do
		local e = enemies.grayball:new{}
		e.coloreffect = base.doNothing
		e.variance = 5
		e.alphafollows = ballsalpha
		e.update = updateFunc
		e:register()
		components[math.floor((i-1)/40) + 1][((i-1) % 40) + 1] = e
	end
	local f = formations.around:new{
		angle = 0,
		target = Vector:new{width/2, height/2},
		anglechange = base.toRadians(20),
		distance = 80,
		adapt = false,
		speed = 1.1*v,
		shootattarget = true
	}
	f:applyOn(components[1])
	f.angle = 3*math.pi/2
	f:applyOn(components[2])
	f.anglechange = - f.anglechange
	f.angle = math.pi
	f:applyOn(components[3])
	f.angle = math.pi/2
	f:applyOn(components[4])

	self.shoottimer = Timer:new {
		timelimit = .5,
		works_on_gamelost = false,
		funcToCall = function()
			local e = self.getShot()
			e.position = self.position:clone()
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = (pos:sub(self.position)):normalize():add(math.random()/3, math.random()/3):normalize():mult(2 * v, 2 * v)
			e:register()
		end
	}

	Timer:new{
		timelimit = .2,
		running = true,
		funcToCall = function(timer)
			if components[1][40].inBox then
				timer:remove()
				self.visible = true
				self.alphafollows:setAndGo(0, 255, 60)
				ballsalpha:setAndGo(255, 0, 30)
				ballsalpha.alsoCall = function(timer)
					timer.alsoCall = nil
					for i = 1, 4 do
						for _, b in ipairs(components[i]) do
							b.delete = true
						end
					end
					timer:new{timelimit = 1.2, onceonly = true, running = true, funcToCall = function() 
						self.speed:set(v/7, 3*v)
						self.shoottimer:start()
					end}
				end
			end
		end
	}
end

local auxVec = Vector:new{}
local auxVec2 = Vector:new{}

function bossLast:collidesWith( pos, size ) --rectangle with circle
	if not size then
		size = pos.size
		pos = pos.position
	end

	auxVec:set(pos):sub(self.position):rotate(-self.angle.var):add(self.position)
	auxVec2:set(
		math.max(math.min(auxVec[1], self.position[1] + self.width/2), self.position[1] - self.width/2),
		math.max(math.min(auxVec[2], self.position[2] + self.height/2), self.position[2] - self.height/2)
	)
	return base.collides(auxVec, 0, auxVec2, size)
end