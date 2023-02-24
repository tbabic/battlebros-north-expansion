this.barbarian_village <- this.inherit("scripts/entity/world/settlement", {
	m = {},
	function create()
	{
		this.settlement.create();
		this.m.Name = this.getRandomName([
			"Frysdolk"
		]);
		this.m.DraftList = [
			"barbarian_background",
			"barbarian_background",
			"barbarian_background",
			"wildman_background"
		];
		this.m.UIDescription = "Some huts huddled together";
		this.m.Description = "A small group of huts huddled together, defying the harsh snowy winds of the north.";
		this.m.UIBackgroundCenter = "ui/settlements/townhall_01_snow";
		this.m.UIBackgroundLeft = null;
		this.m.UIBackgroundRight = null;
		this.m.UIRampPathway = "ui/settlements/ramp_01_planks";
		this.m.UISprite = "ui/settlement_sprites/townhall_01.png";
		this.m.Sprite = "world_wildmen_02_snow";
		this.m.Lighting = "";
		this.m.Rumors = this.Const.Strings.RumorsSnowSettlement;
		this.m.Culture = this.Const.World.Culture.Northern;
		this.m.IsMilitary = false; //TODO: should it be military?
		this.m.Size = 1;
		this.m.HousesType = 1;
		this.m.HousesMin = 0;
		this.m.HousesMax = 0;
		this.m.AttachedLocationsMax = 0;
	}
	
	function onInit() {
		logInfo("init tileType:" + this.getTile().Type);
		if (this.getTile().Type != this.Const.World.TerrainType.Snow) {
			this.m.UIBackgroundCenter = "ui/settlements/townhall_01";
			this.m.Sprite = "world_wildmen_02";
		}
		this.settlement.onInit();
		//TODO: taxidermist???
		//TODO: barber
	}

	function onBuild()
	{
		logInfo("tileType:" + this.getTile().Type);
		if (this.getTile().Type != this.Const.World.TerrainType.Snow) {
			this.m.UIBackgroundCenter = "ui/settlements/townhall_01";
			this.m.Sprite = "world_wildmen_02";
		}
		this.addBuilding(this.new("scripts/entity/world/settlements/buildings/crowd_building"), 5);
		this.addBuilding(this.new("scripts/entity/world/settlements/buildings/barbarian_market_building"), 2);
	}
	
	function getUIInformation()
	{
		local result = this.settlement.getUIInformation();
		result.BackgroundCenter = "";
		result.BackgroundLeft = "";
		result.BackgroundRight = "";
		return result;
	}
	
	function getUIPreloadInformation()
	{
		local result = this.settlement.getUIPreloadInformation();
		result.BackgroundCenter = "";
		result.BackgroundLeft = "";
		result.BackgroundRight = "";
		return result;
	}
	
	function addSituation( _s, _validForDays = 0 ){
		
		local validSituations = [
			"situation.abducted_children",
			"situation.disappearing_villagers",
			"situation.hunting_season",
			"situation.greenskins",
			"situation.raided",
			"situation.short_on_food",
			"situation.sickness",
			"situation.snow_storms",
			"situation.terrified_villagers",
			"situation.terrifying_nightmares",
			"situation.unhold_attacks",
			"situation.well_supplied"

		];
	
	
		this.settlement.addSituation( _s, _validForDays = 0 );
	}

		

});

