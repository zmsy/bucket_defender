-- globals
scene = 0
count = 0

-- cache inputs for debugging
inputs_cache = {}

-- constants for tinkering with
const = {
	SCREENWIDTH = 240,
	SCREENHEIGHT = 136,
	X_MAX_VELO = 1.0,
	Y_MAX_VELO = 1.8,
	JUMP_VELO = 1.8,
	GRAVITY = 0.135
}

-- player class
player = {
	pos = { x = 0, y = 0 }, -- position
	dim = { w = 8, h = 8 }, -- dimensions
	hbox = { x = 2, y = 0, w = 4, y = 6 }, -- hitbox
	dir = 0, -- 0 = right, 1 = left
	velo = { x = 0.0, x_max = 1.0, y = 0.0, y_max = 1.8 }, -- velocity
	accl = { x = 0, y = 0 }, -- acceleration
	stats = {
		health = 10,
		charges = 0,
	},
	state = { -- tracks player activities
		grounded = true,
		jumping = false,
		moving = false,
		jump_able = true,
		bashing = false,
		bash_able = true
	},

	can_jump = function(self)
		return self.state.grounded and not self.state.jumping
  end,

	can_bash = function(self)
		return not self.state.bashing
	end,

	-- animation information
	sprite = 0, -- which sprite the player is currently displaying
	anim = "walk",  -- current animation
	anim_idx = 1, -- which frame of the anim we're on
	anim_ticks = 1, -- how many ticks on this frame are left
	anim_over = false, -- tracks if the most recent anim ended

	anims = { -- list of player animations
		["stand"] = { ticks=1, frames={0}, loop=true},
		["walk"] = { ticks=4, frames={1,2,3,4,5}, loop=true},
		["jump"] = { ticks=2, frames={17}, loop=false},
		["midair"] = { ticks=1, frames={16}, loop=true},
		["slide"] = { ticks=1, frames={18}, loop=true},
		["bash"] = { ticks=3, frames={32,33,34,35,36,37,38,39,40,41}, loop=false}
	},

	set_anim = function(self, new_anim)
		inputs_str = string.format("anim=%s", tostring(new_anim))
		if self.anim ~= new_anim then
			self.anim = new_anim
			self.anim_idx = 1
		end
	end,

	update_anim = function(self)
		self.anim_ticks = self.anim_ticks - 1
		if self.anim_ticks <= 0 then
			if self.anim_idx == #self.anims[self.anim].frames then
				self.anim_over = true
				self.anim_idx = 1
			else
				self.anim_idx = self.anim_idx + 1
			end
			self.anim_ticks = self.anims[self.anim].ticks
		end
	end,

	set_sprite = function(self)
		self.sprite = self.anims[self.anim].frames[self.anim_idx]
	end,

	-- input handlers
	handle_inputs = function(self, inputs)
		-- xor logical equivalent
		if inputs.l or inputs.r and not inputs.l == inputs.r then
			self.state.moving = false
		elseif inputs.l then
			self.velo.x = math.max(self.velo.x - 1, const.X_MAX_VELO * -1)
			self.state.moving = true
			self.dir = 1
		elseif inputs.r then
			self.state.moving = true
			self.velo.x = math.min(self.velo.x + 1, const.X_MAX_VELO)
			self.dir = 0
		end

		if inputs.jump then
			if self.state.bash_able then
				self.state.jumping = true
				self.state.jump_able = false
		  end
		end
		if inputs.bash then
			if self.state.bash_able then
				self.state.bashing = true
				self.state.bash_able = false
		  end
		end
	end,

  -- check the status flags in the player and update accordingly
	handle_state = function(self)
		-- check for state changes based on animation ending
		if self.anim_over then
			if self.state.jumping then self.state.jumping = false end
			if self.state.bashing then self.state.bashing = false end
			self.anim_over = false
		end

		-- handle player is bashing
		if self.state.bashing then self:set_anim("bash") end

		-- handle player is in the air
		if not self.state.grounded then
			if self.state.jumping then
				self:set_anim("jump")
			else
				self:set_anim("midair")
			end
		else
			if self.state.moving then
				self:set_anim("walk")
			elseif self.velo.x > 0.05 then
				self:set_anim("slide")
			else
				self:set_anim("stand")
		  end
		end

  end,

	move = function(self)
		self.pos.x = self.pos.x + self.velo.x
		self.pos.y = self.pos.y + self.velo.y
  end
}

