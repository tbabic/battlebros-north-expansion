::mods_hookBaseClass("entity/tactical/player", function(o) {
	local onInit = ::mods_getMember(o, "onInit");
	::mods_override(o, "onInit", function() {
		onInit();
		if (this.World.Assets.getOrigin().getID() == "scenario.barbarian_raiders")
		{
			this.m.Skills.add(this.new("scripts/skills/effects/skald_horn_effect"));
		}
	});
});