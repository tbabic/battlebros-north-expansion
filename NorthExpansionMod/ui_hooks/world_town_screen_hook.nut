::mods_hookNewObject("ui/screens/world/world_town_screen", function(o){
	local method = ::mods_getMember(o, "showLastActiveDialog");
	::mods_override(o, "showLastActiveDialog", function() {
		this.logInfo("show last active dialog");
		if (::NorthMod.Screens.DuelCircleScreen.isVisible() && !::NorthMod.Screens.DuelCircleScreen.isAnimating())
		{
			this.logInfo("duel visible");
			return;
		}
		this.logInfo("duel not visible");
		return method();
	});
});