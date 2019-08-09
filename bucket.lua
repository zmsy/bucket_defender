-- globals
scene = 0
count = 0
screenwidth = 240
screenheight = 136

controls = {
	rightCount = 0,
	leftCount = 0
}

player = {
	pos = {
		x = 0,
		y = 0
	},
	dim = {
		w = 8,
		h = 8
	},
	dir = 0, -- 0 = right, 1 = left
	velo = {
		x = 0,
		y = 0
	},
	accl = {
		x = 0,
		y = 0
	},
	state = {
		health = 10,
		charges = 0
	}
}

anims = {
	["stand"] = {
		ticks=1,
		frames={0},
	},
	["walk"] = {
		ticks=1,--how long is each frame shown.
		frames={1,2,3,4,5},--what frames are shown.
	},
	["jump"] = {
		ticks=2,
		frames={17, 16},
	},
	["midair"] = {
		ticks=1,
		frames={16},
	},
	["slide"] = {
		ticks=1,
		frames={18},
	}
}

inputs = {
	l = 0,
	r = 0,
	jump = 0,
	bash = 0
}

-- game loop, main function that gets called every frame.
function TIC()
	_update()
	_draw()
end

-- This function runs as soon as the game loads
function _init()
end

function _update()
	if scene == 0 then
		titleupdate()
	elseif scene == 1 then
		gameupdate()
	end
end

function _draw()
	if scene == 0 then
		titledraw()
	elseif scene == 1 then
		gamedraw()
	end
end
-- update functions
function titleupdate()
	if btnp(4) then
		scene = 1
	end
end

function gameupdate()
	count = (count + 1) % 60
	playercontrol()
end

-- draw functions
function titledraw()
	local titletxt = "title screen"
	local starttxt = "press z to start"
	rect(0, 0, screenwidth, screenheight, 3)
	print(titletxt, hcenter(titletxt), screenheight / 4, 10)
	print(starttxt, hcenter(starttxt), (screenheight / 4) + (screenheight / 2), 7)
end

function gamedraw()
	cls(13)

	local gametxt = "game screen"
	map(0, 0, 250, 136, 0, 0)
	print("count: " .. count, 10, 4, 7)
	playerdraw()
end

-- handle button inputs
function playercontrol()
	if (btn(2)) then -- left
		player.pos.x = player.pos.x - 1
		player.dir = 1
	end
	if (btn(3)) then -- right
		player.pos.x = player.pos.x + 1
		player.dir = 0
	end
	if (btn(0)) then -- down
		player.pos.y = player.pos.y - 1
	end
	if (btn(1)) then -- up
		player.pos.y = player.pos.y + 1
	end

	-- make sure the player is still onscreen
	player.pos.x = math.max(player.pos.x, 0)
	player.pos.x = math.min(player.pos.x, screenwidth - player.dim.w)
	player.pos.y = math.max(player.pos.y, 0)
	player.pos.y = math.min(player.pos.y, screenheight - player.dim.h)
end

-- draw player sprite
function playerdraw()
	spr(1, player.pos.x, player.pos.y, 0, 1, player.dir, 0)
end

-- library functions
--- center align from: pico-8.wikia.com/wiki/centering_text
function hcenter(s)
	-- string length times the pixels in a char's width
	-- cut in half and rounded down
	return (screenwidth / 2) - ((#s * 4) // 2)
end

function vcenter(s)
	-- string char's height
	-- cut in half and rounded down
	return (screenheight / 2) - (5 // 2)
end

--- collision check
function iscolliding(obj1, obj2)
	return (obj1.x < (obj2.x + obj2.width) and obj2.x < (obj1.x + obj1.width) and
		obj1.y < (obj2.y + obj2.height) and
		obj2.y < (obj1.y + obj1.height))
end

_init()
