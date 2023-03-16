this.barbarian_settlement_faction <- this.inherit("scripts/factions/faction", {
	m = {
		MaxConcurrentContracts = 1,
		ContractDelay = 1
	},
	function addPlayerRelation( _r, _reason = "" )
	{
		this.faction.addPlayerRelation(_r, _reason);
	}

	function create()
	{
		this.faction.create();
		this.m.Type = this.Const.FactionType.Settlement;
		this.m.Base = "world_base_12";
		this.m.TacticalBase = "bust_base_wildmen_01";
		this.m.CombatMusic = this.Const.Music.BarbarianTracks;
		this.m.RelationDecayPerDay = this.Const.World.Assets.RelationDecayPerDayCivilian;
		this.m.IsHiddenIfNeutral = false;
		this.m.IsRelationDecaying = false;
		
		logInfo("create barbarians");
		foreach (a in this.availableActions()) {
			local card = this.new(a);
			card.setFaction(this);
			this.m.Deck.push(card);
		}
		//TODO: banner
	}

	function onUpdateRoster()
	{
		for( local roster = this.getRoster(); roster.getSize() < 1;  )
		{
			local character = roster.create("scripts/entity/tactical/humans/barbarian_champion");
			
			character.setAppearance();

			if (character.getTitle() != "")
			{
				local currentRoster = roster.getAll();

				foreach( c in currentRoster )
				{
					if (c.getID() != character.getID() && character.getTitle() == c.getTitle())
					{
						character.setTitle("");
						break;
					}
				}
			}

			if (character.getTitle() == "")
			{
				if (this.Math.rand(1,5)  == 1) {
					character.setTitle(this.Const.Strings.BarbarianTitles[this.Math.rand(0, this.Const.Strings.BarbarianTitles.len() - 1)])
				}
				else {
					character.setTitle("of " + this.m.Name);
				}
			}
			
			
			character.m.Name = "Chieftain "+  ::NorthMod.Utils.barbarianNameOnly();
			character.assignRandomEquipment();
			local items = character.getItems();
			items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
			items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
			items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
			items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
			items.equip(this.new("scripts/items/armor/barbarians/hide_and_bone_armor"));
			items.equip(this.new("scripts/items/helmets/barbarians/beastmasters_headpiece"));

		}
	}

	function isReadyForContract()
	{
		if (this.m.Settlements.len() == 0)
		{
			return false;
		}
		
		if( this.getRoster().getSize() < 1)
		{
			return false;
		}

		local delay = 5.0 - (this.getSettlements()[0].getSize() - 1);
		if (this.World.Flags.get("NorthExpansionCivilLevel") == 1)
		{
			delay = 1;
		}
		return this.m.Contracts.len() < this.m.MaxConcurrentContracts && (this.m.LastContractTime == 0 || this.World.getTime().Days <= 1 || this.Time.getVirtualTimeF() > this.m.LastContractTime + this.World.getTime().SecondsPerDay * delay);
	}
	
	function isReadyToSpawnUnit()
	{
		return false;
	}
	
	function addAlly(_a) {
		logInfo("Adding alliance:" + _a);
		if (this.World.FactionManager.getFaction(_a) == null) {
			logInfo("Faction: null");
		} else {
			logInfo("Faction: " + this.World.FactionManager.getFaction(_a).getName());
		}
		if (this.getFlags().get("BarbarianSettlementNoAllies")) {
			return;
		}
		this.faction.addAlly(_a);
	}

	function onSerialize( _out )
	{
		this.faction.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		logInfo("Deserialize barbarians");
		if (this.m.Deck.len() == 0) {
			logInfo("Deserialize barbarian actions");
			foreach (a in this.availableActions()) {
				local card = this.new(c);
				card.setFaction(this);
				this.m.Deck.push(card);
			}
		}
		
		this.faction.onDeserialize(_in);
	}
	
	function availableActions() {
		return [
			//nobles
			"scripts/factions/contracts/raze_attached_location_action",
			"scripts/factions/contracts/destroy_orc_camp_action",
			"scripts/factions/contracts/destroy_goblin_camp_action",
			"scripts/factions/contracts/marauding_greenskins_action",
			"scripts/factions/contracts/b_raid_caravan_action", //barbarianize
			"scripts/factions/contracts/big_game_hunt_action",
			"scripts/factions/contracts/free_greenskin_prisoners_action",
			"scripts/factions/contracts/confront_warlord_action",
			"scripts/factions/contracts/find_artifact_action",
			"scripts/factions/contracts/root_out_undead_action",
			"scripts/factions/contracts/privateering_action", //barbarianize
			"NorthExpansionMod/contracts/nem_barbarian_king_action",
			
			
			//settlement
			//"scripts/factions/contracts/drive_away_bandits_action", // leads to ambushed trade routes situation
			//"scripts/factions/contracts/drive_away_barbarians_action", //barbarianize flavor leads to ambushed trade routes situation
			"scripts/factions/contracts/nem_drive_away_bandits_action",
			"scripts/factions/contracts/nem_drive_away_barbarians_action"
			
			
			"scripts/factions/contracts/investigate_cemetery_action",
			"scripts/factions/contracts/roaming_beasts_action",
			"scripts/factions/contracts/defend_settlement_bandits_action", //barbarianize
			"scripts/factions/contracts/defend_settlement_greenskins_action",
			"scripts/factions/contracts/obtain_item_action",
			"scripts/factions/contracts/discover_location_action",
			"scripts/factions/contracts/hunting_webknechts_action",
			"scripts/factions/contracts/hunting_alps_action",
			"scripts/factions/contracts/hunting_unholds_action", 
			"scripts/factions/contracts/hunting_hexen_action", 
			"scripts/factions/contracts/hunting_schrats_action", 
			"scripts/factions/contracts/hunting_lindwurms_action", //barbarianize
			
			//"scripts/factions/actions/add_random_situation_action" // validate
	
		];
	}
	
	function transformSituations() {
	}
	
	function addContract( _c )
	{
		logInfo("adding contract to barbs:");
		logInfo("contract: " + _c.getType() + " - " + _c.getID() + " - " + _c.getSituationID());
		
		_c.setFaction(this.getID());
		this.m.Contracts.push(_c);
		this.m.LastContractType = _c.getType();
	}
	
	function onSerialize( _out )
	{
		this.faction.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.faction.onDeserialize(_in);
	}
	
	
	
	

});