-- inputs collector class for button presses
function get_inputs()
	local i = { l=false, r=false, jump=false, bash=false }
	if btn(2) then i.l = true end
	if btn(3) then i.r = true end
	if btnp(4) then i.jump = true end
	if btnp(5) then i.bash = true end
	return i
end

-- game loop, main function that gets called every frame.
function TIC()
	_update()
	_draw()
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
	rect(0, 0, const.SCREENWIDTH, const.SCREENHEIGHT, 3)
	print(titletxt, hcenter(titletxt), const.SCREENHEIGHT / 4, 10)
	print(starttxt, hcenter(starttxt), (const.SCREENHEIGHT / 4) + (const.SCREENHEIGHT / 2), 7)
end

function gamedraw()
	cls(13)

	local gametxt = "game screen"
	map(0, 0, 250, 136, 0, 0)
	print(string.format("pos.x=%d,pos.y=%d,l=%s,r=%s",
		player.pos.x, player.pos.y, tostring(inputs_cache.l), tostring(inputs_cache.r)), 10, 4, 7, true)
	playerdraw()
	enemiesDraw()
	particlesDraw()
end

-- handle button inputs
function playercontrol()
	local inputs = get_inputs()
	inputs_cache = inputs
	player:update_anim()
	player:handle_inputs(inputs)
	player:handle_state()
	player:set_sprite()
	player:move()

	-- make sure the player is still onscreen
	player.pos.x = math.max(player.pos.x, 0)
	player.pos.x = math.min(player.pos.x, const.SCREENWIDTH - player.dim.w)
	player.pos.y = math.max(player.pos.y, 0)
	player.pos.y = math.min(player.pos.y, const.SCREENWIDTH - player.dim.h)
end

-- draw player sprite
function playerdraw()
	spr(player.sprite, player.pos.x, player.pos.y, 0, 1, player.dir, 0)
end

-- draw enemies
function enemiesDraw() end

function particlesDraw() end

-- library functions
--- center align from: pico-8.wikia.com/wiki/centering_text
function hcenter(s)
	-- string length times the pixels in a char's width
	-- cut in half and rounded down
	return (const.SCREENWIDTH / 2) - ((#s * 4) // 2)
end

function vcenter(s)
	-- string char's height
	-- cut in half and rounded down
	return (const.SCREENHEIGHT / 2) - (5 // 2)
end

--- collision check
function iscolliding(obj1, obj2)
	return (
		obj1.pos.x < (obj2.pos.x + obj2.dim.w) and
		obj2.pos.x < (obj1.pos.x + obj1.dim.w) and
		obj1.pos.y < (obj2.pos.y + obj2.dim.h) and
		obj2.pos.y < (obj1.pos.y + obj1.dim.h)
	)
end

--- collision check w/ independent hitbox
function iscollidinghbox(obj1, obj2)
	return (
		obj1.pos.x + obj1.hbox.x < (obj2.pos.x + obj2.hbox.x + obj2.hbox.w) and
		obj2.pos.x + obj2.hbox.x < (obj1.pos.x + obj1.hbox.x + obj1.hbox.w) and
		obj1.pos.y + obj1.hbox.y < (obj2.pos.y + obj2.hbox.y + obj2.hbox.h) and
		obj2.pos.y + obj2.hbox.y < (obj1.pos.y + obj1.hbox.y + obj1.dim.h)
	)
end
