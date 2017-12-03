require("info")

local item_type_list = { "ammo", "armor", "gun", "item", "capsule", "repair-tool", "mining-tool", "item-with-entity-data", "rail-planner", "tool", "blueprint", "deconstruction-item", "blueprint-book", "selection-tool", "item-with-tags", "item-with-label", "item-with-inventory", "module"}

local function get_items_list(item_type_list)
	local items_list = {}
		for i, typ in pairs(item_type_list) do
			for item_name, item_prot in pairs (data.raw[typ]) do
				items_list[#items_list+1] = item_name
			end
		end
	return items_list
end

local items_list = get_items_list(item_type_list)

log ('local items_list = ' .. serpent.block(items_list, {comment = false}) )


local fluids_list = {}
for fluid_name, fluid_prot in pairs (data.raw.fluid) do
	fluids_list[#fluids_list+1] = fluid_name
end

log ('local fluids_list = ' .. serpent.block(fluids_list, {comment = false}) )
