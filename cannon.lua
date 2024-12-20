
sin = math.sin
cos = math.cos
rad = math.rad

local mortar = {
    initial_properties = {
        visual = "mesh",
        mesh = "mortar_cannon.obj",
        textures = {"default_steel_block.png"},
        collisionbox = {-0.5, 0, -0.5, 0.5, 1.5, 0.5},
		physical = true,
        visual_size = {x = 1, y = 1, z = 1},
    },

	power = 20,
	angle = 70,
}

function mortar:on_punch(puncher, time_from_last_punch, tool_capabilities, direction,
	damage)
	cont = puncher:get_player_control()
	if cont.sneak then
		local yaw = puncher:get_look_horizontal()

		local rotation = self.object:get_rotation()
        if rotation then
            rotation.y = yaw
            self.object:set_rotation(rotation)
        end
	elseif cont.aux1 then
		pos = self.object:get_pos()
		self.object:remove()
		inv = puncher:get_inventory()
		item = ItemStack("mortar:cannon")
		if inv:room_for_item("main",item) then
			inv:add_item("main",item)
		else
			minetest.item_drop(item, puncher, pos)
		end
	else
		item = puncher:get_wielded_item()
		if item:get_name() == "mortar:bomb" then
			inv = puncher:get_inventory()
			inv:remove_item("main", ItemStack("mortar:bomb"))
			rot = math.deg(self.object:get_rotation().y)
			rot = math.fmod(rot+90,360)
			shoot(self.object:get_pos(),rad(rot),self.angle,self.power)
		end
	end

	return true
end

function mortar:on_rightclick(clicker)
	clicker:set_attach(self.object)
	angle = self.angle
	power = self.power

	minetest.show_formspec(clicker:get_player_name(), "mortar", "size[2,2.6]"..
		"field[0.55,0.4;1.5,1;power;Power;"..power.."]"..
		"field[0.55,1.5;1.5,1;angle;Angle;"..angle.."]"..
		"button[0.25,2.15;1.54,1;save;Save]")
end

minetest.register_entity("mortar:cannon",mortar)

function shoot(pos,r,a,p)
	a = rad(a)
    node = minetest.get_node(pos)
    
	dir = {x=cos(r),y=1,z=sin(r)}
	local magnitude = math.sqrt(dir.x^2 + dir.y^2 + dir.z^2)
	dir.x = dir.x / magnitude
	dir.y = dir.y / magnitude
	dir.z = dir.z / magnitude
    
	velocity = vector.multiply({x=cos(a),y=sin(a),z=cos(a)},dir)
	velocity = vector.multiply(velocity,p)

    entity = minetest.add_entity({x=pos.x,y=pos.y+1,z=pos.z},"ww1_planes_lib:bomb1")
    entity:set_velocity(velocity)
	minetest.sound_play("tnt_explode", {pos = pos, gain = 2.5,
	x_hear_distance = math.min(25 * 20, 128)}, true)
end

minetest.register_craftitem("mortar:bomb",{
	description = "cannon bomb",
	stack_max = 5,
	inventory_image = "default_flint.png^default_coal_lump.png",
})

minetest.register_craftitem("mortar:cannon",{
	description = "mortar cannon",
	stack_max = 1,
	inventory_image = "mortar_cannon.png",
	on_place = function (itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			pos = pointed_thing.above
			obj = minetest.add_entity(pos,"mortar:cannon")
			if obj then
				local yaw = user:get_look_horizontal()
				obj:set_rotation({x=0,y=yaw,z=0})
				itemstack:take_item()
				return itemstack
			end
		end
	end
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mortar" then
        return
    end

    if fields.save then
		obj = player:get_attach()
		ent = obj:get_luaentity()
    	
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
    	ent.angle = angle
    	ent.power = power
    end
	player:set_detach()
	minetest.close_formspec(player:get_player_name(), formname)
end)
