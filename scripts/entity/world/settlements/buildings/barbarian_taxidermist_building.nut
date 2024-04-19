this.barbarian_taxidermist_building <- this.inherit("scripts/entity/world/settlements/buildings/taxidermist_building", {
	m = {},
	function create()
	{
		this.taxidermist_building.create();
		this.m.UIImage = "ui/settlements/barbarian_taxidermist";
		this.m.UIImageNight = "ui/settlements/barbarian_taxidermist_night";
	}
	
	function onUpdateDraftList( _list )
	{
	}

});

