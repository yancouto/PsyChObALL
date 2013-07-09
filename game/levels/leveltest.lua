name = "Test Level"
fullName = "0 - The Test"

function run()
	warnEnemies = true
	warnEnemiesTime = 0.8

	wait(2)
	local topbot = formation {
		type = 'vertical',
		shootatplayer = true,
		speed = 300,
		from = 'top',
		movetorwards = 'center',
		distance = 'distribute'
	}
	enemy('simpleball', 6, topbot)
	topbot.from = 'bottom'
	enemy('simpleball', 6, topbot)

	local leftright = formation {
		type = 'horizontal',
		shootatplayer = true,
		speed = 300,
		from = 'left',
		movetorwards = 'center',
		distance = 'distribute'
	}
	enemy('simpleball', 4, leftright)
	leftright.from = 'right'
	enemy('simpleball', 4, leftright)

	wait(5)


	local f1 = formation {
		type = 'horizontal',
		from = 'left',
		movetorwards = 'down',
		distance = 42,
		startsat = 20,
		setspeedto = vector:new{300,0}
	}
	local f2 = formation {
		type = 'vertical',
		from = 'top',
		movetorwards = 'right',
		distance = 42,
		startsat = 20,
		setspeedto = vector:new{0, 300}
	}
	enemy('grayball', 11, f2)
	f2.movetorwards = 'left'
	f2.startsat = width - 20
	enemy('grayball', 11, f2)
	f2.from = 'bottom'
	f2.setspeedto.y = -300
	enemy('grayball', 11, f2)
	f2.movetorwards = 'right'
	f2.startsat = 20
	enemy('grayball', 11, f2)

	enemy('grayball', 7, f1)
	f1.movetorwards = 'up'
	f1.startsat = height - 20
	enemy('grayball', 7, f1)
	f1.from = 'right'
	f1.setspeedto.x = -300
	enemy('grayball', 7, f1)
	f1.movetorwards = 'down'
	f1.startsat = 20
	enemy('grayball', 7, f1)


	local f = formation {
		type = 'horizontal',
		from = 'left',
		movetorwards = 'center',
		setspeedto = vector:new{0, 0},
		distance = 'distribute'
	}
	
	for i = 1, 7 do
		wait(.8)
		f.from = 'left'
		f.setspeedto.x = 300
		enemy('grayball', i, f)
		f.from = 'right'
		f.setspeedto.x = -300
		enemy('grayball', i, f)
	end
	for i = 7, 1, -1 do
		wait(.8)
		f.from = 'left'
		f.setspeedto.x = 300
		enemy('grayball', i, f)
		f.from = 'right'
		f.setspeedto.x = -300
		enemy('grayball', i, f)
	end

	warnEnemies = false
	wait(10)
	enemy('superball', 1, nil, 'superball', 'superball', 'superball')
end