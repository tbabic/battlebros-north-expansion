this.barbarian_duel_building <- this.inherit("scripts/entity/world/settlements/buildings/building", {
	m = {
		ChampionLevel = 0,
		ChampionIndex = null,
		Level = 0,
		CooldownUntil = 0
	},
	
	function setCooldown(_days)
	{
		this.m.CooldownUntil = this.World.getTime().Days + _days;
	}
	
	function getCooldownDays()
	{
		
		if (this.m.CooldownUntil <= this.World.getTime().Days)
		{
			return 0;
		}
		return this.m.CooldownUntil - this.World.getTime().Days;
	}
	
	function isClosed()
	{
		return this.World.getTime().Days < this.m.CooldownUntil;
	}
	
	function getUIImage()
	{
		if (this.isClosed() || !this.isDuelAvailable())
		{
			return "ui/settlements/dueling_circle_empty";
		}
		else
		{
			return this.m.UIImage;
		}
	}

	function create()
	{
		this.building.create();
		this.m.ID = "building.duel";
		this.m.UIImage = "ui/settlements/dueling_circle";
		this.m.UIImageNight = "ui/settlements/dueling_circle_night";
		this.m.Tooltip = "world-town-screen.main-dialog-module.Duel";
		this.m.Name = "Dueling circle";
	}

	function onClicked( _townScreen )
	{
		this.logInfo("duel - clicked");
		if (!this.World.getTime().IsDaytime)
		{
			return;
		}
			
		local event = this.World.Events.getEvent("event.barbarian_dueling_circle");
		event.setHome(this.m.Settlement);
		
		//this.World.State.m.MenuStack.popAll();
		this.World.Events.m.ActiveEvent = event;
		event.fire();
		this.World.State.showEventScreenFromTown(event, false, false);

	}
	
	function findChampion()
	{
		//renown thresholds
		//1500 or above- only champions
		// 1000 or above only chosen and champion
		// 500 or above, reavers, chosen and champions
		
		local renown = this.World.Assets.getBusinessReputation();
		local fighterStrength = 0;
		local fighter = null;
		
		local troops = this.m.Settlement.getTroops();
		foreach( i, t in troops )
		{
			if (t.ID != this.Const.EntityType.BarbarianThrall 
				&& t.ID != this.Const.EntityType.BarbarianMarauder
				&& t.ID != this.Const.EntityType.BarbarianChampion)
			{
				continue;
			}
			
			if (t.Script.len() != "")
			{
				if (t.Strength > fighterStrength)
				{
					fighter = t;
					this.m.ChampionIndex = i;
				}
			}
		}
		if (fighter == null)
		{
			return null;
		}
		this.logInfo("find champion: " + fighter.ID);
		if(fighter.ID == this.Const.EntityType.BarbarianThrall && renown < 500 && this.m.Level == 0)
		{
			this.m.ChampionLevel = 1;
			return fighter;
		}
		
		if(fighter.ID == this.Const.EntityType.BarbarianMarauder && renown < 1000 && this.m.Level <= 1)
		{
			this.m.ChampionLevel = 2;
			return fighter;
		}
		
		if(fighter.ID == this.Const.EntityType.BarbarianChampion && fighter.Variant == 0 && renown < 1500 && this.m.Level <= 1)
		{
			this.m.ChampionLevel = 3;
			return fighter;
		}
		if (fighter.ID == this.Const.EntityType.BarbarianChampion && fighter.Variant > 0) {
			this.m.ChampionLevel = 4;
			return fighter;
		}
		this.m.ChampionIndex = null;
		return null;

	}
	
	function getChampion()
	{
		if(this.m.ChampionIndex != null && this.m.ChampionIndex >= 0 && this.m.ChampionIndex < this.m.Settlement.getTroops().len())
		{
			return this.m.Settlement.getTroops()[this.m.ChampionIndex];
		}
		
		return null;
	}
	
	function isDuelAvailable()
	{
		return this.getChampion() !=null;
	}

	function onSettlementEntered()
	{	
		this.findChampion();
	}

	function onSerialize( _out )
	{
		this.m.Settlement.getFlags().set("NEM_duel_cooldown", this.m.CooldownUntil);
		this.m.Settlement.getFlags().set("NEM_duel_level", this.m.Level);
		this.building.onSerialize(_out);
		//_out.writeU32(this.m.CooldownUntil);
	}

	function onDeserialize( _in )
	{
		this.building.onDeserialize(_in);
		this.m.CooldownUntil = this.m.Settlement.getFlags().getAsInt("NEM_duel_cooldown");
		this.m.Level = this.m.Settlement.getFlags().getAsInt("NEM_duel_level");
		//this.m.CooldownUntil = _in.readU32();
	}
});

