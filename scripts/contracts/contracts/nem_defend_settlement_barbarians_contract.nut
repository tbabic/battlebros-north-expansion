this.nem_defend_settlement_barbarians_contract <- this.inherit("scripts/contracts/contracts/nem_defend_settlement_bandits_contract", {
	m = {

	},
	function create()
	{
		this.nem_defend_settlement_bandits_contract.create();
		this.m.Type = "contract.nem_defend_settlement_barbarians";
	}
	
	function spawnParties(number)
	{
		for( local i = 0; i < number; i++ )
		{
			local nearest = ::NorthMod.Utils.nearestBarbarianNeighbour(this.m.Home);
			local nearest_base = nearest.settlement;
			this.m.Origin = nearest_base;
			local party = f.spawnEntity(nearest_base.getTile(), "Raiders", false, this.Const.World.Spawn.Barbarians, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());				
			::NorthMod.Utils.addOverrideHostility(party);	
			::NorthMod.Utils.setIsHostile(_party, true);
			this.Contract.m.UnitsSpawned.push(party.getID());
		}
	}
	
	function prepareFlags()
	{
		local r = this.Math.rand(1, 100)
		if (r > 50)
		{
			this.Flags.set("IsKidnapping", true);
		}
		if (r > 80)
		{
			this.Flags.set("RaidOnly", true);
		}
	}
	
	function getAttackScreen()
	{
		return "BarbarianAttack";
	}
	
	function createScreens()
	{
		this.nem_defend_settlement_bandits_contract.createScreens();
		this.m.Screens.push({
			ID = "BarbarianAttack",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_135.png[/img]The raiders from one of the northern clans are in sight! They've come to loot and pillage. Prepare for battle and protect the camp!",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
	}


	function onSerialize( _out )
	{
		
		this.nem_defend_settlement_bandits_contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.nem_defend_settlement_bandits_contract.onDeserialize(_in);
		foreach (partyID in this.Contract.m.UnitsSpawned)
		{
			local party = this.World.getEntityByID(partyID);
			if (party != null && party.isAlive())
			{
				::NorthMod.Utils.addOverrideHostility(party);
			}
			
		}
		
	}

});

