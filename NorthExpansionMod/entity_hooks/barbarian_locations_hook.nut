::mods_hookClass("entity/world/locations/barbarian_camp_location", function(o) {
	o.setOnCombatWithPlayerCallback(function(_location){
		local event = this.World.Events.getEvent("event.barbarian_duel");
		event.m.Location = _location;
		if(event.isValid())
		{
			this.World.Events.fire("event.barbarian_duel");
		}
	})
});

::mods_hookClass("entity/world/locations/barbarian_sanctuary_location", function(o) {
	o.setOnCombatWithPlayerCallback(function(_location){
		local event = this.World.Events.getEvent("event.barbarian_duel");
		event.m.Location = _location;
		if(event.isValid())
		{
			this.World.Events.fire("event.barbarian_duel");
		}
	})
});

::mods_hookClass("entity/world/locations/barbarian_shelter_location", function(o) {
	o.setOnCombatWithPlayerCallback(function(_location){
		local event = this.World.Events.getEvent("event.barbarian_duel");
		event.m.Location = _location;
		if(event.isValid())
		{
			this.World.Events.fire("event.barbarian_duel");
		}
	})
});