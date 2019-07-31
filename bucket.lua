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
	x = 0,
	y = 0,
	width = 8,
	height = 8,
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
		player.x = player.x - 1
		player.dir = 1
	end
	if (btn(3)) then -- right
		player.x = player.x + 1
		player.dir = 0
	end
	if (btn(0)) then -- down
		player.y = player.y - 1
	end
	if (btn(1)) then -- up
		player.y = player.y + 1
	end

	-- make sure the player is still onscreen
	player.x = math.max(player.x, 0)
	player.x = math.min(player.x, screenwidth - player.width)
	player.y = math.max(player.y, 0)
	player.y = math.min(player.y, screenheight - player.height)
end

-- draw player sprite
function playerdraw()
	spr(1, player.x, player.y, 0, 1, player.dir, 0)
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
