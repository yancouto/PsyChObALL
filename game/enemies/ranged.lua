ranged = Body:new {
	size =  30,
	divideN = 3,
	angle = 0,
	anglechange = nil,
	life = 5,
	timeout = 10,
	timeToShoot = 1,
	spriteBatch = false,
	shader = base.circleShader,
	ord = 6,
	__type = 'ranged'
}

Body.makeClass(ranged)

function ranged:__init()
	if not self.target then Enemy.__init(self) end
	self.target = self.target or Vector:new{math.random(width), math.random(height)}
	self.speed:set(self.target):sub(self.position):normalize():mult(1.3*v, 1.3*v)
	self.prevdist = self.position:distsqr(self.target)
	self.onLocation = false
	self.anglechange = self.anglechange or base.toRadians(360/self.divideN)
	self.shotcircle = CircleEffect:new{
		coloreffect = self.shot.coloreffect,
		size = self.size + 4,
		position = self.position,
		index = false,
		sizeGrowth = 0,
		alpha = 255,
		linewidth = 5
	}
	self.timeout = Timer:new {
		timelimit = self.timeout,
		onceonly = true,
		funcToCall = function()
			if self.shoottimer then self.shoottimer:stop() end
			self.speed:set(self.exitposition):sub(self.position):normalize():mult(1.3*v, 1.3*v)
		end
	}
end

function ranged:onInit( num, target, pos, exitpos, shot, initialcolor, angle, timeout)
	self.timeout = timeout
	self.angle = angle or 0
	self.basecolor = initialcolor or {0, 255, 0}
	self.colorvars = {VarTimer:new{var = self.basecolor[1]}, VarTimer:new{var = self.basecolor[2]}, VarTimer:new{var = self.basecolor[3]}}
	self.coloreffect = ColorManager.ColorManager.getColorEffect(unpack(self.colorvars))
	self.divideN = num or self.divideN
	self.shot = shot and enemies[shot] or enemies.simpleball
	if not pos then Enemy.__init(self)
	else self.position = base.clone(pos) end
	self.exitposition = base.clone(exitpos) or self.position:clone()
	self.target = base.clone(target)
end

function ranged:start()
	Body.start(self)
	CircleEffect.bodies[self] = self.shotcircle
end

ranged.draw = base.defaultDraw

function ranged:update( dt )
	Body.update(self, dt)

	if not self.onLocation then
		local curdist = self.position:distsqr(self.target)
		if curdist < 1  or curdist > self.prevdist then
			self.timeout:start()
			self.speed:reset()
			self.onLocation = true
			self.prevdist = nil
			self.shoottimer = Timer:new {
				timelimit  = self.timeToShoot,
				running = true,
				funcToCall = function() self:shoot() end
			}
		else
			self.prevdist = curdist
		end
	end

	for _, v in pairs(Shot.bodies) do
		if self:collidesWith(v) then
			self:manageShotCollision(v)
			break
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.life == 0
end

function ranged:manageShotCollision( shot )
	shot.collides = true
	shot.explosionEffects = false
	self.life = self.life - 1
	self.colorvars[1].var = self.basecolor[1] - ((ranged.life - self.life) / ranged.life) * (self.basecolor[1] - 255)
	self.colorvars[2].var = self.basecolor[2] - ((ranged.life - self.life) / ranged.life) * self.basecolor[2]
	self.colorvars[3].var = self.basecolor[3] - ((ranged.life - self.life) / ranged.life) * self.basecolor[3]
	self.diereason = shot.isUltraShot and 'ultrashot' or 'shot'
end

function ranged:shoot()
	local ang = self.angle + base.toRadians(180)
	local speed = self.setspeed or 1.5*v
	for i = 1, self.divideN do
		local e = self.shot:new{}
		e.position = self.position:clone()
		e.speed = Vector:new{math.sin(ang)*speed, math.cos(ang)*speed}
		ang = ang + self.anglechange
		e:register()
	end
end

function ranged:handleDelete()
	Body.handleDelete(self)
	neweffects(self, 30)
	self.shotcircle.size = -1
	self.timeout:remove()
	if self.diereason == "shot" then
		addscore(25*self.divideN)
		self.divideN = self.divideN + 3	
		self.anglechange = base.toRadians(360/self.divideN)
		self:shoot()
	end
	if self.shoottimer then self.shoottimer:remove() end
end