this.barbarian_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		MinimumCost = this.Const.World.Spawn.Troops.BarbarianThrall.Cost * 20,
		OfferStep = 0.33,
	},
	
	function create()
	{
		this.logInfo("create barb contract");
		this.contract.create();
		
		this.m.Flags.set("NEM_thralls", 0);
		this.m.Flags.set("NEM_marauders", 0);
		this.m.Flags.set("NEM_champions", 0);
		this.m.Flags.set("NEM_unitOffer", 0.0);
	}
	
	function clear()
	{
		this.contract.clear();
		this.World.getGuestRoster().clear();
	}
	
	function addGuests()
	{
		local thralls = this.m.Flags.getAsInt("NEM_thralls");
		local marauders = this.m.Flags.getAsInt("NEM_marauders");
		local champions = this.m.Flags.getAsInt("NEM_champions");
		local roster = this.World.getGuestRoster();
		for (local i = 1; i<= thralls; i++)
		{
			local unit = roster.create("scripts/entity/tactical/humans/barbarian_thrall_guest");
		}
		for (local i = 1; i<= marauders; i++)
		{
			local unit = roster.create("scripts/entity/tactical/humans/barbarian_marauder_guest");
		}
		for (local i = 1; i<= champions; i++)
		{
			local unit = roster.create("scripts/entity/tactical/humans/barbarian_champion_guest");
		}
		
		local units = roster.getAll();
		
		local startPosition = 21 - this.Math.floor(units.len()/2);
		if (startPosition < 18)
		{
			startPosition = 18;
		}
		for (local i = 0; i < units.len(); i++)
		{
			units[i].setFaction(1);
			units[i].assignRandomEquipment();
			units[i].setPlaceInFormation(startPosition + i);

		}
		
	}
	
	function positionGuests()
	{
		local startPosition = this.Math.max(18, 21 - this.Math.floor(units.len()/2));
		local units = roster.getAll()
		for( local i = 0; i < units.len(); i++ )
		{
			units[i].setPlaceInFormation(startPosition + i);
		}
	}
	
	function getUIBulletpoints( _objectives = true, _payment = true )
	{
		this.logInfo("ui bulletpoints");
		
		local result = this.contract.getUIBulletpoints(_objectives, _payment);
		
		local thralls = this.m.Flags.getAsInt("NEM_thralls");
		local marauders = this.m.Flags.getAsInt("NEM_marauders");
		local champions = this.m.Flags.getAsInt("NEM_champions");
		
		if (!_objectives || !_payment)
		{
			return result;
		}
		
		local _items = [];
		if(thralls > 0)
		{
			_items.push({
				icon = "ui/icons/icon_contract_swords.png",
				text = thralls + " thrall" + ((thralls > 1) ? "s" : "" )
			});
		}
		
		if(marauders > 0)
		{
			_items.push({
				icon = "ui/icons/icon_contract_swords.png",
				text = marauders + " reaver" + ((marauders > 1) ? "s" : "" )
			});
		}
		
		if(champions > 0)
		{
			_items.push({
				icon = "ui/icons/icon_contract_swords.png",
				text = champions + " chosen"
			});
		}
		
		if (_items.len() > 0)
		{
			local r = {
				title = "Help",
				items = _items,
				fixed = true
			};
			result.push(r);
		}
		
		return result;
	}
	
	function importSettlementIntro()
	{
		local relation = this.World.FactionManager.getFaction(this.m.Faction).getPlayerRelation();

		if (relation <= 35)
		{
			this.m.Screens.push(::NorthMod.Const.Contracts.IntroSettlementCold);
		}
		else if (relation > 70)
		{
			this.m.Screens.push(::NorthMod.Const.Contracts.IntroSettlementFriendly);
		}
		else
		{
			this.m.Screens.push(::NorthMod.Const.Contracts.IntroSettlementNeutral);
		}
	}
	

	
	function moreHelp()
	{
		local offer = this.m.Flags.getAsFloat("NEM_unitOffer");
		if (offer + this.m.OfferStep > 1)
		{
			return;
		}

		local moneyStep = this.m.Payment.Pool*this.m.OfferStep;
		local currentStep = this.Math.round(offer / this.m.OfferStep);
		local newStep = 0;
		this.logInfo("currentStep : " + currentStep);
		this.logInfo("minimumCost: " + this.m.MinimumCost);
		this.logInfo("OfferStep: " + this.m.OfferStep);
		
		for (local step = 1; (currentStep + step)*this.m.OfferStep <= 1; step++)
		{
			this.logInfo("step: " + step);
			this.logInfo("offer: " + step*this.m.OfferStep)
			
			if (step*moneyStep > this.m.MinimumCost)
			{
				this.logInfo("break step;")
				newStep = currentStep + step;
				break;
			}
		}
		if (newStep <= currentStep)
		{
			return;
		}
		
		this.m.Flags.set("NEM_unitOffer",newStep*this.m.OfferStep);
		return;
	}
	
	function lessHelp()
	{
		local offer = this.m.Flags.getAsFloat("NEM_unitOffer");
		if (offer - this.m.OfferStep <= 0)
		{
			this.m.Flags.set("NEM_unitOffer",0);
			return;
		}
		
		local moneyStep = this.m.Payment.Pool*this.m.OfferStep;
		local currentStep = this.Math.round(offer / this.m.OfferStep);
		local newStep = 0;
		
		for (local step = 1; (currentStep - step) > 0; step--)
		{
			if (step*moneyStep > this.m.MinimumCost)
			{
				newStep = currentStep - step;
				break;
			}
		}
		if(newStep < currentStep && newStep > 0)
		{
			this.m.Flags.set("NEM_unitOffer",newStep*this.m.OfferStep);
			return;
		}
		
		this.m.Flags.set("NEM_unitOffer",newStep*this.m.OfferStep);
		return;
		
	}
	
	function calculateHelpUnits()
	{
		this.logInfo("calculate help");
		local offer = this.m.Flags.getAsFloat("NEM_unitOffer");
		this.m.Flags.set("NEM_thralls", 0);
		this.m.Flags.set("NEM_marauders", 0);
		this.m.Flags.set("NEM_champions", 0);
		if (offer == 0)
		{
			return;
		}
		local unitCosts = [];
		local units = [];
		
		if (this.m.DifficultyMult > 1.1)
		{
			unitCosts.push(this.Const.World.Spawn.Troops.BarbarianChampion.Cost * 20);
			units.push("NEM_champions");
		}
		if (this.m.DifficultyMult > 0.9)
		{
			unitCosts.push(this.Const.World.Spawn.Troops.BarbarianMarauder.Cost * 20);
			units.push("NEM_marauders");
		}
		unitCosts.push(this.m.MinimumCost);
		units.push("NEM_thralls");
		
		local money = this.m.Payment.Pool;
		
		local offerMoney = money*offer;
		local totalCost = 0;
		while(offerMoney >= this.m.MinimumCost)
		{
			for(local i = 0; i< units.len(); i++)
			{
				if(offerMoney >= unitCosts[i])
				{
					totalCost += unitCosts[i];
					this.m.Flags.increment(units[i], 1);
					offerMoney -= unitCosts[i];
				}
			}
		}
		this.logInfo("totalCost: " + totalCost);
		return totalCost;
	}
	
	

});

