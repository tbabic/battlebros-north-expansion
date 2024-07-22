this.barbarian_duel_building <- this.inherit("scripts/entity/world/settlements/buildings/building", {
	m = {
		Champion = null,
		ChampionName = null,
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
			
		/*local event = this.World.Events.getEvent("event.barbarian_dueling_circle");
		event.setHome(this.m.Settlement);
		
		//this.World.State.m.MenuStack.popAll();
		this.World.Events.m.ActiveEvent = event;
		event.fire();
		this.World.State.showEventScreenFromTown(event, false, false);
		this.pushUIMenuStack();*/
		
		local data = this.prepareScreenData();
		::NorthMod.Screens.DuelCircleScreen.setDuelingCircle(this);
		::NorthMod.Screens.DuelCircleScreen.show(data);
		

	}
	

	function prepareScreenData()
	{
		local data = {
			Bros = [],
			Text = "",
			Opponent = null,
			OpponentImage = null
		}
		
		if(this.isClosed())
		{
			data.Text = "You approach the dueling circle but there is no one to fight you. Come back in " + this.getCooldownDays() + " day";
			if (this.getCooldownDays() > 1)
			{
				data.Text += "s";
			}
			return data;
			
		}

		data.Text = "You approach the dueling circle and ask is there a champion in this place who will fight you or one of your men?\n\n"
		if (!this.isDuelAvailable())
		{
			data.Text += "There are no worthy fighters in this place that are willing to step forth to combat one of your warriors. Come back tomorrow."
			return data;
		}
		if (this.m.Champion.Level == 1)
		{
			data.Text += "There are no great champions in this place, but one of the thralls comes forth to fight you and earn his status as a free man."
			data.Opponent = "Barbarian Thrall"
		}
		
		if (this.m.Champion.Level == 2)
		{
			data.Text += "There are no great champions in this place, but a marauder, with the experience of many raids, comes forth to fight you."
			data.Opponent = "Barbarian Reaver"
		}
		
		if (this.m.Champion.Level == 3)
		{
			data.Text += "There are no great champions in this place, but there is an experienced warrior with many victories that comes forth to fight you."
			data.Opponent = "Barbarian Chosen"
		}
		
		if (this.m.Champion.Level == 4)
		{
			data.Text += this.m.ChampionName + " steps forth, you can see he is an impressive warrior with a body of pure muscle, tendon, and scars. A worthy champion."
			data.Opponent = this.m.ChampionName
		}
		data.OpponentImage = this.getChampionImage();
		
		
		
		local roster = this.World.getPlayerRoster().getAll();
		foreach( bro in roster )
		{
			if(bro.getLevel() > this.m.Champion.MaxBroLevel)
			{
				continue;
			}
			
			local background = bro.getBackground();
			local skills = bro.getSkills();
			local uiTraits = [];
			
			foreach( s in skills.m.Skills )
			{
				if (s.getType() == this.Const.SkillType.Trait)
				{
					uiTraits.push({
						id = s.getID(),
						icon = s.getIconColored()
					});
				}
			}
			
			data.Bros.push({
				ID = bro.getID(),
				Name = bro.getName(),
				Level = bro.getLevel(),
				ImagePath = bro.getImagePath(),
				ImageOffsetX = bro.getImageOffsetX(),
				ImageOffsetY = bro.getImageOffsetY(),
				BackgroundImagePath = background.getIconColored(),
				BackgroundText = background.getDescription(),
				Traits = uiTraits
			});
			
		}
		return data;
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
		if(this.m.Settlement.getFlags().has("NEM_duel_champion_name"))
		{
			this.m.Settlement.getFlags().remove("NEM_duel_champion_name");
		}
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
		if (this.m.Champion.Variant == 1)
		{
			this.m.ChampionName = ::NorthMod.Utils.barbarianNameAndTitle();
			this.m.Settlement.getFlags().set("NEM_duel_champion_name", this.m.ChampionName);
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
	
	function prepareDuelRoster()
	{	
		local rosterId = this.toHash(this);
		this.logInfo("duel roster id: " + rosterId);
		
		this.World.Flags.set("NorthExpansionDuelRoster", rosterId);
		this.World.createRoster(this.World.Flags.get("NorthExpansionDuelRoster"));
		
		
		local roster = this.World.getRoster(this.World.Flags.get("NorthExpansionDuelRoster"));
		
		local opponent = roster.create("scripts/entity/tactical/humans/barbarian_duel_placeholder");
		opponent.setFaction(this.Const.Faction.Enemy);
	}
	
	function getChampionImage()
	{
		if(this.m.Champion == null)
		{
			return null;
		}
		if(!this.World.Flags.has("NorthExpansionDuelRoster")) {
			prepareDuelRoster();
		}
		local roster = this.World.getRoster(this.World.Flags.get("NorthExpansionDuelRoster")).getAll();
		local opponent = roster[0];
		opponent.assignEquipment(this.m.Champion.Level);
		
		return opponent.getImagePath();
		
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
			if (this.m.Champion.Variant == 1 && this.m.Settlement.getFlags().has("NEM_duel_champion_name"))
			{
				this.m.ChampionName = this.m.Settlement.getFlags().get("NEM_duel_champion_name");
			}
		}
		
		//this.m.CooldownUntil = _in.readU32();
	}
	
	
});

