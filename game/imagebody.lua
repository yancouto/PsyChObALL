ImageBody = Body:new {
	image = nil,
	bodies = {},
	scale = 1,
	spriteBatch = false,
	mode = 'none',
	__type = 'ImageBody'
}

Body.makeClass(ImageBody)

function ImageBody:__init()
	assert(self.image, 'ImageBody needs an image!')
	self.size = math.max(self.image:getWidth(), self.image:getHeight())*self.scale
end

function ImageBody:draw()
	graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
	graphics.draw(self.image, self.position[1], self.position[2], 0, self.scale, self.scale)
end