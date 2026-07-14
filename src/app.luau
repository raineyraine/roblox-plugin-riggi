--!strict

const vide = require "@pkgs/vide"
const cleanup = vide.cleanup
const effect = vide.effect
const mount = vide.mount

const keys = require "./keys"
const main_app = require "./components/main"

const store = require "@plugin/store"
const state = store.state

const function app(plugin: Plugin)
	local plugin_toolbar = plugin:CreateToolbar("Riggi Plugin")
	local main_button = plugin_toolbar:CreateButton(keys.plugin.main_button, "Open/close the Riggi plugin", "", "Riggi")
	local main_widget = plugin:CreateDockWidgetPluginGuiAsync(
		keys.plugin.main_widget,
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 400, 200, 400)
	)
	main_widget.Name = "riggi_plugin_main_widget"
	main_widget.Title = "Riggi"
	main_widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	state.open(main_widget.Enabled)

	main_button.Click:Connect(function()
		state.open(not state.open())
	end)

	local unmount: (() -> ())?

	main_widget:BindToClose(function()
		state.open(false)
	end)

	effect(function()
		local open = state.open()
		main_widget.Enabled = open
		main_button:SetActive(open)

		if unmount then
			unmount()
			unmount = nil
		end

		if open then
			unmount = mount(function()
				local mounted = main_app(plugin)
				cleanup(mounted)
				return mounted
			end, main_widget)
		end
	end)
end

return app
