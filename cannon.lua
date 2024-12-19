-- idea: there is a chance that it will explode in ur face
-- maybe: make an entity to make it look better just maybe

sin = math.sin
cos = math.cos
rad = math.rad


extra = ""
top = "default_steel_block.png^default_coal_lump.png"
top_onlit = "default_steel_block.png^default_flint.png"
if conduct then
	extra = "smart"
	top = "default_steel_block.png^default_mese_crystal.png"
	top_onlit = "default_steel_block.png^default_mese_crystal.png"
end
minetest.register_node("mortar:cannon"..extra,{
	description = "cannon "..extra,
	tiles = {
		top,
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png^default_flint.png",
		"default_steel_block.png",
	},
	stack_max = 1,
	is_ground_content = false,
	paramtype2 = "facedir",
	groups = {
		cracky = 3,
		oddly_breakable_by_hand = 1,
	},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
        	local meta = minetest.get_meta(pos)
        	local inv = meta:get_inventory()
    		inv:set_size("main", 32)
    		meta:set_int("power",40)
    		meta:set_int("angle",70)
        end,
	on_punch = function(pos, node, player, pointed_thing)
            item = player:get_wielded_item()
            if item:get_name() == "mortar:bomb" then
            	meta = minetest.get_meta(pos)
            	angle = meta:get_int("angle")
        	power = meta:get_int("power")
            	inv = player:get_inventory()
            	inv:remove_item("main",ItemStack("mortar:bomb"))
            	minetest.set_node(pos,{name="mortar:cannon_loaded",param2=node.param2})
            	meta = minetest.get_meta(pos)
            	meta:set_int("angle",angle)
        	meta:set_int("power",power)
            	minetest.get_node_timer(pos):start(0.5)
            end
        end,
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        	meta = minetest.get_meta(pos)
        	angle = meta:get_int("angle")
        	power = meta:get_int("power")
        	formname = minetest.serialize({name="cannon",pos=pos})
        	minetest.show_formspec(clicker:get_player_name(), formname, "size[3,2.5]"..
			"field[0.6,0.5;2.5,0.6;angle;Angle;"..angle.."]"..
			"field[0.6,1.8;2.5,0;power;Power;"..power.."]"..
			"button[0.8,1.7;1.5,1.6;save;Save]")
        end,
})

minetest.register_node("mortar:cannon"..extra.."_loaded",{
	description = "cannon "..extra,
	tiles = {
		"default_steel_block.png^default_flint.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		top_onlit,
		"default_steel_block.png",
	},
	stack_max = 1,
	is_ground_content = false,
	paramtype2 = "facedir",
	groups = {
		cracky = 3,
		oddly_breakable_by_hand = 1,
             	not_in_creative_inventory = 1,
	},
	can_dig = function(pos, player)
            return false
        end,
        on_timer = function(pos, elapsed)
    		meta = minetest.get_meta(pos)
        	rot = meta:get_int("angle")
        	r = rad(rot)
        	p = meta:get_int("power")
        
        	node = minetest.get_node(pos)
        	dir = minetest.facedir_to_dir(node.param2)
        	entity = minetest.add_entity({x=pos.x+dir.x,y=pos.y+1,z=pos.z+dir.z},"ww1_planes_lib:bomb1")
        	entity:set_velocity({x=cos(r)*dir.x*p,y=sin(r)*p,z=cos(r)*dir.z*p})
        	minetest.set_node(pos,{name="mortar:cannon",param2=node.param2})
        	--minetest.get_node_timer(pos):start(0.2)
		minetest.sound_play("tnt_explode", {pos = pos, gain = 2.5,
			max_hear_distance = math.min(25 * 20, 128)}, true)
            	meta = minetest.get_meta(pos)
            	meta:set_int("angle",rot)
        	meta:set_int("power",p)
        end,
})

minetest.register_craftitem("mortar:bomb",{
	description = "cannon bomb",
	stack_max = 5,
	inventory_image = "default_flint.png^default_coal_lump.png",
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if string.sub(formname,1,6) ~= "return" then
        return
    end

    if fields.save then
    	info = minetest.deserialize(formname)
    	if info.name ~= "cannon" then
    		return
    	end
    	
    	meta = minetest.get_meta(info.pos)
    	angle = tonumber(fields.angle)
    	if angle == nil then
    		angle = 65
    	elseif angle < 65 then
    		angle = 65
    	elseif angle > 90 then
    		angle = 90
    	end
    	power = tonumber(fields.power)
    	if power == nil then
    		power = 20
    	end
    	meta:set_int("angle",angle)
    	meta:set_int("power",power)
    end
end)
