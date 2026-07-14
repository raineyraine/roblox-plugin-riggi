--!strict

export type PromptAppProps<T> = {
	submit: (value: T) -> (),
	cancel: () -> (),
}

export type PromptApp<T> = (plugin: Plugin, props: PromptAppProps<T>) -> Instance

export type PromptResult<T> = {
	and_then: (callback: (T) -> ()) -> PromptResult<T>,
	on_cancel: (callback: () -> ()) -> PromptResult<T>,
}

local store = require "@plugin/store"
local plugin = store.state.plugin()

local vide = require "@pkgs/vide"
local mount = vide.mount
local cleanup = vide.cleanup

local function spawn_prompt_widget<T>(id: string, info: DockWidgetPluginGuiInfo, app: PromptApp<T>): PromptResult<T>
	local andThenCallback: ((T) -> ())? = nil
	local onCancelCallback: (() -> ())? = nil

	local result: T? = nil
	local cancelled = false

	local to_return = {}
	to_return = {
		and_then = function(callback: (T) -> ())
			if result then
				callback(result)
			else
				andThenCallback = callback
			end

			return to_return
		end,
		on_cancel = function(callback: () -> ())
			if cancelled then
				callback()
			else
				onCancelCallback = callback
			end

			return to_return
		end,
	}

	local unmount: () -> ()

	local widget = plugin:CreateDockWidgetPluginGuiAsync(id, info)
	widget.Enabled = true

	local function submit(value: T)
		unmount()
		widget:Destroy()
		result = value
		if andThenCallback then
			andThenCallback(value)
		end
	end

	local function cancel()
		unmount()
		widget:Destroy()
		cancelled = true
		if onCancelCallback then
			onCancelCallback()
		end
	end

	local props = {
		submit = submit,
		cancel = cancel,
	}

	unmount = mount(function()
		local mounted = app(plugin, props)
		cleanup(mounted)
		return mounted
	end, widget)

	widget:BindToClose(props.cancel)

	return to_return :: PromptResult<T>
end

return {
	spawn_prompt_widget = spawn_prompt_widget,
}
