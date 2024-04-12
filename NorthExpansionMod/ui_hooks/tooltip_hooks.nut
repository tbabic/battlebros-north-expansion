
::mods_hookClass("ui/screens/tooltip/tooltip_events", function(o) {
	this.logInfo(o);
	local method = ::mods_getMember(o, "general_queryUIElementTooltipData");
	::mods_override(o, "general_queryUIElementTooltipData", function(_entityId, _elementId, _elementOwner) {
		
		if (_elementId == "world-town-screen.main-dialog-module.Duel")
		{
			
			local ret = [
				{
					id = 1,
					type = "title",
					text = "Dueling Circle"
				},
				{
					id = 2,
					type = "description",
					text = "Dueling circle is a place where you can challenge warriors from the settlement for fight in a single combat."
				}
			];
			return ret;
		}
		
		return method(_entityId, _elementId, _elementOwner);
		
		
		
		
	});
});