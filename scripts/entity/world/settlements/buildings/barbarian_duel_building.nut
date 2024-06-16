this.barbarian_duel_building <- this.inherit("scripts/entity/world/settlements/buildings/building", {
	m = {
		Champion = null,
		Level = 0,
		CooldownUntil = 0,
		LastUpdate = -1
	},
	
	function setCooldown(_days)
	{
		this.m.CooldownUntil = this.World.getTime().Days + _days;
		this.m.Settlement.getFlags().set("NEM_duel_cooldown", this.m.CooldownUntil);
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
		if(!this.World.getTime().IsDaytime)
		{
			return this.m.UIImageNight;
		}
		
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
		this.logInfo("last update:" + this.m.LastUpdate);
		if(this.m.LastUpdate >= this.World.getTime().Days)
		{
			return;
		}
		
		this.m.Champion = null;
		this.m.Settlement.getFlags().set("NEM_duel_champion", 0);
		this.m.LastUpdate = this.World.getTime().Days;
		this.m.Settlement.getFlags().set("NEM_duel_lastUpdate", this.m.LastUpdate);
		this.logInfo("new update: " + this.m.LastUpdate);
		
		local renown = this.World.Assets.getBusinessReputation();
		
		local upgradeChance = 0;
		upgradeChance += this.m.Level;
		upgradeChance += this.Math.floor(renown / 100);
		upgradeChance = this.Math.min(40, upgradeChance);
		this.logInfo("upgrade chance: " + upgradeChance);
		
		local r = this.Math.rand(1, 100);
		this.logInfo("roll: " + r);
		r += upgradeChance;
		
		local currentChance = 0;
		foreach (champ in ::NorthMod.Const.DuelChampions )
		{
			currentChance += champ.Chance;
			this.logInfo("compare: " + r + " ? " + currentChance);
			if(r <= currentChance)
			{
				this.m.Champion = champ;
				break;
			}
		}
		
		
		local minPartyLevel = 100;
		local roster = this.World.getPlayerRoster().getAll();
		foreach( bro in roster )
		{
			if (bro.m.Level < minPartyLevel)
			{
				minPartyLevel = bro.m.Level;
			}
		}
		if (this.m.Champion != null && this.m.Champion.MaxBroLevel < minPartyLevel)
		{
			this.m.Champion = null;
			return;
		}
		this.m.Settlement.getFlags().set("NEM_duel_champion", this.m.Champion.Level);
		
		
	}
	
	function getChampion()
	{
		return this.m.Champion;
	}
	
	
	function isDuelAvailable()
	{
		return this.m.Champion != null;
	}
	
	function championDefeated()
	{
		this.m.Level += this.m.Champion.Level;
		this.m.Champion == null;
		this.m.Settlement.getFlags().set("NEM_duel_level", this.m.Level);
	}

	function onSettlementEntered()
	{	
		this.findChampion();
	}

	function onSerialize( _out )
	{
		this.building.onSerialize(_out);
		//_out.writeU32(this.m.CooldownUntil);
	}

	function onDeserialize( _in )
	{
		this.building.onDeserialize(_in);
		this.m.CooldownUntil = this.m.Settlement.getFlags().getAsInt("NEM_duel_cooldown");
		this.m.Level = this.m.Settlement.getFlags().getAsInt("NEM_duel_level");
		this.m.LastUpdate = this.m.Settlement.getFlags().getAsInt("NEM_duel_lastUpdate");
		local championLevel = this.m.Settlement.getFlags().getAsInt("NEM_duel_champion");
		if (championLevel > 0)
		{
			this.m.Champion = ::NorthMod.Const.DuelChampions[championLevel - 1];
		}

		
		//this.m.CooldownUntil = _in.readU32();
	}
	
	
});

