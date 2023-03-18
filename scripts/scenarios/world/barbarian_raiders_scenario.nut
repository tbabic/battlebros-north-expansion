this.barbarian_raiders_scenario <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},
	function create()
	{
		this.m.ID = "scenario.barbarian_raiders";
		this.m.Name = "Barbarians of the North";
		this.m.Description = "[p=c][img]gfx/ui/events/event_08.png[/img][/p][p]You are a warrior and a raider. Your whole life has been battle and struggle and it's not about to change now.\n\n[color=#bcad8c]Barbarian Leader:[/color] Start with a leader that has permanently bad relations with civilized factions but friendly with a barbarian settlement. If the leader dies, the campaign ends.\n[color=#bcad8c]Barbarian dozen:[/color] Can not have more than 12 men.\n[color=#bcad8c]Father\'s Sword:[/color] Start with a greatsword inherited from your father.\n[color=#bcad8c]Mercenary Path:[/color] Make decisions to become mercenary and remove restrictions or stay barbarian.[/p]";
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
		items.equip(this.new("scripts/items/helmets/barbarians/leather_headband"));
		
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
		this.reassignBanners();
		
		local barbarians = createBarbarianSettlement()
		local coords = barbarians.coords;
		
		this.World.State.m.Player = this.World.spawnEntity("scripts/entity/world/player_party", coords.X, coords.Y);
		
		//this.World.Events.addSpecialEvent("event.survivor_recruits");
		
		this.World.Assets.updateLook(5);
		this.World.getCamera().setPos(this.World.State.m.Player.getPos());
		this.Time.scheduleEvent(this.TimeUnit.Real, 1000, function ( _tag )
		{
			this.Music.setTrackList([
				"music/barbarians_02.ogg"
			], this.Const.Music.CrossFadeTime);
			this.World.Events.fire("event.barbarian_raiders_scenario_intro");
		}, null);
		
		
	}
	
	function createBarbarianSettlement()
	{
		local f = this.new("scripts/factions/barbarian_settlement_faction");
		local c = getCoordinates(f);
		local s = this.World.spawnLocation("scripts/entity/world/settlements/barbarian_village", c);
		
		s.updateProperties();
		s.build();
		
		
		local allies = f.getAllies();
		this.World.FactionManager.m.Factions.push(f);
		f.setName(s.getName());
		f.setID(this.World.FactionManager.m.Factions.len()-1);
		f.setDescription(s.getDescription());
		f.setBanner(11);
		f.setDiscovered(true);
		f.getFlags().set("IsBarbarianFaction", true);
		
		f.setPlayerRelation(50.0);
		f.addSettlement(s, true);
		f.getFlags().set("BarbarianSettlementNoAllies", true);
		if (s.getOwner() == null)
		{
			logInfo("owner null");
			s.setOwner(f);
		}
		f.onUpdateRoster();
		checkFactions();
		
		
		local allies = f.getAllies();
		logInfo("Alliance: " + f.getName());
		foreach (a in allies) {
			if (this.World.FactionManager.getFaction(a) == null) {
				logInfo("Faction: null");
			} else {
				logInfo("Faction: " + this.World.FactionManager.getFaction(a).getName());
			}
		}
		
		return {
			faction = f,
			settlement = s,
			coords = c
		};
		
	}
	
	function getCoordinates(f) {
	
		
		local spawnTile = spawnTile(f);
		if (spawnTile != null) {
			return spawnTile.Coords;
		}
		local northVillage;
		local maxY = this.World.getMapSize().Y;
		local minY = this.World.getMapSize().Y * 0.7;
		local maxX = this.World.getMapSize().X;
		local minX = 0;
		local northernX = 0;
		local northTile;
		
		
		for( local i = 0; i != this.World.EntityManager.getSettlements().len(); i = ++i )
		{
			local v = this.World.EntityManager.getSettlements()[i];

			if (v.getTile().Coords.Y > minY && !v.isIsolatedFromRoads())
			{
				minY = v.getTile().Coords.Y;
				northernX = v.getTile().Coords.X;
				northTile = v.getTile();
				
			}
			
			if (v.getTile().Coords.X > maxX && !v.isIsolatedFromRoads())
			{
				maxX = v.getTile().Coords.X;
				
			}
			
			if (v.getTile().Coords.X < minX && !v.isIsolatedFromRoads())
			{
				minX = v.getTile().Coords.X;
				
			}
		}
		logInfo("northLocationMin: " + minY);
		logInfo("northLocationMax: " + maxY);
		logInfo("eastLocationMin: " + minX);
		logInfo("eastLocationMax: " + maxX);
		
		local navSettings = this.World.getNavigator().createSettings();
		navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost_Flat;

		local halfY = (this.World.getMapSize().Y + minY) / 2;
		
		local maxX = this.Math.max(halfY, maxX);
		
		local maxBoundaryY = this.Math.max(maxX, minY + 5);
		local minBoundaryY = this.Math.min(maxX, minY + 5);
		
		local halfX = (minX + maxX) / 2;
		local xOffset = 10;
		if (northernX > halfX) {
			xOffset = -10;
		}
		
		
		
		local maxBoundaryX = this.Math.max(halfX, northernX + xOffset);
		local minBoundaryX = this.Math.min(halfX, northernX + xOffset);
		
		logInfo("minX:" + minBoundaryX);
		logInfo("maxX:" + maxBoundaryX);
		logInfo("minY:" + minBoundaryY);
		logInfo("maxY:" + maxBoundaryY);
		
		do
		{
			local x = this.Math.rand(minBoundaryX, maxBoundaryX);
			local y = this.Math.rand(minBoundaryY, maxBoundaryY);
			logInfo("x: " + x);
			logInfo("y: " + y);

			if (!this.World.isValidTileSquare(x, y))
			{
			}
			else
			{
				local tile = this.World.getTileSquare(x, y);
				logInfo("cand x coord:" + tile.Coords.X);
				logInfo("cand y coord:" + tile.Coords.Y);

				if (tile.Type == this.Const.World.TerrainType.Ocean || tile.Type == this.Const.World.TerrainType.Shore || tile.IsOccupied || tile.HasRoad)
				{
				}
				
				else
				{
					//local path = this.World.getNavigator().findPath(tile, northTile, navSettings, 0);

					spawnTile = tile;
					logInfo("x coord:" + x);
					logInfo("y coord:" + y);
					break;
				}
			}
		}
		while (1);
		
		logInfo("spawn x coord:" + spawnTile.Coords.X);
		logInfo("spawn y coord:" + spawnTile.Coords.Y);
		logInfo("square x coord:" + spawnTile.SquareCoords.X);
		logInfo("square y coord:" + spawnTile.SquareCoords.Y);
		
		return spawnTile.Coords;
	
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
		local f = this.World.Flags.get("NorthExpansionCivilLevel");
		logInfo("flag:" + f);
		
		if (this.World.Flags.get("NorthExpansionCivilLevel") >= 3)
		{
			this.World.Assets.m.BrothersMax = 20;
		}
		
		this.World.Events.addSpecialEvent("event.survivor_recruits");
		
		
		
		
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
	
	function checkFactions()
	{
		local factions = clone this.World.FactionManager.getFactions(true);
		foreach (f in factions) {
			if (f == null || f.isHidden() || !f.isDiscovered() || f.getSettlements().len() == 0)
			{
				continue;
			}
			local allies = f.getAllies();
			//logInfo("Alliance: " + f.getName());
			foreach (a in allies) {
				//logInfo(a);
			}
			
			
		}
	}
	
	function spawnTile(f) {
		local settlements = this.World.EntityManager.getSettlements();
		local action = this.new("scripts/factions/actions/build_barbarian_camp_action");
		action.m.Faction = f;
		local spawnTile = action.getTileToSpawnLocation(100, [
				this.Const.World.TerrainType.Mountains
			], 9, 12, 0, 0, 0, null, 0.8, 0.95);
		return spawnTile;
	}
	
	function reassignBanners()
	{
		local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		
		
		local northMost = null;
		
		local houses = [];
		
		
		foreach (n in nobles)
		{
			local house = {
				Faction = n,
				North = 0
			}
			local maxY = 0;
			foreach (s in n.getSettlements())
			{
				if (s.getTile().Coords.Y > house.North)
				{
					house.North = s.getTile().Coords.Y;
				}
			}
			
			houses.push(house);
		}
		
		houses.sort(function ( _a, _b )
		{
			if (_a.North > _b.North)
			{
				return -1;
			}
			else if (_a.North < _b.North)
			{
				return 1;
			}

			return 0;
		});
		
		local northBanners = [2, 6, 8];
		local middleBanners = [3, 5,7];
		local southBanners = [4, 9, 10];
		
		logInfo("banners");
		
		houses[0].Faction.setBanner(northBanners[this.Math.rand(0, northBanners.len() - 1)]);
		houses[1].Faction.setBanner(middleBanners[this.Math.rand(0, middleBanners.len() - 1)]);
		houses[2].Faction.setBanner(southBanners[this.Math.rand(0, southBanners.len() - 1)]);
	}
	

	

});

