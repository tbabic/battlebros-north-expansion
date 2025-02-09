this.nem_barbarians_new_contract_action <- this.inherit("scripts/factions/faction_action", {
	m = {
        ContractActions = [],
		Home = null
    },
	function create()
	{
		this.m.ID = "nem_barbarians_new_contract_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 3;
		this.m.IsStartingOnCooldown = false;
		this.m.IsSettlementsRequired = true;
		this.faction_action.create();
		
		foreach(a in this.availableActions())
		{
			local card = this.new(a);
			this.m.ContractActions.push(card);
		}
	}
	
	function setHome( _home)
	{
		if (typeof _home == "instance")
		{
			this.m.Home = _home;
		}
		else
		{
			this.m.Home = this.WeakTableRef(_home);
		}
		
		foreach(c in this.m.ContractActions)
		{
			c.setHome(this.m.Home);
		}
		
	}
	
	function setFaction( _f )
	{
		this.m.Faction = this.WeakTableRef(_f);
		foreach(contractAction in this.m.ContractActions)
		{
			contractAction.setFaction(_f);
		}
	}

	function onUpdate( _faction )
	{
		//this.logInfo("onUpdate new contract");
		this.m.Score = 0;
		
		if (!this.World.Flags.get("NorthExpansionActive"))
		{
			//this.logInfo("onUpdate new contract return1");
			return;
		}
		
		if (this.World.Flags.get("NorthExpansionCivilLevel") >= 3)
		{
			//this.logInfo("onUpdate new contract return2");
			return;
		}
		
		if (_faction.getType() != this.Const.FactionType.Barbarians)
		{
			
			this.logInfo("onUpdate new contract return3");
			this.logInfo(_faction.getType() + " ?= " + this.Const.FactionType.Barbarians);
			this.logInfo(_faction.getID());
			return;
		}
		this.logInfo("onUpdate new contract2");
		foreach(contractAction in this.m.ContractActions)
		{
			//logInfo("actionfaction:" + contractAction.getFaction());
			if (contractAction.getFaction() == null)
			{
				contractAction.setFaction(getFactionOfType( this.Const.FactionType.Barbarians ));
			}
			//logInfo("actionfaction2:" + contractAction.getFaction())
			contractAction.update();
			if (contractAction.getScore() > 0) {
				this.m.Score = 1;
			}
		}
		
	}

	function onClear()
	{
	}

	function onExecute( _faction )
	{
		local allowSkip = this.m.Home.getFlags().get("NEM_allow_contract_skip");
		if (allowSkip && this.Math.rand(1, 10) > 1 && false)
		{
			this.logInfo("skipping contract: " + this.m.Home.getName());
			this.m.Home.getFlags().set("NEM_allow_contract_skip", false);
			return;
		}
		this.m.Home.getFlags().set("NEM_allow_contract_skip", true);
		local scores = [];
		foreach(contractAction in this.m.ContractActions)
		{
			this.logInfo("score: " + contractAction.getID() + " -> " + contractAction.getScore() + " / " + this.m.Home.getName() + " - " + this.m.Home.getID());
			scores.push(contractAction.getScore());
		}
		logInfo("calling score picker");
		local i = ::NorthMod.Utils.scorePicker(scores);
		if (i == null) {
			return;
		}
		//i = 27;
		this.logInfo("picked action:" + i + " - " + this.m.ContractActions[i].getID() + "/" + this.m.Home.getID());
		this.m.ContractActions[i].execute();
		//this.m.ContractActions[this.m.ContractActions.len()-1].execute();
	}
	
	function availableActions() {
		return [
			//contracts to convert
			
			// "scripts/factions/contracts/free_greenskin_prisoners_action",
			// "scripts/factions/contracts/privateering_action", //barbarianize
			
			//converted
			"scripts/factions/contracts/nem_raid_location_action",
			"scripts/factions/contracts/nem_barbarian_king_action",
			"scripts/factions/contracts/nem_drive_away_bandits_action", 
			"scripts/factions/contracts/nem_drive_away_barbarians_action",
			"scripts/factions/contracts/nem_hunting_alps_action",
			"scripts/factions/contracts/nem_hunting_hexen_action",
			"scripts/factions/contracts/nem_hunting_lindwurms_action",
			"scripts/factions/contracts/nem_hunting_schrats_action", 
			"scripts/factions/contracts/nem_hunting_unholds_action", 
			"scripts/factions/contracts/nem_hunting_webknechts_action",
			"scripts/factions/contracts/nem_obtain_item_action",
			"scripts/factions/contracts/nem_raid_caravan_action",
			"scripts/factions/contracts/nem_return_item_action",
			"scripts/factions/contracts/nem_roaming_beasts_action",
			
			"scripts/factions/contracts/nem_defend_settlement_greenskins_action",
			"scripts/factions/contracts/nem_defend_settlement_bandits_action",
			"scripts/factions/contracts/nem_defend_settlement_barbarians_action",
			"scripts/factions/contracts/nem_destroy_orc_camp_action",
			"scripts/factions/contracts/nem_destroy_goblin_camp_action",
			"scripts/factions/contracts/nem_confront_warlord_action",
			"scripts/factions/contracts/nem_discover_location_action",
			"scripts/factions/contracts/nem_defend_settlement_nobles_action",
			
			
			"scripts/factions/contracts/nem_find_artifact_action", 
			"scripts/factions/contracts/nem_investigate_cemetery_action", 
			"scripts/factions/contracts/nem_last_stand_action", 
			"scripts/factions/contracts/nem_root_out_undead_action",
			
			
			"scripts/factions/contracts/nem_privateering_action",
			"scripts/factions/contracts/nem_decisive_battle_action",
			//TODO:
			//privateering contract - holy and civil war
			// attack aftermath of decisive battle - civil war
			// interrupt siege and defeat both parties - holy and civil war
			
	
		];
	}

});

