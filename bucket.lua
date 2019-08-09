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
	pos = { x = 0, y = 0 },
	dim = { w = 8, h = 8 },
	dir = 0, -- 0 = right, 1 = left
	velo = { x = 0, y = 0 },
	accl = { x = 0, y = 0 },
	state = {
		health = 10,
		charges = 0
	},
	sprite = 0, -- which sprite the player is currently displaying
	anim = "walk",  -- current animation
	anim_idx = 1, -- which frame of the anim we're on
	anim_ticks = 1, -- how many ticks on this frame are left
	anims = { -- list of player animations
		["stand"] = { ticks=1, frames={0} },
		["walk"] = { ticks=4, frames={1,2,3,4,5} },
		["jump"] = { ticks=2, frames={17, 16} },
		["midair"] = { ticks=1, frames={16} },
		["slide"] = { ticks=1, frames={18} }
	},
	set_anim = function(self, new_anim)
		self.anim = new_anim
	end,
	update_anim = function(self)
		self.anim_ticks = self.anim_ticks - 1
		if self.anim_ticks <= 0 then
			if self.anim_idx == #self.anims[self.anim].frames then
				self.anim_idx = 1
			else
				self.anim_idx = self.anim_idx + 1
			end
			self.anim_ticks = self.anims[self.anim].ticks
		end
  end,
	set_sprite = function(self)
		self.sprite = self.anims[self.anim].frames[anim_idx]
  end
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
	-- print(string.format("a_idx=%d,spr=%d,a_tx=%d,anim=%s",
	print(string.format("a_idx=%d,a_tx=%d,anim=%s",
		-- player.anim_idx, player.sprite, player.anim_ticks, player.anim), 10, 4, 7)
		player.anim_idx, player.anim_ticks, player.anim), 10, 4, 7)
	playerdraw()
end

--- ##### input parsing #####

inputs = {
	l = true,
	r = true,
	jump = true,
	bash = true
}

function get_inputs()
	if btn(2) then inputs.l = true end
	if btn(3) then inputs.r = true end
	if btnp(4, 6, 60) then inputs.jump = true end
	if btnp(5, 6, 60) then inputs.bash = true end
end

function clear_inputs()
	inputs.l = false
	inputs.r = false
	inputs.jump = false
	inputs.bash = false
end

-- handle button inputs
function playercontrol()
	clear_inputs()
	get_inputs()
	player:update_anim()
	player:set_sprite()
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
	spr(player.sprite, player.pos.x, player.pos.y, 0, 1, player.dir, 0)
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
