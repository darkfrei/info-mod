-- recipe functions; version 005 from 2017-12-03
-- /darkfrei

function ilog (content)
	if not (content) then
		log ("no content, sorry")
		return
	end
	if type (content) == "table" then log (serpent.block(content, {comment = false})) return end
	log (content)
end

function table_size (tabl)
	local k = 0
	for i, v in pairs (tabl) do
		k = k + 1
	end
	return k
end

function table_last (tabl)
	local last = 0
	for i, v in pairs (tabl) do
		last = i
	end
	return last
end


recipe_functions = {}
--results = {{type = "item", name = "stone-brick", amount = 1}}


function recipe_functions.norm_ingredients(recipe)
	if recipe.ingredients then
		for i, ingredient in pairs (recipe.ingredients) do
			if not ingredient.type then
				ingredient.type = "item"
				ingredient.name = ingredient.name or ingredient[1]
				ingredient[1] = nil
				ingredient.amount = ingredient.amount or ingredient[2]
				ingredient[2] = nil
				--log ('Was no type by ' .. ingredient.name)
			else
				--log ('item:' ..ingredient.name .. ' type:' .. ingredient.type)
			end
		end
	else
		log ('Warning! No ingredients!')
		ilog (recipe)
	end
end

function recipe_functions.norm_results (recipe)
	if recipe.result then
		local amount = recipe.result_count or 1
		recipe.results = {{type = "item", name = recipe.result, amount = amount}}
		recipe.result = nil
		recipe.result_count = nil
	end
end

function recipe_functions.norm_results_icons (recipe)
	if recipe.icon then 
		--log ('icons from icon: ' .. recipe.name)
		recipe.icons = {{icon = recipe.icon}}
		recipe.icon = nil
	end
	local results = recipe.results or {}
	if table_size(results) == 1 then
		local result_name = results[table_last (results)].name
		local result_item = data.raw.item[result_name]
		if result_item then
			local result_icon = recipe.icon
			if (not (result_icon)) and (result_item.icon) then
				result_icon = result_item.icon
				--log (result_name .. ' added icon from item')
			end
			local result_icons = recipe.icons
			if not (result_icons) and (result_item.icons)  then
				result_icons = result_item.icons
				--log (result_name .. ' added icons from item')
			end
			if not (result_icons) then
				result_icons = {{icon = result_icon}}
				--log (result_name .. ' icon was rewritten ' .. result_icon)
				result_icon = nil
			end
		else
			--log("no item! " .. result_name .. " - " .. serpent.block(recipe, {comment = false}))
		end
	end
end

