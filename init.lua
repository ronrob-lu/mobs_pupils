-- mobs_pupils/init.lua
-- Pupil NPCs for Minetest / Luanti (based on Mobs Redo)
-- License: MIT (ronrob-lu 2026)

mobs_pupils = {}

-- Pupil names pool for natural identity
local pupil_names = {
	"Alex", "Sam", "Emma", "Liam", "Olivia", "Noah", "Ava", "Ethan",
	"Sophia", "Lucas", "Mia", "Jackson", "Isabella", "Oliver", "Charlotte",
	"Aiden", "Amelia", "Elijah", "Harper", "James", "Evelyn", "Benjamin",
	"Abigail", "Mason", "Emily", "Logan", "Ella", "Alexander", "Elizabeth",
	"Jacob", "Sofia", "Michael", "Avery", "Daniel", "Ella", "Henry", "Scarlett"
}

-- Cache toycity nodes if present
local toycity_blocks = {}
if minetest.get_modpath("toycity") then
	for nodename, _ in pairs(minetest.registered_nodes) do
		if nodename:find("^toycity:") then
			table.insert(toycity_blocks, nodename)
		end
	end
end

-- 1. Register School Block
minetest.register_node("mobs_pupils:school_block", {
	description = "School Block",
	tiles = {"mobs_pupils_school_block.png"},
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_stone_defaults and default.node_sound_stone_defaults() or nil,
})

