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
		self.path_recalc_timer = (self.path_recalc_timer or 0) + dtime

		local pos = self.object:get_pos()
		if not pos then return end

		local school_time = is_school_time()
		local target_block_type = school_time and "mobs_pupils:school_block" or "mobs_pupils:home_block"
		local target_pos = find_nearest_block(pos, target_block_type, 30)

		if not target_pos and self.owner and self.owner ~= "" then
			local parent = minetest.get_player_by_name(self.owner)
			if parent then
				local ppos = parent:get_pos()
				if ppos and vector.distance(pos, ppos) < 30 then
					target_pos = vector.round(ppos)
				end
			end
		end

		if target_pos then
			local dist = vector.distance(pos, target_pos)
			if dist > 2 then
				-- Recalculate path periodically or if no current path
				if not self.current_path or #self.current_path == 0 or self.path_recalc_timer >= 1.5 then
					self.path_recalc_timer = 0
					local start_pos = vector.round(pos)
					local path = minetest.find_path(start_pos, target_pos, 20, 1, 2, "A*")
					if path and #path > 1 then
						self.current_path = path
						self.path_index = 2
					else
						self.current_path = nil
					end
				end

				-- Determine next position/waypoint
				local next_pos = nil
				if self.current_path and self.path_index and self.current_path[self.path_index] then
					next_pos = self.current_path[self.path_index]
					local dist_to_waypoint = vector.distance(
						{x = pos.x, y = pos.y, z = pos.z},
						{x = next_pos.x, y = pos.y, z = next_pos.z}
					)
					if dist_to_waypoint < 0.6 then
						self.path_index = self.path_index + 1
						next_pos = self.current_path[self.path_index]
					end
				end

				if not next_pos then
					next_pos = target_pos
				end

				-- Move towards next_pos
				local dx = next_pos.x - pos.x
				local dz = next_pos.z - pos.z
				if math.abs(dx) > 0.01 or math.abs(dz) > 0.01 then
					local yaw = math.atan2(dz, dx) - math.pi / 2
					self.object:set_yaw(yaw)

					local vel = self.object:get_velocity() or {x = 0, y = 0, z = 0}
					local current_y = vel.y
					local speed = self.walk_velocity or 1.5

					local dir_x = -math.sin(yaw)
					local dir_z = math.cos(yaw)

					-- Obstacle check: Jump over 1-node high block if blocked
					local check_pos = {
						x = math.floor(pos.x + dir_x * 0.6 + 0.5),
						y = math.floor(pos.y + 0.1),
						z = math.floor(pos.z + dir_z * 0.6 + 0.5)
					}
					local node_ahead = minetest.get_node_or_nil(check_pos)
					if node_ahead and node_ahead.name ~= "air" and node_ahead.name ~= "ignore" then
						local def = minetest.registered_nodes[node_ahead.name]
						if def and def.walkable ~= false and math.abs(current_y) < 0.1 then
							current_y = 4.2
						end
					end

					self.object:set_velocity({
						x = dir_x * speed,
						y = current_y,
						z = dir_z * speed
					})

					if mobs.set_animation then
						mobs:set_animation(self, "walk")
					end
				end
			else
				-- Stays around block
				local vel = self.object:get_velocity() or {x = 0, y = 0, z = 0}
				self.object:set_velocity({x = 0, y = vel.y, z = 0})
				if mobs.set_animation then
					mobs:set_animation(self, "stand")
				end
				self.current_path = nil

				if not school_time then
					if self.timer >= 2.0 then
						self.timer = 0
						try_place_toy(pos)
					end
				end
			end
		else
			self.current_path = nil
		end
	end,
})

-- 4. Register Pupil Spawn Egg
mobs:register_egg("mobs_pupils:pupil", "Pupil NPC", "mobs_pupils_egg.png", 1)

minetest.log("action", "[mobs_pupils] Loaded successfully!")
