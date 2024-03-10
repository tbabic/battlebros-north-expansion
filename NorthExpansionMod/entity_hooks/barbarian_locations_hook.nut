::mods_hookBaseClass("entity/world/location", function(o) {
	
	
	
	local create = ::mods_getMember(o, "create");
	::mods_override(o, "create", function()
	{
		create();
		
		
		if (this.getTypeID() != "location.barbarian_camp" && 
			this.getTypeID() != "location.barbarian_shelter" && 
			this.getTypeID() != "location.barbarian_sanctuary") {
			return;
		}
		logInfo("barbarian camp conversion: " + this.getTypeID());
		if (this.getTypeID() == "location.barbarian_shelter") 
		{
			this.m.campSize <- 1;
		}
		
		if (this.getTypeID() == "location.barbarian_camp") 
		{
			this.m.campSize <- 2;
		}
		
		if (this.getTypeID() == "location.barbarian_sanctuary") 
		{
			this.m.campSize <- 3;
		}
		this.m.combatForced <- false;
		
		
		this.m.Modifiers <- this.new("scripts/entity/world/settlement_modifiers");
		this.m.Situations <- [];
		this.m.CurrentBuilding <- null;
		
		this.m.Buildings <- [];
		this.m.Buildings.resize(6, null)
		this.m.Buildings[2] = this.new("scripts/entity/world/settlements/buildings/barbarian_market_building");
		this.m.Buildings[5] = this.new("scripts/entity/world/settlements/buildings/barbarian_crowd_building");
		this.m.Buildings[3] = this.new("scripts/entity/world/settlements/buildings/barbarian_taxidermist_building");
		this.m.Buildings[4] = this.new("scripts/entity/world/settlements/buildings/barber_building");
		
		for( local i = 0; i < this.m.Buildings.len(); i = ++i )
		{
			if (this.m.Buildings[i] != null)
			{
				this.m.Buildings[i].setSettlement(this);
			}
		}
		
		
		/*this.setOnCombatWithPlayerCallback(function(_location, _isPlayerAttacking = true){
			local event = this.World.Events.getEvent("event.barbarian_duel");
			event.m.Location = _location;
			if(event.isValid())
			{
				this.World.Events.fire("event.barbarian_duel");
			}
		})*/
		
		this.setOnEnterCallback(function (_location) {
			local forceAttack = this.World.State.m.IsForcingAttack;
			if (_location.isAttackable() && (!_location.isAlliedWithPlayer() || forceAttack))
			{
				if (_location.onEnteringCombatWithPlayer())
				{
					logInfo("really start combat");
					this.World.State.showCombatDialog();
				}
			}
			
			
			else if (_location.isEnterable())
			{
				_location.updateRoster();
				_location.updateShop();
				this.World.State.showTownScreen();
			}
			
			
			return;
		});
		
		this.getMusic <- function() {
			if (!this.World.getTime().IsDaytime)
			{
				return [];
			}
			return this.Const.Music.BarbarianTracks;
		}
		
		this.isEnterable <- function()
		{
			this.logInfo("is enterable");
			if (!this.World.Flags.get("NorthExpansionActive")) {
				this.logInfo("expansion not active");
				return false;
			}
			
			if (this.World.Flags.get("NorthExpansionCivilLevel") > 1)
			{
				this.logInfo("civil level: " + this.World.Flags.get("NorthExpansionCivilLevel"));
				return false;
			}

			else if (!this.isAlliedWithPlayer())
			{
				this.logInfo("not allied");
				return false;
			}
			this.logInfo("enterable");
			logInfo("last: " + this.World.State.m.LastEnteredTown);
			return true;
		}
		
		this.getUIInformation <- function()
		{
			this.logInfo("get UI information");
			local terrainType = this.getTile().Type
			local settlementImages = this.Const.World.TerrainSettlementImages[terrainType];
			local night = !this.World.getTime().IsDaytime;
			local water =  null;
			
			local backgroundCenter = "ui/settlements/townhall_01_snow"
			if (terrainType != this.Const.World.TerrainType.Snow) {
				backgroundCenter = "ui/settlements/townhall_01";
			}
			
			local result = {
				Title = this.getName(),
				SubTitle = this.m.Description,
				Assets = this.UIDataHelper.convertAssetsInformationToUIData(),
				HeaderImagePath = null,
				Background = settlementImages.Background + (night ? "_night" : "") + ".jpg",
				BackgroundCenter = backgroundCenter + (night ? "_night" : "") + ".png",
				BackgroundLeft = null,
				BackgroundRight = null,
				Ramp = settlementImages.Ramp + (night ? "_night" : "") + ".png",
				RampPathway = "ui/settlements/ramp_01_planks" + (night ? "_night" : "") + ".png",
				Mood = settlementImages.Mood + ".png",
				Foreground = settlementImages.Foreground + (night ? "_night" : "") + ".png",
				Water = null
				Slots = [],
				Situations = [],
				Contracts = [],
				IsContractActive = this.World.Contracts.getActiveContract() != null,
				IsContractsLocked = false
			};

			foreach( building in this.m.Buildings )
			{
				if (building == null || building.isHidden())
				{
					result.Slots.push(null);
				}
				else
				{
					local b = {
						Image = building.getUIImage(),
						Tooltip = building.getTooltip()
					};
					result.Slots.push(b);
				}
			}

			foreach( situation in this.m.Situations )
			{
				local exists = false;

				foreach( e in result.Situations )
				{
					if (e.ID == situation.getID())
					{
						exists = true;
						break;
					}
				}

				if (exists)
				{
					continue;
				}

				result.Situations.push({
					ID = situation.getID(),
					Icon = situation.getIcon()
				});
			}
			logInfo("get contracts for location");
			local contracts = this.getContracts();
			logInfo("location contracts:" + this.getID() + " - " + contracts.len());
			
			foreach( i, contract in contracts )
			{
				if (i > 9)
				{
					break;
				}

				if (contract.isActive())
				{
					continue;
				}

				local c = {
					Icon = contract.getBanner(),
					ID = contract.getID(),
					IsNegotiated = contract.isNegotiated(),
					DifficultyIcon = contract.getUIDifficultySmall()
				};
				result.Contracts.push(c);
			}
			

			return result;
		}

		this.getUIPreloadInformation <- function()
		{
			
			this.logInfo("get UI preload information");
			local night = !this.World.getTime().IsDaytime;
			local terrainType = this.getTile().Type
			local settlementImages = this.Const.World.TerrainSettlementImages[terrainType];
			
			local result = {
				Background = settlementImages.Background + (night ? "_night" : "") + ".jpg",
				BackgroundCenter = "ui/settlements/townhall_01" + (night ? "_night" : "") + ".png",
				BackgroundLeft = null,
				BackgroundRight = null,
				Ramp = settlementImages.Ramp + (night ? "_night" : "") + ".png",
				RampPathway = "ui/settlements/ramp_01_planks" + (night ? "_night" : "") + ".png",
				Mood = settlementImages.Mood + ".png",
				Foreground = settlementImages.Foreground + (night ? "_night" : "") + ".png",
				Water = null,
				Slots = []
			};

			foreach( building in this.m.Buildings )
			{
				if (building == null || building.isHidden())
				{
					result.Slots.push(null);
				}
				else
				{
					local b = {
						Image = building.getUIImage(),
						Tooltip = building.getTooltip()
					};
					result.Slots.push(b);
				}
			}

			return result;
		}
		
		
		
		this.updateRoster <- function()
		{
			local lastRosterUpdate = this.getFlags().getAsInt("lastRosterUpdate");
			local daysPassed = (this.Time.getVirtualTimeF() - lastRosterUpdate) / this.World.getTime().SecondsPerDay;
			
			if (lastRosterUpdate != 0 && daysPassed < 2)
			{
				return;
			}

			lastRosterUpdate = this.Time.getVirtualTimeF();
			this.getFlags().set("lastRosterUpdate", lastRosterUpdate);
			local roster = this.World.getRoster(this.getID());
			local current = roster.getAll();
			local iterations = this.Math.max(1, daysPassed / 2);
			local activeLocations = 0;


			local rosterMin = this.m.campSize;
			local rosterMax = rosterMin + this.m.campSize -1;

			if (this.World.FactionManager.getFaction(this.getFaction()).getPlayerRelation() < 50)
			{
				rosterMin = rosterMin * (this.World.FactionManager.getFaction(this.m.Factions[0]).getPlayerRelation() / 50.0);
				rosterMax = rosterMax * (this.World.FactionManager.getFaction(this.m.Factions[0]).getPlayerRelation() / 50.0);
			}

			rosterMin = rosterMin * this.m.Modifiers.RecruitsMult;
			rosterMax = rosterMax * this.m.Modifiers.RecruitsMult;
			rosterMin = rosterMin + this.World.Assets.m.RosterSizeAdditionalMin;
			rosterMax = rosterMax + this.World.Assets.m.RosterSizeAdditionalMax;

			if (iterations < 7)
			{
				for( local i = 0; i < iterations; i = ++i )
				{
					for( local maxRecruits = this.Math.rand(this.Math.max(0, rosterMax / 2 - 1), rosterMax - 1); current.len() > maxRecruits;  )
					{
						local n = this.Math.rand(0, current.len() - 1);
						roster.remove(current[n]);
						current.remove(n);
					}
				}
			}
			else
			{
				roster.clear();
				current = [];
			}

			local maxRecruits = this.Math.rand(rosterMin, rosterMax);
			local draftList = [
				"barbarian_background",
				"barbarian_background",
				"barbarian_background",
				"wildman_background"
			];



			this.World.Assets.getOrigin().onUpdateDraftList(draftList);

			while (maxRecruits > current.len())
			{
				local bro = roster.create("scripts/entity/tactical/player");
				bro.setStartValuesEx(draftList);
				current.push(bro);
			}

			this.World.Assets.getOrigin().onUpdateHiringRoster(roster);
			logInfo("roster size: " + roster.getSize());
		}
		
		updateShop <-function ()
		{
			local lastShopUpdate = this.getFlags().getAsInt("lastShopUpdate");
			local daysPassed = (this.Time.getVirtualTimeF() - lastShopUpdate) / this.World.getTime().SecondsPerDay;

			if (lastShopUpdate != 0 && daysPassed < 3)
			{
				return;
			}

			lastShopUpdate = this.Time.getVirtualTimeF();
			this.getFlags().set("lastShopUpdate", lastShopUpdate);
			foreach( building in this.m.Buildings )
			{
				if (building != null)
				{
					building.onUpdateShopList();

					if (building.getStash() != null)
					{
						foreach( s in this.m.Situations )
						{
							s.onUpdateShop(building.getStash());
						}
					}
				}
			}
		}
		
		this.onSlotClicked <- function( _i, _townScreen )
		{
			if (this.m.Buildings[_i] != null)
			{
				this.m.CurrentBuilding = this.m.Buildings[_i];
				this.m.Buildings[_i].onClicked(_townScreen);
			}
		}
		
		this.getCurrentBuilding <- function()
		{
			return this.m.CurrentBuilding;
		}
		
		this.hasAttachedLocation <- function(attachedLocation) {
			false;
		}
		
		getSellPriceMult <- function()
		{
			local p = this.getPriceMult() * this.World.Assets.getSellPriceMult();
			local r = this.World.FactionManager.getFaction(this.getFaction()).getPlayerRelation();

			if (r < 50)
			{
				p = p - (50.0 - r) * 0.006;
			}
			else if (r > 50)
			{
				p = p + (r - 50.0) * 0.003;
			}

			p = p * this.m.Modifiers.SellPriceMult;
			return p;
		}
		
		getBuyPriceMult <- function()
		{
			local p = this.getPriceMult() * this.World.Assets.getBuyPriceMult();
			local r = this.World.FactionManager.getFaction(this.getFaction()).getPlayerRelation();

			if (r < 50)
			{
				p = p + (50.0 - r) * 0.006;
			}
			else if (r > 50)
			{
				p = p - (r - 50.0) * 0.003;
			}

			p = p * this.m.Modifiers.BuyPriceMult;
			return p;
		}
		
		getPriceMult <- function()
		{
			return 1.0 * this.m.Modifiers.PriceMult;
		}
		
		getFoodPriceMult <- function()
		{
			return this.m.Modifiers.FoodPriceMult;
		}
		
		getModifiers <- function()
		{
			return this.m.Modifiers;
		}
		
		getProduceAsString <- function()
		{
			return "goods";
		}
			
		hasBuilding <- function( _id )
		{
			foreach( b in this.m.Buildings )
			{
				if (b != null && b.getID() == _id)
				{
					return true;
				}
			}

			return false;
		}
		
		getSituationByID <- function( _id )
		{
			foreach( e in this.m.Situations )
			{
				if (e.getID() == _id)
				{
					return e;
				}
			}

			return null;
		}

		getSituationByInstance <- function( _instanceID )
		{
			foreach( e in this.m.Situations )
			{
				if (e.getInstanceID() == _instanceID)
				{
					return e;
				}
			}

			return null;
		}

		hasSituation <- function( _id )
		{
			foreach( e in this.m.Situations )
			{
				if (e.getID() == _id)
				{
					return true;
				}
			}

			return false;
		}

		addSituation <- function( _s, _validForDays = 0 )
		{
			if (!_s.isStacking())
			{
				this.removeSituationByID(_s.getID());
			}

			if (this.m.Situations.len() >= 10)
			{
				this.m.Situations[0].onRemoved(this);
				this.m.Situations.remove(0);
			}

			this.m.Situations.push(_s);
			_s.setInstanceID(this.World.EntityManager.getNextSituationID());

			if (_validForDays != 0)
			{
				_s.setValidForDays(_validForDays);
			}
			else if (_s.getDefaultDays() != 0)
			{
				_s.setValidForDays(_s.getDefaultDays());
			}

			_s.onAdded(this);
			this.m.Modifiers.reset();

			foreach( s in this.m.Situations )
			{
				s.onUpdate(this.m.Modifiers);
			}

			return _s.getInstanceID();
		}

		removeSituationByID <- function( _id )
		{
			foreach( i, e in this.m.Situations )
			{
				if (e.getID() == _id)
				{
					e.onRemoved(this);
					this.m.Situations.remove(i);
					this.m.Modifiers.reset();

					foreach( s in this.m.Situations )
					{
						s.onUpdate(this.m.Modifiers);
					}

					break;
				}
			}
		}

		removeSituationByInstance <- function( _instanceID )
		{
			foreach( i, e in this.m.Situations )
			{
				if (e.getInstanceID() == _instanceID)
				{
					e.onRemoved(this);
					this.m.Situations.remove(i);
					this.m.Modifiers.reset();

					foreach( s in this.m.Situations )
					{
						s.onUpdate(this.m.Modifiers);
					}

					return 0;
				}
			}

			return _instanceID;
		}

		updateSituations <- function()
		{
			local garbage = [];

			foreach( i, s in this.m.Situations )
			{
				if (!s.isValid())
				{
					garbage.push(i);
				}
				else if (s.getValidUntil() == 0)
				{
					if (!this.World.Contracts.hasContractWithSituation(s.getInstanceID()))
					{
						garbage.push(i);
					}
				}
			}

			garbage.reverse();

			foreach( g in garbage )
			{
				this.m.Situations[g].onRemoved(this);
				this.m.Situations.remove(g);
			}
		}

		getSituations <- function()
		{
			return this.m.Situations;
		}
		
		this.updateChieftain <- function() {
			//Create roster for barbarian faction
			local faction = this.World.FactionManager.getFaction(this.getFaction());
			if (faction == null) {
				return;
			}
			
			if(!this.World.Flags.get("NorthExpansionBarbarianRoster")) {
				
				this.World.createRoster(faction.getID());
			}
			this.World.Flags.set("NorthExpansionBarbarianRoster", true);
			local roster = this.World.getRoster(faction.getID());
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
				character.setTitle(::NorthMod.Utils.barbarianTitle());
			}
			
			character.m.Name = ::NorthMod.Utils.barbarianNameOnly();
			character.assignRandomEquipment();
			character.getFlags().set("NorthExpansionChieftain", this.getID());
		}
		
		this.getChieftain <- function() {
			local roster = this.World.getRoster(this.World.FactionManager.getFaction(this.getFaction()).getID());
			foreach( character in roster.getAll() )
			{
				if (character.getFlags().get("NorthExpansionChieftain") == this.getID())
				{
					return character;
				}
			}
			return null;
		}
		
		this.changeChieftain <- function (){
			character = this.getChieftain();
			character.m.Name = ::NorthMod.Utils.barbarianNameOnly();
			character.setTitle(::NorthMod.Utils.barbarianTitle());
			character.assignRandomEquipment();
		}
		
		local onInit = ::mods_getMember(o, "onInit");
		::mods_override(o, "onInit", function() {
			onInit();
			this.World.createRoster(this.getID());
		});
		
		local addFaction = ::mods_getMember(o, "addFaction");
		::mods_override(o, "addFaction", function(_f) {
			addFaction(_f);
			this.updateChieftain();
		});
		
		local getTooltip = ::mods_getMember(o, "getTooltip");
		::mods_override(o, "getTooltip", function() {
			local ret = getTooltip();
			if (this.isAlliedWithPlayer()) {
				if (this.isShowingDefenders() && !this.isHiddenToPlayer() && this.m.Troops.len() != 0 && this.getFaction() != 0)
				{
					ret.extend(this.getTroopComposition());
				}
				else
				{
					ret.push({
						id = 20,
						type = "text",
						icon = "ui/orientation/player_01_orientation.png",
						text = "Unknown garrison"
					});
				}

				ret.push({
					id = 21,
					type = "hint",
					icon = "ui/orientation/terrain_orientation.png",
					text = "This location is " + this.Const.Strings.TerrainAlternative[this.getTile().Type]
				});

				if (this.isShowingDefenders() && this.getCombatLocation().Template[0] != null && this.getCombatLocation().Fortification != 0 && !this.getCombatLocation().ForceLineBattle)
				{
					ret.push({
						id = 20,
						type = "hint",
						icon = "ui/orientation/palisade_01_orientation.png",
						text = "This location has fortifications"
					});
				}
			}
			return ret;
		});
		
		this.m.ContractAction <- this.new("scripts/factions/contracts/nem_barbarians_new_contract_action");
		this.m.ContractAction.setHome(this);
		this.getContracts <- function() {
			logInfo("getContracts: " + this.getID());
			logInfo("contracts faction: " + this.getFaction());
			local faction = this.World.FactionManager.getFaction(this.getFaction());
			if (faction == null) {
				return [];
			}
			local factionContracts = faction.getContracts();
			local locationContracts = [];
			foreach (contract in factionContracts)
			{
				logInfo("evaluate home: " + contract.getHome() + " ?=" + this);
				logInfo("evaluate home ids: " + contract.getHome().getID() + " ?=" + this.getID());
				if (contract.getHome().getID() == this.getID()) {
					locationContracts.push(contract);
				}
			}
			return locationContracts;
		}
		
		this.isReadyForContract <- function() {
			logInfo("isReadyForContract: " + this.getID());
			if (this.getContracts().len() >= this.m.campSize)
			{
				return false;
			}
			local faction = this.World.FactionManager.getFaction(this.getFaction());
			logInfo("id: " + this.getID() + " - " + this.getTypeID() + "- " + this.getName());
			logInfo("isReadyForContract:" + faction);
			this.m.ContractAction.setFaction(faction);
			this.m.ContractAction.update(false);
			logInfo("isReadyForContract score:" + this.m.ContractAction.getScore());
			return this.m.ContractAction.getScore() != 0;
			
		}
		
		this.createNewContract <- function() {
			logInfo("createNewContract: " + this.getID());
			this.m.ContractAction.execute(false);
		}
		
		this.getUIContractInformation <- function() {
			this.m.Modifiers.reset();

			foreach( s in this.m.Situations )
			{
				s.onUpdate(this.m.Modifiers);
			}

			local result = {
				Contracts = [],
				IsContractActive = this.World.Contracts.getActiveContract() != null,
				IsContractsLocked = false
			};
			local contracts = this.getContracts();

			foreach( i, contract in contracts )
			{
				if (i > 9)
				{
					break;
				}

				if (contract.isActive())
				{
					continue;
				}

				local c = {
					Icon = contract.getBanner(),
					ID = contract.getID(),
					IsNegotiated = contract.isNegotiated(),
					DifficultyIcon = contract.getUIDifficultySmall()
				};
				result.Contracts.push(c);
			}

			return result;
		}
		

	});
	
	
	
	
	
	
	
	
	
	
	
	
});
