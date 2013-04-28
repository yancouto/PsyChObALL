require "circleEffect"
require "effect"
require "enemy"
require "shot"
require "timer"
require "list"

function rbesttime()
    local file = filesystem.newFile("high")
    if not filesystem.exists("high") then
        file:open('w')
        file:write("0\n0")
        file:close()
    end
    file:open('r')
    local it = file:lines()
    local r = it()
    if not r then r=0 end
    besttime = 0 + r
    r= it()
    if not r then r=0 end
    bestmult = 0 + r
end



function wbesttime()
    local file = filesystem.newFile("high")
    file:open('w')
    if totaltime>besttime then besttime = totaltime end
    file:write(besttime .. "\n" .. bestmult)
    file:close()
end

function love.load()
	for k,v in pairs(love) do
		if type(v)== 'table' and not _G[k] then
			_G[k] = v
		end
	end

	width, height = graphics.getWidth(),graphics.getHeight()

    screenshotnumber = 1
	while(filesystem.exists('screenshot_' .. screenshotnumber .. '.png')) do screenshotnumber = screenshotnumber + 1 end

	v = 220
    version = "0.8.0 dev"
	timer.ts = {}
	filesystem.setIdentity("PsyChObALL")
	song = audio.newSource("resources/Phantom - Psychodelic.ogg")
	song:play()
	song:setLooping(true)
	songsetpoints = {20,123,180,308,340}
	songfadeout = timer.new(.01,function(self) 
	        if song:getVolume()<=.02 then 
	            song:setVolume(0) 
	            self:stop()
	        else song:setVolume(song:getVolume()-.02) end
	 end,false,false,false,false,true)
	 songfadein = timer.new(.03,function(self) 
	        if song:getVolume()>=.98 then 
	            song:setVolume(1) 
	            self:stop()
	        else song:setVolume(song:getVolume()+.02) end
	 end,false,false,false,false,true)
	colortimer = timer.new(10,nil,true,false,false,true,true)

	reload() -- reload()-> things that should be resetted when player dies, the rest-> one time only
	
	sqr2 = math.sqrt(2)
	fonts = {}
	
	firsttime = true
	rbesttime()
	
	
	
	
	currentPE = nil
	currentPET = nil
	noLSD_PET = graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = Texel(texture, texture_coords) * color;
            return vec4((cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, cor_final[3]);
        }
    ]]
    noLSD_PE = graphics.newPixelEffect[[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = color;
            return vec4((cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, cor_final[3]);
        }
    ]]
	invertPET = graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = Texel(texture, texture_coords) * color;
            return vec4(1-cor_final[0],1-cor_final[1],1-cor_final[2], cor_final[3]);
        }
    ]]
    invertPE = graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = color;
            return vec4(1-cor_final[0],1-cor_final[1],1-cor_final[2], cor_final[3]);
        }
    ]]
	
	multtimer = timer.new(2.2,function() multiplier = 1 end,false,true,true,true,true,function(self) self:stop() self.func(self) end)
	inverttimer = timer.new(2.2,function()
	     if currentPE ~= noLSD_PE then 
	        song:setPitch(1)
		timefactor = 1.0
			currentPE = nil 
	        currentPET = nil 
	    end
	end,false,true,true,true,true,function(self) self:stop() self.func(self) end)
	
end

