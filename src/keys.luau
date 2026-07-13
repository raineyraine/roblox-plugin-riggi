--!strict

const function key(extension: string): string
	return "raineyraine/riggi_plugin." .. extension
end

const keys = {
	plugin = {
		main_button = key "button.main",
		main_widget = key "widget.main",
	},
	saved_state = {
		presets = "presets",
	},
}

return keys
