function indexing (text)
	--string.find(s, pattern [, index [, plain]])
	local pos_or_nil = string.find(text, '-')
	if not pos_or_nil then 
		return  '.' .. text
	else -- only text has '-' inside, not the number
		return '["' .. text .. '"]'
	end
	log ("Error")
end

function self (table_or_value, path)
   list2 = {}
   
   if type(table_or_value) == "table" then
      for index in pairs (table_or_value) do
			self (table_or_value[index], path .. indexing(index))
      end
   else
      if type(table_or_value) ~= "function" then
			if type(table_or_value) == "string" then
				log (' / ' .. path .. ' = "' .. tostring(table_or_value) .. '"')
			else	
				log (' / ' .. path .. ' = ' .. tostring(table_or_value))
			end
      end
   end
   return list2
end


for i, v in pairs( {data=data, defines=defines} ) do
   local list2 = self(v, i)
	
   --log(" Subnum: " .. serpent.line(list2) )
end



