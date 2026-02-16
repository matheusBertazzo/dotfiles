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
		},
		['tabs'] = {
			osx = { '¡', '™', '£', '¢', '∞', '§', '¶', '•', 'ª' },
			default = {
				'<A-1>',
				'<A-2>',
				'<A-3>',
				'<A-4>',
				'<A-5>',
				'<A-6>',
				'<A-7>',
				'<A-8>',
				'<A-9>',
			}
		}
	}

	if jit.os == "OSX" then
		return keymap_dict[plugin_name].osx
	else
		return keymap_dict[plugin_name].default
	end
end

return helper
