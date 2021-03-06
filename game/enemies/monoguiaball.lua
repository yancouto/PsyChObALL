monoguiaball = body:new {
	size =  25,
	divideN = 3,
	args = {},
	coloreffect = getColorEffect(20, 140, 0),
	__type = 'monoguiaball'
}

function monoguiaball:__init()
	if not rawget(self.position, 1) then enemy.__init(self) end
end

function monoguiaball:update( dt )
	body.update(self, dt)

	for _, v in pairs(shot.bodies) do
		if not v.collides and self:collidesWith(v) then
			self.collides = true
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
			break
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.collides
end

function monoguiaball:handleDelete()
	neweffects(self, 20)
	if self.diereason ~= "shot" then return end
	addscore(100)
	--local ang = math.atan2(self.Vx, self.Vy)
	local speed = self.speed:length()
	for i = 1, self.divideN do
		local e = (self.divideType or enemies.multiball):new(lux.object.clone(self.args))
		e.size = self.size - 6
		e.position:set(self.position):add(math.random(self.size), math.random(self.size))
		e.speed:set(self.speed):add((math.random() - .5)*v*1.9, (math.random() - .5)*v*1.9):normalize():mult(v + 40 ,v + 40)
		if math.abs(e.Vy) + math.abs(e.Vx) < 40 then e.Vy = sign(self.Vy) * math.random(3 * v / 4, v) end
		e:register()
		--[[e.size = self.size - 10
		e.position:set(self.position)
		local angle = ang + (math.random() - .5)*torad(60)
		e.speed:set(math.sin(angle)*speed*1.3, math.cos(angle)*speed*1.3)
		e:register()]]
	end
end