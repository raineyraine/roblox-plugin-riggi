export type PromptAppProps<T> = {
	submit: (value: T) -> (),
	cancel: () -> (),
}

export type PromptApp<T> = (plugin: Plugin, props: PromptAppProps<T>) -> Instance

export type PromptResult<T> = {
	and_then: (callback: (T) -> ()) -> PromptResult<T>,
	on_cancel: (callback: () -> ()) -> PromptResult<T>,
}

const core = require "@plugin/store/core"
const plugin = core.state.plugin()

const vide = require "@pkgs/vide"
const mount = vide.mount
const cleanup = vide.cleanup

const function spawn_prompt_widget<T>(
	id: string,
	info: DockWidgetPluginGuiInfo,
	app: PromptApp<T>,
	title: string?
): PromptResult<T>
	local andThenCallback: ((T) -> ())? = nil
	local onCancelCallback: (() -> ())? = nil

	local result: T? = nil
	local cancelled = false

	const to_return: PromptResult<T> = {} :: any

	function to_return.and_then(callback: (T) -> ())
		if result then
			callback(result)
		else
			andThenCallback = callback
		end

		return to_return
	end

	function to_return.on_cancel(callback: () -> ())
		if cancelled then
			callback()
		else
			onCancelCallback = callback
		end

		return to_return
	end

	local unmount: () -> ()

	local widget = plugin:CreateDockWidgetPluginGuiAsync(id, info)
	widget.Enabled = true
	if title then
		widget.Title = title
	end

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
