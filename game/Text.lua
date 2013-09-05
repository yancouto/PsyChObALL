Text = Body:new {
	text = 'notext',
	size = 20,
	ord = 6,
	printmethod = graphics.print,
	__type = 'Text',
	spriteBatch = false,
	mode = 'none',
	bodies = {}
}

Body.makeClass(Text)

function Text:__init()
	self.font = self.font or getFont(self.size)
	self.variance = rawget(self, 'variance') or math.random(ColorManager.colorCycleTime*1000)/1000
end

function Text:draw()
	graphics.setColor(ColorManager.getComposedColor(self.variance, self.alpha or self.alphaFollows and self.alphaFollows.var, self.coloreffect))
	graphics.setFont(self.font)
 	self.printmethod(self.text, self.position[1], self.position[2], self.limit, self.align)
end