function recipe_functions.global_iterator ()
	local raw_recipes = data.raw.recipe
	local i = 0
	local recipes_handler = {} -- {{name = "recipe_name", difficultly = "default" / "normal" / "expensive", recipe = {recipe_table}}}
	for recipe_name, recipe in pairs (raw_recipes) do
		if recipe.normal then
			i = i + 2
			recipes_handler[#recipes_handler+1] = {name =recipe.name, difficultly = 'normal', recipe = recipe.normal}
			recipes_handler[#recipes_handler+1] = {name =recipe.name, difficultly = 'expensive', recipe = recipe.expensive}
		else
			i = i + 1
			recipes_handler[#recipes_handler+1] = {name =recipe.name, difficultly = 'default', recipe = recipe}
		end
	end
	return recipes_handler
end

function recipe_functions.list_of_recipe_names ()
	local recipe_names = {}
	local raw_recipes = data.raw.recipe
	for i_name, recipe in pairs (raw_recipes) do
		if not (i_name == recipe.name) then
			log ('Warning! Some problem!')
		end
		recipe_names[#recipe_names+1] = recipe.name
	end
	return recipe_names
end

function check_result_and_item_stack (result)
	local result_name = result.name
	--log ('Working with ' .. result_name)
local item = 
		data.raw.item[result_name] 
	or data.raw["item-with-entity-data"][result_name] 
	or data.raw["mining-tool"][result_name] 
	or data.raw["gun"][result_name] 
	or data.raw["ammo"][result_name] 
	or data.raw["armor"][result_name] 
	or data.raw["repair-tool"][result_name] 
	or data.raw["mining-tool"][result_name] 
	or data.raw["capsule"][result_name] 
	or data.raw["fluid"][result_name] 
	or data.raw["module"][result_name] 
	or data.raw["rail-planner"][result_name] 
	or data.raw["tool"][result_name] 
	or data.raw["blueprint"][result_name] 
	or data.raw["deconstruction-item"][result_name] 
	or data.raw["blueprint-book"][result_name] 
	or data.raw["selection-tool"][result_name] 
	or data.raw["item-with-tags"][result_name] 
	or data.raw["item-with-label"][result_name] 
	or data.raw["item-with-inventory"][result_name] 
	-- sorry for this code, it must be rewritten later
	
	if (item.stack_size) then
		if result.amount > item.stack_size then
			item.stack_size = result.amount
		end
	else	
		log ('No stack_size by ' .. item.name)
	end
end

function is_element_in_list (element, list)
	local bool = false
	for i, v in pairs (list) do
		if v == element then
			bool = true
		end
	end
	return bool
end





function change_handler_recipe (handler, factor_k)
	local recipe = handler.recipe
	recipe.energy_required = recipe.energy_required or 0.5 -- default for 0.15.34
	recipe.energy_required = recipe.energy_required * factor_k
	for i, ingredient in pairs (recipe.ingredients) do
		ingredient.amount = ingredient.amount * factor_k
	end
	for i, result in pairs (recipe.results) do
		result.amount = result.amount * factor_k
		check_result_and_item_stack (result)
	end
end





function recipe_functions.make_item_type_table ()
	item_type_list = {"ammo","armor","gun","item","capsule","repair-tool","mining-tool","item-with-entity-data","rail-planner","tool","blueprint","deconstruction-item","blueprint-book","selection-tool","item-with-tags","item-with-label","item-with-inventory","module"}
	item_type_table = {}
		for i, item_type_name in pairs (item_type_list) do
			for item_name, item in pairs (data.raw[item_type_name]) do
				item_type_table[item_name] = item_type_name
			end
		end
	log ('item_type_table = ' .. serpent.block(item_type_table, {comment = false}))
end


function get_item_type_name_from_item_name (item_name)
	if not item_type_table then
		recipe_functions.make_item_type_table ()
	end
	log ('get_item_type_name_from_item_name by ' .. item_name)
	local item_type_name = item_type_table[item_name] or "fluid"
	log ('item_type_name = ' .. item_type_name)
	return item_type_name
end


function check_recipe_ingredients (recipe, factor_k)
	local max_factor_k = factor_k
	if not (recipe.ingredients) then
		log ('Error: no ingridients by --' .. handler.name)
		log ('hanler = ' .. serpent.block(handler, {comment = false}))
		return false
	end
	for i, ingredient in pairs (recipe.ingredients) do
		if not (ingredient.amount) then
			is_ok = false
			log ('Error: changing ingredient of --' .. handler.name)
			if ingredient.name then
				log ('Bad ingredient was ' .. ingredient.name)
			end
			return false
		end
		if (ingredient.amount * factor_k) > 65535 then
			log ('ingredient.amount * factor_k > 65535, actually: ' .. ingredient.amount .. ' * ' .. factor_k)
			local m_factor = math.floor(65535/ingredient.amount)
			if max_factor_k > m_factor then
				max_factor_k = m_factor
			end
			--return false
		end
	end
	--return true
	if not (max_factor_k == factor_k) then
		log ('New max_factor_k is ' .. max_factor_k)
	end
	return max_factor_k
end



function check_recipe_results (recipe, black_list_items, white_list_item_types)
	if not (recipe.results) then
		log ('Error: no ingridients by recipe -----------')
		log ('hanler = ' .. serpent.block(handler, {comment = false}))
		return false
	end
	
	for i, result in pairs (recipe.results) do
		local item_name = result.name
		if not (item_name) then 
			log ('No item_name! Will be ignored! result = ' .. serpent.block(result, {comment = false}))
			return false
		end
		local item_type_name = get_item_type_name_from_item_name(item_name)
		if is_element_in_list(item_name, black_list_items) then
			log ('item was in black list --' .. item_name)
			return false
		end
		if not (result.type == "fluid") then
			if not (is_element_in_list(item_type_name, white_list_item_types)) then
				log ("item type wasn't in white list --" .. item_type_name .. ' (' .. item_name .. ')')
				return false
			end
			else
			log ('Result item_name is ' .. item_name .. ' and ignored')
		end
		if not (result.amount) then
			log ('Error: no result_amount by recipe -----------')
			if result.name then
				log ('Bad result was ' .. result.name)
			end
		return false
		end
	end
	return true
end

function check_handler_recipe (handler, black_list_items, white_list_item_types, factor_k)
	local recipe = handler.recipe
	local is_ok = true
	local new_factor_k_or_false = check_recipe_ingredients (recipe, factor_k)
	
	if not (new_factor_k_or_false) then
		is_ok = false
		log ('ingredients was bad by --' .. handler.name)
	end
	
	if not (check_recipe_results (recipe, black_list_items, white_list_item_types)) then
		is_ok = false
		log ('results was bad by --' .. handler.name)
	end
	
	if is_ok then 
		log ('The recipe ' .. handler.name .. ' was ok.')
	end
	
	if is_ok then 
		return new_factor_k_or_false
	else
		return is_ok
	end	
end

function recipe_functions.multiplicate_all (factor_k, black_list_items, white_list_item_types)
	local recipes_handler = recipe_functions.global_iterator ()
	for i, handler in pairs (recipes_handler) do
	-- (not (is_element_in_list(handler.name, black_list_items))) and 
	-- (is_element_in_list(get_item_type_name_from_item_name(handler.name), white_list_item_types)) then
		local new_factor_or_false = check_handler_recipe (handler, black_list_items, white_list_item_types, factor_k)
		if new_factor_or_false then
			change_handler_recipe (handler, new_factor_or_false)
		end
	end
end

return recipe_functions
