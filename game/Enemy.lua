Enemy = Body:new {
	collides = false,
	diereason = 'leftscreen',
	size = 16,
	shader = Base.circleShader,
	bodies = {},
	__type = 'Enemy'
}

Body.makeClass(Enemy)

local sides = {top = 1, up = 1, bottom = 2, down = 2, left = 3, right = 4}

function Enemy:__init()
	self.variance = math.random(ColorManager.colorCycleTime * 1000) / 1000

	local side = self.side and sides[self.side] or math.random(4)
	if	side == 1 or side == 2 then -- top or bottom
		self.x = math.random(self.size, width - self.size)
		self.y = side == 1 and 0 or height
		self.Vy = math.random(v, v + 50) * (side == 1 and 1 or -1)
		local n = -1
		if self.x < width / 2 then n = 1 end
		self.Vx = n * math.random(0, v)
	elseif side == 3 or side == 4 then -- left or right
		self.x = side == 3 and 0 or width
		self.y = math.random(self.size, height - self.size)
		self.Vx = math.random(v, v + 50) * (side == 3 and 1 or -1)
		local n = -1
		if self.y < height / 2 then n = 1 end
		self.Vy = n * math.random(0, v)
	end
end

function Enemy.init()
	Enemy.list = List:new{}

	Enemy.addtimer = Timer:new {
		timelimit = 2,
		persistent = true
	}

	function Enemy.addtimer:funcToCall() --adds the enemies to a list
		self.timelimit = .8 + (self.timelimit - .8) / 1.09
		Enemy.list:push(Enemy:new{})
	end

	function Enemy.addtimer:handleReset()
		self:stop()
	end

	Enemy.releasetimer = Timer:new {
		timelimit = 2,
		persistent = true
	}

	function Enemy.releasetimer:funcToCall() --actually releases the enemies on screen
		self.timelimit = .8 + (self.timelimit - .8) / 1.09
		local e = Enemy.list:pop()
		if e then e:register()
		else print 'Enemy missing' end
	end

	function Enemy.releasetimer:handleReset()
		self:stop()
	end
end

function Enemy:handleDelete()
	Body.handleDelete(self)
	if self.diereason == "shot" then
		RecordsManager.addScore(self.size / 3)
		Effect.createEffects(self, 23)
		RecordsManager.addMultiplier(self.size / 30)

		if self.size >= 15 then 
			CircleEffect:new{
				based_on = self,
				linewidth = 7,
				alpha = 80,
				sizeGrowth = 600, 
				maxsize = width
			} 
		end
	else
		Effect.createEffects(self, 4)
	end

	if self.size >= 10 then
		local times = self.size >= 15 and 3 or 2
		local size  = self.size >= 15 and self.size/3 + 5 or 6
		for i = 1, times do
			local e = Enemy:new{
				size = size
			}
			e.position:set(self.position):add(math.random(self.size), math.random(self.size))
			e.speed:set(self.speed):add((math.random() - .5)*v*1.9, (math.random() - .5)*v*1.9):normalize():mult(v + 40 ,v + 40)
			if e.Vy + e.Vx < 10 then e.Vy = Base.sign(self.Vy) * math.random(3 * v / 4, v) end
			e.variance = self.variance
			e:register()
		end
	end
end

function Enemy:update(dt)
	Body.update(self, dt)
	
	for i,v in pairs(Shot.bodies) do
		if self:collidesWith(v) then
			self.collides = true
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
			break
		end
	end

	if not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end

	self.delete = self.delete or self.collides
end
