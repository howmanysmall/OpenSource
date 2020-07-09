local Roact = require(script.Parent.Parent.Roact)
local PetEntry = require(script.Parent)

return function(Target)
	local Tree = Roact.mount(Roact.createElement(PetEntry), Target)
	return function()
		Roact.unmount(Tree)
	end
end