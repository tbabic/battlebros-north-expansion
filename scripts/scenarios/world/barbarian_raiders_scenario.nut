this.barbarian_raiders_scenario <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},
	function create()
	{
		this.m.ID = "scenario.barbarian_raiders";
		this.m.Name = "Barbarians of the North";
		this.m.Description = "[p=c][img]gfx/ui/events/event_08.png[/img][/p][p]You are a warrior and a raider. Your whole life has been battle and struggle and it's not about to change now.\n\n[color=#bcad8c]Barbarian Leader:[/color] Start with a leader that has permanently bad relations with civilized factions but friendly with barbarian settlements. If the leader dies, the campaign ends.\n[color=#bcad8c]Barbarian dozen:[/color] Can not have more than 12 men.\n[color=#bcad8c]Father\'s Sword:[/color] Start with a greatsword inherited from your father.\n[color=#bcad8c]Mercenary Path:[/color] Make decisions to become mercenary and remove restrictions or stay barbarian.[/p]";
		this.m.Difficulty = 3;
		this.m.Order = 60;
		this.m.IsFixedLook = true;
	}

	function isValid()
	{
		return this.Const.DLC.Wildmen;
	}
	
	function setBroAppearance(bro, _appearance) {
	
		if (bro == null || _appearance == null) {
			return;
		}
	
		local actor = bro.getBackground().getContainer().getActor();
		
		
		if (_appearance.Faces != null && _appearance.Faces.len() > 0) {
			local sprite = actor.getSprite("head");
			sprite.setBrush(_appearance.Faces[this.Math.rand(0, _appearance.Faces.len() - 1)]);
			sprite.Color = this.createColor("#fbffff");
			sprite.varyColor(0.05, 0.05, 0.05);
			sprite.varySaturation(0.1);
			local body = actor.getSprite("body");
			body.Color = sprite.Color;
			body.Saturation = sprite.Saturation;
		}
		
		if (_appearance.HairColors == null || _appearance.HairColors.len() == 0) {
			return; 
		}
		local hairColor = _appearance.HairColors[this.Math.rand(0, _appearance.HairColors.len() - 1)];
		
		if (_appearance.Hairs != null && _appearance.Hairs.len() > 0)
		{
			local sprite = actor.getSprite("hair");
			sprite.setBrush("hair_" + hairColor + "_" + _appearance.Hairs[this.Math.rand(0, _appearance.Hairs.len() - 1)]);

			if (hairColor != "grey")
			{
				sprite.varyColor(0.1, 0.1, 0.1);
			}
			else
			{
				sprite.varyBrightness(0.1);
			}
		}

		if (_appearance.Beards != null && _appearance.Beards.len() > 0)
		{
			local beard = actor.getSprite("beard");
			beard.setBrush("beard_" + hairColor + "_" + _appearance.Beards[this.Math.rand(0, _appearance.Beards.len() - 1)]);
			beard.Color = actor.getSprite("hair").Color;

			if (this.doesBrushExist(beard.getBrush().Name + "_top"))
			{
				local sprite = actor.getSprite("beard_top");
				sprite.setBrush(beard.getBrush().Name + "_top");
				sprite.Color = actor.getSprite("hair").Color;
			}
		}
	}

	function onSpawnAssets()
	{
		this.logInfo("Barbarian raiders scenario");
		local useDefaultBro = false;
		local roster = this.World.getPlayerRoster();

		for( local i = 0; i < 3; i = ++i )
		{
			local bro;
			bro = roster.create("scripts/entity/tactical/player");
			bro.m.HireTime = this.Time.getVirtualTimeF();
		}

		local bros = roster.getAll();
		
		local _appearance = {
			HairColors = ["black"],
			Faces = ["bust_head_01"],
			Hairs = ["21"],
			Beards = ["17"],
		}
		bros[0].setStartValuesEx([
			"barbarian_background"
		]);
		bros[0].getBackground().m.RawDescription = "You were raised in the harsh north and fought many battles, mostly victorious but you've managed to live through few bitter defeats. But now it's time to find your destiny somewhere south. Working as a mercenary, doing what you do best, fighting, seems like the best way to go forward.";
		bros[0].getBackground().buildDescription(true);
		
		if (useDefaultBro) {
			setBroAppearance(bros[0], _appearance);
			
			foreach( trait in this.Const.CharacterTraits ) {
				bros[0].getSkills().removeByID(trait[0]);
			}
			
			
			local destinedTrait = null;
			destinedTrait = this.new("scripts/skills/traits/destined_trait");
			if (destinedTrait == null) {
				logInfo("destined trait is null");
			} else {
				bros[0].getSkills().add(destinedTrait);
			}
			
			
			local b = bros[0].getBaseProperties();
			b.Hitpoints = 63;
			b.Bravery = 43;
			b.Stamina = 103;
			b.MeleeSkill = 60;
			b.RangedSkill = 32;
			b.MeleeDefense = 4;
			b.RangedDefense = 3;
			b.Initiative = 115;
			bros[0].getSkills().update();
			
			bros[0].setName("Vindurask");
			bros[0].setTitle("Whirlwind");
			
			
		}
		
		bros[0].getSkills().removeByID("trait.survivor");
		bros[0].getSkills().removeByID("trait.greedy");
		bros[0].getSkills().removeByID("trait.loyal");
		bros[0].getSkills().removeByID("trait.disloyal");
		
		local r = Math.rand(1,10);
		if (r <= 2)
		{
			// remove existing traits
			foreach( trait in this.Const.CharacterTraits ) {
				bros[0].getSkills().removeByID(trait[0]);
			}
			
			local trait;
			if (r == 1)
			{
				trait = this.new("scripts/skills/traits/destined_trait")
			}
			else
			{
				trait = this.new("scripts/skills/traits/champion_trait")
			}
			bros[0].getSkills().add(trait);
		}
		
		
		bros[0].getSkills().add(this.new("scripts/skills/traits/player_character_trait"));
		bros[0].setPlaceInFormation(3);
		bros[0].getFlags().set("IsPlayerCharacter", true);
		bros[0].m.PerkPoints = 2;
		bros[0].m.LevelUps = 2;
		bros[0].m.Level = 3;
		bros[0].m.Talents = [];
		local talents = bros[0].getTalents();
		talents.resize(this.Const.Attributes.COUNT, 0);
		talents[this.Const.Attributes.MeleeSkill] = 3;
		talents[this.Const.Attributes.Hitpoints] = 2;
		talents[this.Const.Attributes.MeleeDefense] = 3;
		local items = bros[0].getItems();
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
		items.equip(this.new("scripts/items/armor/barbarians/scrap_metal_armor"));
		local helmet = this.new("scripts/items/helmets/barbarians/leather_headband");
		helmet.setVariant(188);
		items.equip(helmet);
		
		local item = this.new("scripts/items/weapons/named/fathers_sword");
		items.equip(item);
		
		bros[1].setStartValuesEx([
			"barbarian_background"
		]);
		bros[1].getBackground().m.RawDescription = "%name% is your best friend and has followed you all over the north, suffering victories and defeats together. He has no plans to abandon you now.";
		bros[1].getBackground().buildDescription(true);
		
		
		local _appearance2 = {
			HairColors = ["red"],
			Faces = ["bust_head_10"],
			Hairs = ["08"],
			Beards = ["13"],
		}
		setBroAppearance(bros[1], _appearance2);
		
		
		foreach( trait in this.Const.CharacterTraits ) {
			bros[1].getSkills().removeByID(trait[0]);
		}
		
		bros[1].getSkills().add(this.new("scripts/skills/traits/loyal_trait"));
		bros[1].getSkills().add(this.new("scripts/skills/traits/eagle_eyes_trait"));
		
		
		local b = bros[1].getBaseProperties();
		b.Hitpoints = 61;
		b.Bravery = 42;
		b.Stamina = 102;
		b.MeleeSkill = 59;
		b.RangedSkill = 40;
		b.MeleeDefense = 3;
		b.RangedDefense = 5;
		b.Initiative = 117;
		bros[1].getSkills().update();
		
		bros[1].setName("Rikke");
		bros[1].setTitle("The Dogman");
		
		
		bros[1].setPlaceInFormation(4);
		bros[1].m.PerkPoints = 1;
		bros[1].m.LevelUps = 1;
		bros[1].m.Level = 2;
		bros[1].m.Talents = [];
		local talents = bros[1].getTalents();
		talents.resize(this.Const.Attributes.COUNT, 0);
		talents[this.Const.Attributes.MeleeSkill] = 1;
		talents[this.Const.Attributes.RangedSkill] = 3;
		talents[this.Const.Attributes.Hitpoints] = 1;
		local items = bros[1].getItems();
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
		items.equip(this.new("scripts/items/armor/barbarians/reinforced_animal_hide_armor"));
		items.equip(this.new("scripts/items/helmets/barbarians/bear_headpiece"));
		items.equip(this.new("scripts/items/weapons/barbarians/crude_axe"));
		items.addToBag(this.new("scripts/items/weapons/barbarians/heavy_throwing_axe"));
		
		local warhound = this.new("scripts/items/accessory/warhound_item");
		warhound.m.Name = "Fenrir the Warhound";
		items.equip(warhound);
		
		
		
		bros[2].setStartValuesEx([
			"wildman_background"
		]);
		
		foreach( trait in this.Const.CharacterTraits ) {
			bros[2].getSkills().removeByID(trait[0]);
		}
		
		bros[2].getSkills().add(this.new("scripts/skills/traits/iron_jaw_trait"));
		bros[2].getSkills().add(this.new("scripts/skills/traits/feral_trait"));
		
		local b = bros[2].getBaseProperties();
		b.Hitpoints = 66;
		b.Bravery = 46;
		b.Stamina = 115;
		b.MeleeSkill = 55;
		b.RangedSkill = 35;
		b.MeleeDefense = 0;
		b.RangedDefense = -2;
		b.Initiative = 100;
		
		
		bros[2].getSkills().update();
		
		local _appearance3 = {
			HairColors = ["brown"],
			Faces = ["bust_head_10"],
			Hairs = ["shaved"],
			Beards = ["14"],
		}
		setBroAppearance(bros[2], _appearance3);
		bros[2].getSprite("body").setBrush("bust_naked_body_01");
		bros[2].getSprite("tattoo_body").setBrush("scar_02_bust_naked_body_01")
		bros[2].getSprite("tattoo_head").setBrush("scar_02_head")
		
		bros[2].setName("Bjorn");
		bros[2].setTitle("The Wildling");
		bros[2].getBackground().m.RawDescription = "%name% has decided to stay with you, instead of going south. When asked why, he grounts out that north is his home. While not a man of many words, he is absolutely vicious and ferocious specimen in battle. Sometimes it looks like, the closer he is to death, the more dangerous he is.";
		bros[2].getBackground().buildDescription(true);
		bros[2].setPlaceInFormation(13);
		bros[2].m.PerkPoints = 1;
		bros[2].m.LevelUps = 1;
		bros[2].m.Level = 2;
		
		
		bros[2].m.Talents = [];
		
		
		local talents = bros[2].getTalents();
		talents.resize(this.Const.Attributes.COUNT, 0);
		talents[this.Const.Attributes.Hitpoints] = 3;
		talents[this.Const.Attributes.RangedDefense] = 2;
		talents[this.Const.Attributes.MeleeSkill] = 1;
		
		local items = bros[2].getItems();
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
		items.equip(this.new("scripts/items/weapons/barbarians/blunt_cleaver"));
		
		this.World.Assets.m.BusinessReputation = -50;
		this.World.Assets.addMoralReputation(-30.0);
		
		this.World.Assets.getStash().add(this.new("scripts/items/supplies/goat_cheese_item"));
		this.World.Assets.getStash().add(this.new("scripts/items/supplies/smoked_ham_item"));
		this.World.Assets.getStash().add(this.new("scripts/items/weapons/nem_barbarian_drum"));
		this.World.Assets.m.Money = this.World.Assets.m.Money / 2;
		this.World.Assets.m.Ammo = this.World.Assets.m.Ammo / 2;
	}

	function onSpawnPlayer()
	{
		this.World.Flags.set("NorthExpansionActive", true);
		this.World.Flags.set("NorthExpansionCivilLevel", 1);
		
		local f = this.World.Flags.get("NorthExpansionCivilLevel");
		logInfo("flag:" + f);
		
		
		local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local houses = [];

		foreach( n in nobles )
		{
			n.addPlayerRelation(-100.0, "You are considered outlaws and barbarians");
		}
		
		local cityStates = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.OrientalCityState);
		local houses = [];

		foreach( c in cityStates )
		{
			c.addPlayerRelation(-100.0, "You are considered outlaws and barbarians");
		}
		
		local randomVillage;
		local northernmostY = 0;

		for( local i = 0; i != this.World.EntityManager.getSettlements().len(); i = ++i )
		{
			local v = this.World.EntityManager.getSettlements()[i];

			if (v.getTile().SquareCoords.Y > northernmostY && !v.isMilitary() && !v.isIsolatedFromRoads() && v.getSize() <= 2)
			{
				northernmostY = v.getTile().SquareCoords.Y;
				randomVillage = v;
			}
		}

		randomVillage.setLastSpawnTimeToNow();
		local randomVillageTile = randomVillage.getTile();
		local navSettings = this.World.getNavigator().createSettings();
		navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost_Flat;

		do
		{
			local x = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.X - 2), this.Math.min(this.Const.World.Settings.SizeX - 2, randomVillageTile.SquareCoords.X + 2));
			local y = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.Y - 2), this.Math.min(this.Const.World.Settings.SizeY - 2, randomVillageTile.SquareCoords.Y + 2));

			if (!this.World.isValidTileSquare(x, y))
			{
			}
			else
			{
				local tile = this.World.getTileSquare(x, y);

				if (tile.Type == this.Const.World.TerrainType.Ocean || tile.Type == this.Const.World.TerrainType.Shore || tile.IsOccupied)
				{
				}
				else if (tile.getDistanceTo(randomVillageTile) <= 1)
				{
				}
				else
				{
					local path = this.World.getNavigator().findPath(tile, randomVillageTile, navSettings, 0);

					if (!path.isEmpty())
					{
						randomVillageTile = tile;
						break;
					}
				}
			}
		}
		while (1);

		local attachedLocations = randomVillage.getAttachedLocations();
		local closest;
		local dist = 99999;

		foreach( a in attachedLocations )
		{
			if (a.getTile().getDistanceTo(randomVillageTile) < dist)
			{
				dist = a.getTile().getDistanceTo(randomVillageTile);
				closest = a;
			}
		}

		if (closest != null)
		{
			closest.setActive(false);
			closest.spawnFireAndSmoke();
		}
		local s = this.new("scripts/entity/world/settlements/situations/raided_situation");
		s.setValidForDays(5);
		randomVillage.addSituation(s);
		
		this.World.State.m.Player = this.World.spawnEntity("scripts/entity/world/player_party", randomVillageTile.Coords.X, randomVillageTile.Coords.Y);
		this.World.Assets.updateLook(5);
		this.World.getCamera().setPos(this.World.State.m.Player.getPos());
		this.Time.scheduleEvent(this.TimeUnit.Real, 1000, function ( _tag )
		{
			this.Music.setTrackList([
				"music/barbarians_02.ogg"
			], this.Const.Music.CrossFadeTime);
			this.World.Events.fire("event.barbarian_raiders_scenario_intro");
		}, null);
		
		
		local barbarians = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians);
		barbarians.setPlayerRelation(50);
		barbarians.m.IsHidden = false;
		barbarians.m.IsRelationDecaying = true;
		barbarians.m.Banner = 99;
		barbarians.setMotto("\"Winter is here\"");
		barbarians.setDescription("Free barbarian tribes roam the north as they have been for hundreds of years. They raid to claim what they need, and they sacrifice their prisoners in bloody rituals to prove their worth to ancestors who ascended to be gods through their deeds in life. They follow their old ways to this day. They’re the warriors of the north.");
		
	}
	
	
	function onUpdateHiringRoster( _roster )
	{
		if (this.World.Statistics.getFlags().getAsInt("NorthExpansionCivilLevel") < 2)
		{
			local garbage = [];
			local bros = _roster.getAll();

			foreach( i, bro in bros )
			{
				if (bro.getBackground().isNoble())
				{
					garbage.push(bro);
				}
			}

			foreach( g in garbage )
			{
				_roster.remove(g);
			}
		}
	}
	
	
	function onInit()
	{	
		logInfo("scenario on init")
		this.World.Assets.m.BrothersMax = 12;
		local barbarians = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians);
		if (this.World.Flags.get("NorthExpansionCivilLevel") >= 3)
		{
			this.World.Assets.m.BrothersMax = 20;
		}
		else if(barbarians != null)
		{
			
			barbarians.m.IsHidden = false;
			barbarians.m.IsRelationDecaying = true;
		}
		
		
		//this.World.Events.addSpecialEvent("event.survivor_recruits");

	}
	
	function onCombatFinished()
	{
		local roster = this.World.getPlayerRoster().getAll();

		foreach( bro in roster )
		{
			if (bro.getFlags().get("IsPlayerCharacter"))
			{
				return true;
			}
		}

		return false;
	}
	

	
	
	

	

});

