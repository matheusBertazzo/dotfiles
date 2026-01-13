local helper = {}

function helper.get_keymaps_for(plugin_name)
	local keymap_dict = {
		['mini.move'] = {
			osx = {
				left = '˙',
				right = '¬',
				down = '∆',
				up = '˚',
				line_left = '˙',
				line_right = '¬',
				line_down = '∆',
				line_up = '˚'
			},
			default = {}
		}
	}

	if jit.os == "OSX" then
		return keymap_dict[plugin_name].osx
	else
		return keymap_dict[plugin_name].default
	end
end

return helper