function reload()
	timer.closenonessential()
	
	song:seek(songsetpoints[math.random(#songsetpoints)])
	song:setVolume(0)
	songfadein:start()
	
	circle = {}
	circle.x,circle.y = relative(380,300)
	circle.Vx = 0
	circle.Vy = 0
	circle.size = 23
	function circle:update(dt)
		self.x = self.x + 1.65*self.Vx*dt
		self.y = self.y + 1.65*self.Vy*dt
		for i,v in pairs(enemy.bodies) do
			if (v.size+self.size)*(v.size+self.size)>=(v.x-self.x)*(v.x-self.x)+(v.y-self.y)*(v.y-self.y) then
				lostgame()
				self.diereason = "shot"
			elseif (self.collides or self.x<-self.size or self.y<-self.size or self.x+self.size>graphics.getWidth() or self.y+self.size> graphics.getHeight()) then
				self.diereason = "leftbounds"
				lostgame()
			end
		end
	end
	
	paintables = {}
	shot.bodies = {}
	effect.bodies = {}
	circleEffect.bodies = {}
	enemy.bodies = {}
	paintables[1] = circleEffect.bodies
	paintables[2] = shot.bodies
	paintables[3] = enemy.bodies
	paintables[4] = effect.bodies
	
	enemylist = list.new()
	enemylist:push(enemy.new())
	enemytimer = timer.new(1,function(self)
	        if not self.first then self.first = true self.timelimit = 2 end
			self.timelimit = .3 + (self.timelimit-.3)/1.09
			enemylist:push(enemy.new())
		end)
	enemytimer2 = timer.new(0,function(self)
			if not self.first then self.first = true self.timelimit = 2 return end
			self.timelimit = .3 + (self.timelimit-.3)/1.09
			table.insert(enemy.bodies,enemylist:pop())
		end)
	
	shottimer = timer.new(.18,function() shoot(mouse.getPosition()) end,false)
	
	multiplier = 1
	
	
	circletimer = timer.new(.2,function()
			circleEffect.new(circle)
			for i,v in pairs(enemy.bodies) do
				if v.size>=10 then circleEffect.new(v) end
			end
		end)
	
	totaltime = 0
	
	timefactor = 1.0
	
	score = 200

	pause = false
	gamelost = false
	esc = false

	srt = " " --random string to be painted
	dtn = nil
end

function getFont(size)
	if fonts[size] then return fonts[size] end
	fonts[size] = graphics.newFont(size)
	return fonts[size]
end

function relative(x,y)
	return x*width/800,y*height/600
end

function lostgame()
    wbesttime()
    songfadeout:start()
	if deathText()=="The LSD wears off" then
	    song:setPitch(.8)
		deathtexts[11] = "MOAR LSD"
		currentPE = noLSD_PE
		currentPET = noLSD_PET
	elseif deathText()=="MOAR LSD" then
	    song:setPitch(1)
	    deathtexts[11] = "The LSD wears off"
		currentPE = nil 
		currentPET = nil
	end

    gamelost = true
end

function color(x,xt,alpha)
	xt = xt or colortimer.timelimit
	x = x % xt
	local r,g,b
	if x<=xt/3 then
		r = 100 -- 100%
		g = 100*x/(xt/3) -- 0->100%
		b = 0 -- 0%
	elseif x<=xt/2 then
		r = 100*(1 - ((x-xt/3)/(xt/2-xt/3))) -- 100->0%
		g = 100 - 20*((x-xt/3)/(xt/2-xt/3)) --100->80%
		b = 0 -- 0%
	elseif x<=7*xt/12 then
		r = 0 -- 0%
		g = 80 - 20*((x-xt/2)/(7*xt/12-xt/2)) -- 80->60%
		b = 60*((x-xt/2)/(7*xt/12-xt/2)) -- 0->60%
	elseif x<=255*xt/360 then
		r = 11*((x-7*xt/12)/(255*xt/360-7*xt/12)) -- 0->11%
		g = 60 -49*((x-7*xt/12)/(255*xt/360-7*xt/12)) -- 60->11%
		b = 60 + 10*((x-7*xt/12)/(255*xt/360-7*xt/12)) --60->70%
	elseif x<=318*xt/360 then
		r = 11 + 59*((x-255*xt/360)/(318*xt/360-255*xt/360)) -- 11->70%
		g = 11*(1 - ((x-255*xt/360)/(318*xt/360-255*xt/360))) -- 11->0%
		b = 70 - 10*((x-255*xt/360)/(318*xt/360-255*xt/360)) -- 70->60%
	else
		r = 70 + 30*((x-318*xt/360)/(xt-318*xt/360)) -- 70->100%
		g = 0 -- 0%
		b = 60*(1 - ((x-318*xt/360)/(xt-318*xt/360))) --60->0%
	end
	
	return {r*2.55,g*2.55,b*2.55,alpha or 255}
end

function sign(x)
    if x>0 then return 1
    elseif x<0 then return -1
    else return 0 end
end

function line()
	graphics.setColor(color(colortimer.time+12))
	graphics.circle("line",mouse.getX(),mouse.getY(),5)
	graphics.setColor(color(colortimer.time+12,nil,60))
	local m = (mouse.getY()-circle.y)/(mouse.getX()-circle.x)
	local x,y
	if (mouse.getX()-circle.x)>0 then 
		x = graphics.getWidth()
		y = circle.y + (x-circle.x)*m
	else
		x = 0
		y = circle.y + (x-circle.x)*m
	end
	graphics.line(circle.x,circle.y,x,y)
end

function love.draw()
	graphics.setPixelEffect(currentPE) --things without texture
    graphics.setLine(4)
	local bc = color(colortimer.time+17*colortimer.timelimit/13)
	bc[1] = bc[1]/7
	bc[2] = bc[2]/7
	bc[3] = bc[3]/7
    --graphics.setBackgroundColor(bc)
	graphics.setColor(bc)
	graphics.rectangle("fill",0,0,graphics.getWidth(),graphics.getHeight()) --background color
    for i,v in pairs(paintables) do
        for j,m in pairs(v) do
			m:draw()
		end
    end
	graphics.setColor(color(colortimer.time*1.4))
	graphics.setLine(1)
	for i=enemylist.first,enemylist.last-1 do
		local a = math.atan((enemylist[i].Vy/enemylist[i].Vx))
		if enemylist[i].Vx<0 then a = a + math.pi end
		graphics.arc("line", enemylist[i].x, enemylist[i].y, 30, a-.15, a+.15)
	end
	line()
	graphics.setColor(color(colortimer.time))
    graphics.circle("fill", circle.x,circle.y,circle.size)
	
	
    graphics.setPixelEffect(currentPET) --things with textures
    graphics.print(string.format("Score: %.0f",score),relative(20,20))
    graphics.print(string.format("Time: %.1fs",totaltime),relative(20,60))
	graphics.print(srt,relative(20,80))
	graphics.print("FPS: " .. love.timer.getFPS(),relative(740,20))
	graphics.print(string.format("Best Time: %.1fs",math.max(besttime,totaltime)),relative(20,40))
	if multiplier>bestmult then bestmult = multiplier end
	graphics.print(string.format("Best Mult: x%.1f",bestmult),relative(715,86))
	graphics.setFont(getFont(40))
	graphics.print(string.format("x%.1f",multiplier),relative(700,50))
	graphics.setFont(getFont(12))
	
	
	if firsttime then
		graphics.setColor(color(colortimer.time-colortimer.timelimit/2))
		graphics.setFont(getFont(20))
		graphics.print("You get points when:",relative(200,30))
		graphics.print("You kill an enemy",relative(225,60))
		graphics.print("You lose points when:",relative(500,30))
		graphics.print("You miss a shot",relative(525,60))
		graphics.print("You let an enemy escape",relative(525,80))
		graphics.setFont(getFont(30))
		graphics.print("Game Ends when your score hits zero",relative(100,470))
		graphics.setFont(getFont(20))
		graphics.print("Use WASD or arrows to move",relative(150,250))
		graphics.print("Click to shoot",relative(415,325))
		graphics.print("Space for", relative(470,360))
		
		graphics.print("click to continue",relative(650,560))
		graphics.setFont(getFont(12))
		graphics.print("Or when you die.",relative(570,500))
		graphics.print("v" .. version,relative(750,580))
		
		graphics.setFont(getFont(35))
		graphics.setColor(color(colortimer.time*0.856))
		graphics.print("ulTrAbLaST",relative(545,349))
		graphics.setFont(getFont(12))
	end
	if gamelost then
		graphics.setColor(color(colortimer.time-colortimer.timelimit/2))
		if besttime == totaltime then
			graphics.setFont(getFont(60))
			graphics.print("You beat the best time!",relative(100,100))
		end
		graphics.setFont(getFont(40))
		graphics.print(deathText(),relative(200,250))
		graphics.setFont(getFont(30))
		graphics.print(string.format("You lasted %.1fsecs",totaltime),relative(360,440))
		if score==0 then graphics.print("Your score hit 0.",relative(320,500)) end
		graphics.setFont(getFont(22))
		graphics.print("'r' to retry",relative(400,400))
		graphics.setFont(getFont(12))
	end
	if esc then
		graphics.setColor(color(colortimer.time-colortimer.timelimit/2))
		graphics.setFont(getFont(40))
		graphics.print("Paused",relative(200,250))
		graphics.setFont(getFont(12))
	end
end

deathtexts = {"Game Over", "No one will\n miss you","You now lay\n   with the dead","Yo momma so fat\n   you died",
"You ceased to exist","Your mother\n   wouldn't be proud","Snake? Snake?\n   Snaaaaaaaaaake","Already?",
"All your base\n are belong to BALLS","You wake up and\n realize it was all a nightmare","The LSD wears off",
"MIND BLOWN","Just one more","USPGameDev Rulez","A winner is not you","Have a nice death","There is no cake\n   also you died"}
function deathText()
	dtn = dtn or deathtexts[math.random(table.getn(deathtexts))]
	return dtn
end

function love.update(dt)
	isPaused = (gamelost or esc or pause or firsttime) 
	if score<=0 then score=0 lostgame() end
	
	
	timer.update(dt,timefactor,isPaused)
	
	dt = dt*timefactor
	
	if isPaused then return end
	totaltime = totaltime+dt

    circle:update(dt)
    local todelete = {}
    for i,v in pairs(paintables) do
        for j,m in pairs(v) do
			if not m:update(dt) then
			table.insert(todelete,j)
			end
		end
		local a=0
		for k,n in ipairs(todelete) do
			v[n-a]:handleDelete()
			table.remove(v,n-a)
			a = a+1
		end
		todelete = nil
		todelete = {}
    end
	todelete = nil
end

function love.mousepressed(x,y,button)
    if esc or pause then return end
    if firsttime then firsttime = false return end
    if button == 'l' then
        shoot(x,y)
		shottimer:start()
    end
end
function love.mousereleased(x,y,button)
	if button == 'l' then
		shottimer:stop()
	end
end

function shoot(x,y)
	local diffx = x - circle.x
    local diffy = y - circle.y
    local Vx = signum(diffx)*math.sqrt((9*v*v*diffx*diffx)/(diffx*diffx + diffy*diffy))
    local Vy = signum(diffy)*math.sqrt((9*v*v*diffy*diffy)/(diffx*diffx + diffy*diffy))
    table.insert(shot.bodies, shot.new(circle.x,circle.y,Vx,Vy))
end

function signum(a)
    if a>0 then return 1
    elseif a<0 then return -1
    else return 0 end
end

local ultrablast = 25

function love.keypressed(key,code)
	
	if (key=='escape' or key=='p') and not gamelost then esc = not esc end

    if key=='w' or key == 'up' then 
        circle.Vy = -v
        if circle.Vx~=0 then circle.Vy = circle.Vy/sqr2 circle.Vx = circle.Vx/sqr2 end
    elseif key=='s' or key == 'down' then 
        circle.Vy = v
        if circle.Vx~=0 then circle.Vy = circle.Vy/sqr2 circle.Vx = circle.Vx/sqr2 end
    elseif key=='a' or key=='left' then 
        circle.Vx = -v
        if circle.Vy~=0 then circle.Vx = circle.Vx/sqr2 circle.Vy = circle.Vy/sqr2 end
    elseif key=='d' or key=='right' then 
        circle.Vx = v 
        if circle.Vy~=0 then circle.Vx = circle.Vx/sqr2 circle.Vy = circle.Vy/sqr2 end
    end
	
	if key==' ' and not isPaused then
		for i=1,ultrablast do
			shoot(circle.x+(math.cos(math.pi*2*i/ultrablast)*100),circle.y+(math.sin(math.pi*2*i/ultrablast)*100))
		end
	end
	
	if gamelost and key=='r' then
		local x,y
		if circle.diereason == "shot" then
			x = circle.x
			y = circle.y
		end
		reload()
		circle.x = x or circle.x
		circle.y = y or circle.y
	end
end

function love.keyreleased(key,code)
    if ((key=='w'or key=='up') and (keyboard.isDown('s') or keyboard.isDown('down')))then
        circle.Vy = math.abs(circle.Vy)
    elseif ((key=='s'or key=='down') and (keyboard.isDown('w') or keyboard.isDown('up'))) then
        circle.Vy = -math.abs(circle.Vy)
    elseif ((key=='a'or key=='left') and (keyboard.isDown('d') or keyboard.isDown('right'))) then
        circle.Vx = math.abs(circle.Vx)
    elseif  ((key=='d'or key=='right') and (keyboard.isDown('a') or keyboard.isDown('left'))) then
        circle.Vx = -math.abs(circle.Vx)
    end
    
    if (key=='w' or key=='s' or key=='up' or key=='down') and 
            not (keyboard.isDown('w') or keyboard.isDown('s') or 
                keyboard.isDown('up') or keyboard.isDown('down')) then 
		circle.Vy=0
	    circle.Vx = signum(circle.Vx) * v
    elseif (key=='a' or key=='d' or key=='left' or key=='right') and 
            not (keyboard.isDown('a') or keyboard.isDown('d') or 
                keyboard.isDown('left') or keyboard.isDown('right')) then 
	circle.Vx=0 
	circle.Vy = signum(circle.Vy) * v
	end
	
	if key=='scrollock' then 
	    graphics.newScreenshot():encode('screenshot_' .. screenshotnumber .. '.png')
	    screenshotnumber = screenshotnumber + 1
	end
end

function love.focus(f)
    pause = not f
end