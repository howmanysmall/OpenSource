-- @license https://github.com/Kampfkarren/hoarcekat/blob/master/LICENSE.md
-- @source https://github.com/Kampfkarren/hoarcekat/blob/master/src/Components/EventConnection.lua

local Roact = require(script.Parent.Roact)
local t = require(script.Parent.t)

local EventConnection = Roact.Component:extend("EventConnection")
EventConnection.validateProps = t.strictInterface({
	Event = t.RBXScriptSignal,
	Function = t.callback,
})

function EventConnection:init()
	self.connection = nil
end

function EventConnection:didMount()
	self.connection = self.props.Event:Connect(self.props.Function)
end

function EventConnection.render()
	return nil
end

function EventConnection:didUpdate(oldProps)
	if self.props.Event ~= oldProps.Event or self.props.Function ~= oldProps.Function then
		self.connection:Disconnect()
		self.connection = self.props.Event:Connect(self.props.Function)
	end
end

function EventConnection:willUnmount()
	self.connection = self.connection:Disconnect()
end

return EventConnection
