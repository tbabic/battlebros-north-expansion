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
		this.m.IsMilitary = false;
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
		
		local taxidermist = this.new("scripts/entity/world/settlements/buildings/barbarian_taxidermist_building");
		taxidermist.onUpdateDraftList = function(_list){};
		this.addBuilding(taxidermist);
		this.addBuilding(this.new("scripts/entity/world/settlements/buildings/barber_building"));
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
	
	function isEnterable()
	{
		
		logInfo("last roster update:" + this.m.LastRosterUpdate);
		
		logInfo("situations on enter:");
		foreach(s in this.m.Situations)
		{
			if (s == null)
			{
				logInfo("null situation");
			}
			logInfo(s.getID());
		}
		
		if (!this.m.IsActive)
		{
			return false;
		}

		if (!this.getOwner().isAlliedWithPlayer())
		{
			return false;
		}

		return true;
	}
	
	function updateRoster( _force = false )
	{
		logInfo("last roster update:" + this.m.LastRosterUpdate);
		logInfo("force: " + _force);
		local daysPassed = (this.Time.getVirtualTimeF() - this.m.LastRosterUpdate) / this.World.getTime().SecondsPerDay;
		logInfo("dayPassed:" + daysPassed);
		this.settlement.updateRoster(_force);
	}
	
	function addSituation( _s, _validForDays = 0 )
	{
		logInfo("Situation Frysdolk: " + _s.getID() + " - " + _s.getInstanceID());
		return this.settlement.addSituation(_s, _validForDays);
	}
	
	function updateSituations()
	{
		
		logInfo("contract manager:");
		foreach( c in this.World.Contracts.m.Open)
		{
			if (c != null)
			{
				logInfo("contract: " + c.getType() + " - " + c.getID() + " - " + c.getSituationID());
			}
		}
		
		logInfo("situations update1:");
		foreach(s in this.m.Situations)
		{
			if (s == null)
			{
				logInfo("null situation");
			}
			logInfo(s.getID());
			
			logInfo(this.Time.getVirtualTimeF());
			logInfo(s.m.ValidUntil);
		}
		local garbage = [];

		foreach( i, s in this.m.Situations )
		{
			logInfo("validity")
			if (!s.isValid())
			{
				logInfo("invalid");
				garbage.push(i);
			}
			else if (s.getValidUntil() == 0)
			{
				logInfo("contract?");
				if (!this.World.Contracts.hasContractWithSituation(s.getInstanceID()))
				{
					logInfo("no contract");
					garbage.push(i);
				}
			}
		}

		garbage.reverse();

		foreach( g in garbage )
		{
			logInfo("remove: " + this.m.Situations[g].getID());
			this.m.Situations[g].onRemoved(this);
			this.m.Situations.remove(g);
		}
		
		logInfo("situations update2:");
		foreach(s in this.m.Situations)
		{
			if (s == null)
			{
				logInfo("null situation");
			}
			logInfo(s.getID());
		}
	}

		

});

