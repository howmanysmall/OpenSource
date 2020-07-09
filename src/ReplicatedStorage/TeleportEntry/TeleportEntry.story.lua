local Roact = require(script.Parent.Parent.Roact)
local TeleportEntry = require(script.Parent)

return function(Target)
	local Tree = Roact.mount(Roact.createElement(TeleportEntry), Target)

	return function()
		Roact.unmount(Tree)
	end
end