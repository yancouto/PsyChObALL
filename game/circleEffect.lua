require 'body'

circleEffect = body:new {
	alpha = 10,
	maxsize = width/1.9,
	__type = 'circle'
}

function circleEffect:__init()
	if self.based_on then --circle to be based on
		self.position = self.based_on.position:clone{}
		self.size = self.based_on.size
		self.based_on = nil
	end
	
	self.sizeGrowth = self.sizeGrowth or math.random(120,160)		
	self.variance = math.random(30,300)/100
	if table.getn(circleEffect.bodies) > 250 then table.remove(circleEffect.bodies,1) end
	table.insert(circleEffect.bodies,self)
end

function circleEffect:draw()
    if self.linewidth then love.graphics.setLine(self.linewidth) end
    love.graphics.setColor(color(colortimer.time*self.variance,nil,self.alpha))
    love.graphics.circle('line',self.x,self.y,self.size)
    if self.linewidth then love.graphics.setLine(4) end
end

function circleEffect:update(dt)
    self.size = self.size + self.sizeGrowth*dt
    return self.size<self.maxsize
end