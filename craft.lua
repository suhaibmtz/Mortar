minetest.register_craft({
	output = "cannon:cannon",
	recipe = {
		{"default:steel_ingot","","default:steel_ingot"},
		{"default:steel_ingot","basic_materials:steel_bar","default:steel_ingot"},
		{"default:steel_ingot","default:steelblock","default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "cannon:bomb 2",
	recipe = {
		{"","default:steel_ingot",""},
		{"default:steel_ingot","tnt:tnt","default:steel_ingot"},
		{"","tnt:tnt_stick",""},
	},
})
