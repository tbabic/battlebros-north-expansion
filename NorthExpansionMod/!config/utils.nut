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
			return location.getFlags().get("NEMisNearbySnow");
		}
		local worldmap = this.MapGen.get("world.worldmap_generator");
		local terrain = worldmap.getTerrainInRegion(location.getTile());
		local result = checkSuitableTerrain(terrain, "small_snow_village")
		location.getFlags().set("NEMisNearbySnow", result);
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
	
	function nearestBarbarianNeighbour(_home)
	{
		local lowestDistance = 9999;
		local lowestDistanceSettlement;
		local f = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians);
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
	
	function setIsHostile(_entity, _isHostile)
	{
		_entity.getFlags().set("NEM_isHostile", _isHostile);
	}
	
	function isHostile(_entity)
	{
		return _entity.getFlags().get("NEM_isHostile");
	}

}