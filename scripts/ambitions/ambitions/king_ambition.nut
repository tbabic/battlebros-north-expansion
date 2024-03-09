this.king_ambition <- this.inherit("scripts/ambitions/ambition", {
	m = {
		LastCombatId = null,
		DefeatedArmies = 0,
		DefeatedCamps = 0,
		heroesSpawned = false,
		heroesConquered = false
	},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.king";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "The north needs a king.";
		this.m.RewardTooltip = "You'll become a King of the North";
		this.m.UIText = "Become a King of the North";
		this.m.TooltipText = "Defeat opposing barbarians and improve your reputation.";
		this.m.SuccessText = "[img]gfx/ui/events/event_31.png[/img]The north needs a king. The north has a king. You've won battles against other barbarians, the clans and settlements have sworn fealty to you. There is no one left to oppose you and if the you, they will be crushed.";
		this.m.SuccessButtonText = "Long live the king!.";
	}
	
	function getTooltipText()
	{
		if (this.World.Assets.getBusinessReputation() < 3000)
		{
			this.m.TooltipText += "\nReach 3000 renown";
		}
		
		local toDefeatArmies = 8 - this.m.DefeatedArmies;
		local toDefeatCamps = 4 - this.m.DefeatedCamps;
		
		if (toDefeatArmies > 0)
		{
			this.m.TooltipText += "\nDefeat roaming "+toDefeatArmies+" barbarian parties";
		}
		
		if (toDefeatCamps > 0)
		{
			this.m.TooltipText += "\nDestriy "+toDefeatCamps+" barbarian camps";
		}
		
		this.m.TooltipText += "Find and visit \'The Stone Heroes\' location";
		
	}

	function onUpdateScore()
	{
		if (this.World.Ambitions.getDone() < 2)
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 2500)
		{
			return;
		}
		if (!this.World.Flags.get("NorthExpansionCivilActive"))
		{
			return;
		}
		if (this.World.Flags.get("NorthExpansionCivilLevel") >= 3) {
			return;
		}
		this.m.Score = 10;
	}
	
	function onLocationDestroyed( _location )
	{
		if (this.World.FactionManager.getFaction(_location.getFaction()).getType() == this.Const.FactionType.Barbarians)
		{
			++this.m.DefeatedCamps;
		}
	}
	
	function onPartyDestroyed( _party )
	{
		local f = this.World.FactionManager.getFaction(_party.getFaction());
		if (f.getType() == this.Const.FactionType.Barbarians)
		{
			++this.m.DefeatedArmies;
		}
	}

	function onCheckSuccess()
	{
		
		if (this.World.Assets.getBusinessReputation() < 3000)
		{
			return false;
		}
		
		if (this.m.DefeatedArmies < 8)
		{
			return false;
		}
		
		if (this.m.DefeatedCamps < 4)
		{
			return false;
		}
		
		if (!this.m.heroesSpawned)
		{
			//TODO: spawn heroes;
			this.m.heroesSpawned = true;
		}
		
		return this.m.heroesConquered;
	}

	function onReward()
	{
		//TODO: king reward armor, noble factions relations
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/icons/special.png",
			text = "King armor"
		});
	}

	function onSerialize( _out )
	{
		this.ambition.onSerialize(_out);
		_out.writeU16(this.m.DefeatedCamps);
		_out.writeU16(this.m.DefeatedArmies);
		_out.writeBool(this.m.heroesSpawned);
		_out.writeBool(this.m.heroesConquered);
	}

	function onDeserialize( _in )
	{
		this.ambition.onDeserialize(_in);
		this.m.DefeatedCamps = _in.readU16();
		this.m.DefeatedArmies = _in.readU16();
		this.m.heroesSpawned = _in.readBool();
		this.m.heroesConquered = _in.readBool();
	}

});