-- 2. Register Home Block
minetest.register_node("mobs_pupils:home_block", {
	description = "Home Block",
	tiles = {"mobs_pupils_home_block.png"},
	groups = {choppy = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_wood_defaults and default.node_sound_wood_defaults() or nil,
})

-- Crafting Recipes for Blocks
if minetest.get_modpath("default") then
	minetest.register_craft({
		output = "mobs_pupils:school_block",
		recipe = {
			{"default:book", "default:book", "default:book"},
			{"default:cobble", "default:cobble", "default:cobble"},
			{"default:wood", "default:wood", "default:wood"},
		}
	})

	minetest.register_craft({
		output = "mobs_pupils:home_block",
		recipe = {
			{"default:wood", "default:wood", "default:wood"},
			{"default:chest", "default:wool_yellow", "default:chest"},
			{"default:wood", "default:wood", "default:wood"},
		}
	})
end

-- Helper: Check if current time is school time (7000 to 12000)
local function is_school_time()
	local timeofday = (minetest.get_timeofday() or 0) * 24000
	return timeofday >= 7000 and timeofday <= 12000
end

-- Helper: Find nearest block by name within radius
local function find_nearest_block(pos, block_name, radius)
	local nodes = minetest.find_nodes_in_area(
		{x = pos.x - radius, y = pos.y - radius, z = pos.z - radius},
		{x = pos.x + radius, y = pos.y + radius, z = pos.z + radius},
		{block_name}
	)
	if #nodes == 0 then
		return nil
	end
	local nearest = nil
	local min_dist = math.huge
	for _, npos in ipairs(nodes) do
		local dist = vector.distance(pos, npos)
		if dist < min_dist then
			min_dist = dist
			nearest = npos
		end
	end
	return nearest
end

-- Helper: Find a suitable ground position near center_pos
local function find_ground_pos(center_pos, min_r, max_r)
	if not center_pos then return nil end
	for _ = 1, 12 do
		local rx = math.random(-max_r, max_r)
		local rz = math.random(-max_r, max_r)
		if math.abs(rx) >= min_r or math.abs(rz) >= min_r then
			local tx = center_pos.x + rx
			local tz = center_pos.z + rz
			local base_y = math.floor(center_pos.y)
			for ty = base_y + 2, base_y - 3, -1 do
				local pos_below = {x = tx, y = ty - 1, z = tz}
				local pos_at = {x = tx, y = ty, z = tz}
				local pos_above = {x = tx, y = ty + 1, z = tz}

				local node_below = minetest.get_node_or_nil(pos_below)
				local node_at = minetest.get_node_or_nil(pos_at)
				local node_above = minetest.get_node_or_nil(pos_above)

				if node_below and node_at and node_above then
					local def_below = minetest.registered_nodes[node_below.name]
					local def_at = minetest.registered_nodes[node_at.name]
					local def_above = minetest.registered_nodes[node_above.name]

					local below_walkable = def_below and def_below.walkable ~= false
					local at_walkable = def_at and def_at.walkable == true
					local above_walkable = def_above and def_above.walkable == true

					if below_walkable and not at_walkable and not above_walkable and
					   node_below.name ~= "mobs_pupils:school_block" and
					   node_below.name ~= "mobs_pupils:home_block" then
						return {x = tx, y = ty, z = tz}
					end
				end
			end
		end
	end
	return nil
end

-- Helper: Place toy block nearby if standing near home block
local function try_place_toy(pos)
	if #toycity_blocks == 0 then return end
	if math.random(1, 10) ~= 1 then return end -- 10% chance per check tick

	local target_pos = {
		x = pos.x + math.random(-2, 2),
		y = pos.y + math.random(-1, 1),
		z = pos.z + math.random(-2, 2)
	}

	local under = {x = target_pos.x, y = target_pos.y - 1, z = target_pos.z}
	local node_at = minetest.get_node(target_pos)
	local node_under = minetest.get_node(under)

	if node_at.name == "air" and node_under.name ~= "air" and node_under.name ~= "ignore" then
		local toy = toycity_blocks[math.random(1, #toycity_blocks)]
		minetest.set_node(target_pos, {name = toy})
		minetest.add_particlespawner({
			amount = 6,
			time = 0.3,
			minpos = target_pos,
			maxpos = target_pos,
			minvel = {x = -0.5, y = 0.5, z = -0.5},
			maxvel = {x = 0.5, y = 1.5, z = 0.5},
			minacc = {x = 0, y = -2, z = 0},
			maxacc = {x = 0, y = -2, z = 0},
			minexptime = 0.5,
			maxexptime = 1.0,
			minsize = 1,
			maxsize = 2,
			texture = "mobs_pupils_home_block.png",
		})
	end
end

-- 3. Register Pupil Mob with Mobs Redo
mobs:register_mob("mobs_pupils:pupil", {
	type = "npc",
	passive = true,
	damage = 0,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.2, 0.0, -0.2, 0.2, 0.88, 0.2},
	visual = "mesh",
	mesh = "character.b3d",
	textures = {
		{"beach_npc.png"},
		{"beach_npc_2.png"},
		{"beach_npc_3.png"},
		{"beach_npc_4.png"},
		{"beach_npc_5.png"},
		{"beach_npc_6.png"},
	},
	visual_size = {x = 0.5, y = 0.5}, -- Half size of standard player
	makes_footstep_sound = true,
	walk_velocity = 1.5,
	run_velocity = 2.5,
	jump = true,
	jump_height = 4,
	stepheight = 1.1,
	fear_height = 3,
	water_damage = 0,
	lava_damage = 8,
	light_damage = 0,
	view_range = 15,
	owner = "",
	order = "roam",
	pushable = true,
	pathfinding = 1,
	animation = {
		speed_normal = 15,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
	},
	follow = {"default:apple", "default:paper", "default:book"},

	on_spawn = function(self)
		local name = pupil_names[math.random(1, #pupil_names)]
		self.nametag = name
		self.object:set_properties({
			nametag = self.nametag,
			nametag_color = "#FFFFFF",
		})
	end,

	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then return end
		local player_name = clicker:get_player_name()
		local mob_name = self.nametag or "Pupil"

		-- Set parent if not set
		if not self.owner or self.owner == "" then
			self.owner = player_name
			minetest.chat_send_player(player_name, mob_name .. ": You are now my parent!")
		else
			minetest.chat_send_player(player_name, mob_name .. ": Hello, " .. player_name .. "!")
		end
	end,

	do_custom = function(self, dtime)
		self.timer = (self.timer or 0) + dtime
		self.roam_timer = (self.roam_timer or 0) - dtime

		local pos = self.object:get_pos()
		if not pos then return end

		local school_time = is_school_time()
		local target_block_type = school_time and "mobs_pupils:school_block" or "mobs_pupils:home_block"
		local anchor_pos = find_nearest_block(pos, target_block_type, 30)

		if not anchor_pos and self.owner and self.owner ~= "" then
			local parent = minetest.get_player_by_name(self.owner)
			if parent then
				local ppos = parent:get_pos()
				if ppos and vector.distance(pos, ppos) < 30 then
					anchor_pos = vector.round(ppos)
				end
			end
		end

		-- Reset target when active block type changes (e.g. school time transition)
		if self.last_anchor_type ~= target_block_type then
			self.last_anchor_type = target_block_type
			self.roam_target = nil
			self.roam_timer = 0
		end

		-- Pick or update roaming target
		if not self.roam_target or self.roam_timer <= 0 or vector.distance(pos, self.roam_target) > 35 then
			local new_target = nil
			if anchor_pos then
				local dist_to_anchor = vector.distance(pos, anchor_pos)
				if dist_to_anchor > 12 then
					new_target = find_ground_pos(anchor_pos, 1, 4)
				else
					new_target = find_ground_pos(anchor_pos, 2, 7)
				end
			else
				new_target = find_ground_pos(vector.round(pos), 2, 6)
			end

			if not new_target then
				if anchor_pos then
					new_target = {
						x = anchor_pos.x + math.random(-2, 2),
						y = anchor_pos.y,
						z = anchor_pos.z + math.random(-2, 2)
					}
				else
					new_target = vector.round(pos)
				end
			end

			self.roam_target = new_target
			self.roam_timer = math.random(4, 8)
			-- 1 in 3 chance to run, otherwise walk
			self.move_speed = (math.random(1, 3) == 1) and (self.run_velocity or 2.5) or (self.walk_velocity or 1.5)
		end

		-- Move towards roam_target
		if self.roam_target then
			local dx = self.roam_target.x - pos.x
			local dz = self.roam_target.z - pos.z
			local dist_h = math.sqrt(dx * dx + dz * dz)

			if dist_h > 0.8 then
				local yaw = math.atan2(dz, dx) - math.pi / 2
				self.object:set_yaw(yaw)

				local vel = self.object:get_velocity() or {x = 0, y = 0, z = 0}
				local current_y = vel.y
				local speed = self.move_speed or self.walk_velocity or 1.5

				local dir_x = -math.sin(yaw)
				local dir_z = math.cos(yaw)

				-- Obstacle check & jump logic
				local check_pos = {
					x = math.floor(pos.x + dir_x * 0.6 + 0.5),
					y = math.floor(pos.y + 0.1),
					z = math.floor(pos.z + dir_z * 0.6 + 0.5)
				}
				local node_ahead = minetest.get_node_or_nil(check_pos)
				if node_ahead and node_ahead.name ~= "air" and node_ahead.name ~= "ignore" then
					local def = minetest.registered_nodes[node_ahead.name]
					-- Only jump over normal terrain nodes, NOT school/home blocks
					if def and def.walkable ~= false and
					   node_ahead.name ~= "mobs_pupils:school_block" and
					   node_ahead.name ~= "mobs_pupils:home_block" and
					   math.abs(current_y) < 0.1 and
					   pos.y <= self.roam_target.y + 0.5 then
						current_y = 4.2
					end
				end

				self.object:set_velocity({
					x = dir_x * speed,
					y = current_y,
					z = dir_z * speed
				})

				if mobs.set_animation then
					if speed > 2.0 then
						mobs:set_animation(self, "run")
					else
						mobs:set_animation(self, "walk")
					end
				end
			else
				-- Reached roam destination spot
				local vel = self.object:get_velocity() or {x = 0, y = 0, z = 0}
				self.object:set_velocity({x = 0, y = vel.y, z = 0})

				if mobs.set_animation then
					mobs:set_animation(self, "stand")
				end

				-- Short pause before picking next spot
				if self.roam_timer > 3 then
					self.roam_timer = math.random(1, 3)
				end

				-- If off school, try placing toy near home
				if not school_time then
					if self.timer >= 2.0 then
						self.timer = 0
						try_place_toy(pos)
					end
				end
			end
		end
	end,
})

-- 4. Register Pupil Spawn Egg
mobs:register_egg("mobs_pupils:pupil", "Pupil NPC", "mobs_pupils_egg.png", 1)

minetest.log("action", "[mobs_pupils] Loaded successfully!")
