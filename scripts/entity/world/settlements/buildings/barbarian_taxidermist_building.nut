this.barbarian_taxidermist_building <- this.inherit("scripts/entity/world/settlements/buildings/taxidermist_building", {
	m = {},
	function create()
	{
		this.taxidermist_building.create();
	}
	
	function onUpdateDraftList( _list )
	{
	}

});

