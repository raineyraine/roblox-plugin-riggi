const vide = require "@pkgs/vide"
const source = vide.source

type Array<Value> = { Value }

export type AlertKind = "warn" | "error" | "info" | "success"
export type Alert = {
	read kind: AlertKind,
	read message: string,
	read id: number,
}

local id = 0

const state = {
	alerts = source({} :: Array<Alert>),
}

const actions = {}

function actions.alert(kind: AlertKind, message: string, removeAfter: number?)
	const alertId = id
	const alerts = state.alerts()
	table.insert(alerts, { kind = kind, message = message, id = alertId })
	state.alerts(alerts)

	task.delay((removeAfter or 4) + (#alerts - 1) * 0.1, function()
		actions.remove_alert(alertId)
	end)

	id += 1
end

function actions.remove_alert(id: number)
	const alerts = state.alerts()
	const newAlerts = {} :: Array<Alert>
	local length = 0

	for i, alert in alerts do
		if alert.id ~= id then
			length += 1
			newAlerts[length] = alert
		end
	end

	state.alerts(newAlerts)
end

return {
	state = state,
	actions = actions,
}
