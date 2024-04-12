this.barbarian_barber_building <- this.inherit("scripts/entity/world/settlements/buildings/barber_building", {
	m = {},
	function create()
	{
		this.barber_building.create();
		this.m.UIImage = "ui/settlements/barbarian_barber";
		this.m.UIImageNight = "ui/settlements/barbarian_barber_night";
	}

});
