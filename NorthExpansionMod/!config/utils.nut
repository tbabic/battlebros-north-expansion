::NorthMod.Utils <-{

	function stringSplit(sourceString, delimiter)
	{
		local leftover = sourceString;
		local results = [];
		while(true)
		{
			local index = leftover.find(delimiter);
			if (index == null) {
				results.push(leftover);
				break;
			}
			local leftSide = leftover.slice(0, index);
			results.push(leftSide);
			leftover = leftover.slice(index + delimiter.len());
		}
		return results;
	}

	function stringReplace( sourceString, textToReplace, replacementText )
	{
		local strings = this.stringSplit(sourceString, textToReplace);
		local result = strings[0];
		if(strings.len() == 1)
		{
			return result;
		}
		
		for (local i = 1; i < strings.len(); i++) {
			 result += replacementText + strings[i];
			 
		}
		return result;
	}

	function scorePicker(scores)
	{
		this.logInfo("executing score picker");
		local totalScore = 0;
		for (local i = 0; i < scores.len(); i++)
		{
			totalScore += scores[i];
		}
		local r = this.Math.rand(1, totalScore);
		this.logInfo("score picked:" + r + ":" +totalScore);
		for (local i = 0; i < scores.len(); i++) {
			this.logInfo("scores[" + i + "](" + r +") <= "+ scores[i]);
			if (scores[i] > 0 && r <= scores[i])
			{
				return i;
			}
			r = r - scores[i];
		}
		return null;
	}
	
	function checkSuitableTerrain(_terrain, villageType)
	{
		foreach (v in this.Const.World.Settlements.Villages_small)
		{
			if (this.String.contains(v.Script, villageType))
			{
				return v.isSuitable(_terrain);
			}
		}
		return false;
	}
	
	function isNearbyForest(location)
	{
		if (location.getFlags().has("NEMisNearbyForest")) {
			return location.getFlags().get("NEMisNearbyForest");
		}
		local worldmap = this.MapGen.get("world.worldmap_generator");
		local terrain = worldmap.getTerrainInRegion(location.getTile());
		local result = checkSuitableTerrain(terrain, "small_lumber_village")
		location.getFlags().set("NEMisNearbyForest", result);
	}
	
	function isNearbySnow(location)
	{
		if (location.getFlags().has("NEMisNearbySnow")) {
			//return location.getFlags().get("NEMisNearbySnow");
		}
		local worldmap = this.MapGen.get("world.worldmap_generator");
		local terrain = worldmap.getTerrainInRegion(location.getTile());
		local result = checkSuitableTerrain(terrain, "small_snow_village");
		this.logInfo("local terrain: " + terrain.Local);
		this.logInfo("adjacents");
		foreach(i, adjacent in terrain.Adjacent)
		{
			this.logInfo(i + ", " + adjacent);
		}
		
		location.getFlags().set("NEMisNearbySnow", result);
	}
	
	function getBestTerrain(location)
	{
		local tile = location.getTile();
		local terrain = [];
		terrain.resize(this.Const.World.TerrainType.COUNT, 0);

		for( local i = 0; i < 6; i = ++i )
		{
			if (!tile.hasNextTile(i))
			{
			}
			else
			{
				++terrain[tile.getNextTile(i).Type];
			}
		}

		terrain[this.Const.World.TerrainType.Plains] = this.Math.max(0, terrain[this.Const.World.TerrainType.Plains] - 1);

		if (terrain[this.Const.World.TerrainType.Steppe] != 0 && this.Math.abs(terrain[this.Const.World.TerrainType.Steppe] - terrain[this.Const.World.TerrainType.Hills]) <= 2)
		{
			terrain[this.Const.World.TerrainType.Steppe] += 2;
		}

		if (terrain[this.Const.World.TerrainType.Snow] != 0 && this.Math.abs(terrain[this.Const.World.TerrainType.Snow] - terrain[this.Const.World.TerrainType.Hills]) <= 2)
		{
			terrain[this.Const.World.TerrainType.Snow] += 2;
		}

		local highest = 0;

		for( local i = 0; i < this.Const.World.TerrainType.COUNT; i = ++i )
		{
			if (i == this.Const.World.TerrainType.Ocean || i == this.Const.World.TerrainType.Shore)
			{
			}
			else if (terrain[i] >= terrain[highest])
			{
				highest = i;
			}
		}
		return highest;
	}


	function guaranteedTalents(bro, talent, number)
	{

		local talents = bro.getTalents();
		if (talents[talent] > 0 && talents[talent] < number )
		{
			this.logInfo("setting talent: " + talent + "to " + number);
			talents[talent] = number;
		}
		else if (talents[talent] == 0) {
			local count = 0;
			local min = 10;
			local minTalent = null;
			for (local i = 0; i < talents.len(); i++) {
				if (talents[i] > 0) {
					count++;
					if (talents[i] < min && i != this.Const.Attributes.MeleeDefense && i != this.Const.Attributes.MeleeSkill) {
						min = talents[i];
						minTalent = i;
					}
				}
				
			}
			if(count < 3) {
				talents[talent] = number;
			} else {
				talents[minTalent] = 0;
				talents[talent] = number;
			}
		}
		
		
		
		bro.m.Attributes = [];
		bro.fillAttributeLevelUpValues(this.Const.XP.MaxLevelWithPerkpoints - 1);
	}
	
	function barbarianNameOnly()
	{
		return ::NorthMod.Const.BarbarianNames[this.Math.rand(0, ::NorthMod.Const.BarbarianNames.len()-1)];
	}
	
	function barbarianTitle()
	{
		return ::NorthMod.Const.BarbarianTitles[this.Math.rand(0, ::NorthMod.Const.BarbarianTitles.len()-1)];
	}
	
	function barbarianNameAndTitle()
	{
		return this.barbarianNameOnly() + " " + this.barbarianTitle();
	}
	
	function nearestFactionNeighbour(_home, _faction)
	{
		local lowestDistance = 9999;
		local lowestDistanceSettlement;
		local f = _faction;
		local camps = f.getSettlements();
		
		foreach( b in camps )
		{
			if (b == _home || b.getID() == _home.getID() || b.isLocationType(this.Const.World.LocationType.Unique))
			{
				continue;
			}
			if (b.getTypeID() != "location.barbarian_camp" && 
				b.getTypeID() != "location.barbarian_shelter" && 
				b.getTypeID() != "location.barbarian_sanctuary") {
				continue;
			}


			local d = _home.getTile().getDistanceTo(b.getTile());

			if (d < lowestDistance)
			{
				lowestDistance = d;
				lowestDistanceSettlement = b;
			}
		}
		return {
			settlement = lowestDistanceSettlement,
			distance = lowestDistance
		};
	}
	
	function nearestBarbarianNeighbour(_home)
	{
		local f = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians);
		return nearestFactionNeighbour(_home, f);
	}
	
	function setIsHostile(_entity, _isHostile)
	{
		_entity.getFlags().set("NEM_isHostile", _isHostile);
	}
	
	function isHostile(_entity)
	{
		return _entity.getFlags().get("NEM_isHostile");
	}
	
	function addOverrideHostility(_entity)
	{
		local _isAlliedWithPlayer = ::mods_getMember(_entity, "isAlliedWithPlayer");
		::mods_override(_entity, "isAlliedWithPlayer", function() {
			local isHostile = ::NorthMod.Utils.isHostile(this)
			if (isHostile) {
				return false;
			}
			return _isAlliedWithPlayer()
		});	
		
		local _isAlliedWith = ::mods_getMember(_entity, "isAlliedWith") 
		::mods_override(_entity, "isAlliedWith", function(_p) {
			local isHostile = ::NorthMod.Utils.isHostile(this);
			if (_p.getFaction() == this.Const.Faction.Player && isHostile)
			{
				return false;
			}
			return _isAlliedWith(_p)
		});	
		
	}
	
	function aliveEntitiesByIds( _ids)
	{
		if (ids == null || ids.len() == 0)
		{
			return [];
		}
		local entities = [];
		foreach (id in ids)
		{
			local e = this.World.getEntityByID(id);
			if (e != null && !e.isNull() && e.isAlive())
			{
				entities.push(this.WeakTableRef(e));
			}
		}
		return entities;
		
	}

}