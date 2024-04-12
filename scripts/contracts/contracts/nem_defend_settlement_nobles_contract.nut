this.nem_defend_settlement_nobles_contract <- this.inherit("scripts/contracts/contracts/nem_defend_settlement_bandits_contract", {
	m = {
		
	},
	function create()
	{
		this.nem_defend_settlement_bandits_contract.create();
		this.m.Type = "contract.nem_defend_settlement_barbarians";
		
		if (this.Math.rand(1, 100) <= 50)
		{
			this.m.DifficultyMult = this.Math.rand(90, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(115, 135) * 0.01;
		}
	}

	function start()
	{
		this.m.Payment.Pool = 1300 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
		
		this.m.Payment.Completion = 1.0;

		this.contract.start();
	}
	
	function spawnParties(number)
	{
		local nearestSettlement = this.Contract.getNearestLocationTo(this.Contract.m.Home, this.World.EntityManager.getSettlements());
		this.m.Origin = nearestSettlement;
		local f = nearestSettlement.getOwner();
		if (this.Math.rand(1, 100) <= 30)
		{
			this.Flags.set("IsMercenary", true);
		}

		
		for( local i = 0; i < number; i++ )
		{
			local party;
			
			if (this.Flags.get("IsMercenary"))
			{
				party = f.spawnEntity(nearestSettlement.getTile(), "Mercenaries", false, this.Const.World.Spawn.Mercenaries, 125 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				party.getSprite("base").setBrush("world_base_07");
				party.getSprite("body").setBrush("figure_mercenary_0" + this.Math.rand(1, 2));
			}
			else
			{
				party = f.spawnEntity(nearestSettlement.getTile(), "Noble army", false, this.Const.World.Spawn.Noble, 125 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());			
			}
		}
	}
	
	function prepareFlags()
	{
		//nobles are not interesting in raiding
	}
	
	function getAttackScreen()
	{
		if (this.Flags.get("IsMercenary"))
		{
			return "MercenaryAttack";
		}
		else
		{
			return "NobleAttack";
		}
	}
	

	function createScreens()
	{
		this.importScreens(::NorthMod.Const.Contracts.NegotiationDefault);
		this.importScreens(::NorthMod.Const.Contracts.Overview);
		this.getScreen("Task").Text = "[img]gfx/ui/events/event_20.png[/img]{A few clansmen are roaming outside the halls of the room. You can hear their shouting and it is of a nervous tone. %employer% pours a drink and sips it with a shaking hand.%SPEECH_ON%I\'ll just be clear with you, warrior. We have many, many reports that southern nobles are about to attack this camp. If you want to know, those reports came by way of dead women and children. Clearly, we\'ve no reason to doubt the seriousness of these reports. So, the question is, will you protect us?%SPEECH_OFF% | You settle into %employer%\'s room, taking a seat, rubbing your hands along the wooden frame. It\'s a good oak. A once-tree worth sitting in.%SPEECH_ON%Glad you\'re comfortable, warrior, but I sure as hell ain\'t. We have many, many warnings that a large noble army is about to attack our camp. We\'re quite short on defense, but not short on crowns. Obviously, that\'s where you come in. Are you interested?%SPEECH_OFF% | %employer% steps forth, his voice carrying the weight of desperation. %SPEECH_ON%Warriors, we are on the brink of destruction, threatened by the army the accursed nobles seeking to drive us from our lands. We cannot withstand this attack alone, but with your help, we might have a chance%SPEECH_OFF%}";
		
		
		this.m.Screens.push({
			ID = "MercenaryAttack",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_50.png[/img]{While waiting for the soldiers to come storming into the camp, you instead spot a mercenary company coming your way. Well, just because the target changes doesn\'t mean the contract does - prepare yourself! }",
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
		this.m.Screens.push({
			ID = "NobleAttack",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_78.png[/img]The noble army is in sight! Prepare for battle and protect the camp!",
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


	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			local s = this.new("scripts/entity/world/settlements/situations/terrified_villagers_situation");
			s.m.Description = "The villagers here are afraid of arriving noble army. Fewer potential recruits are to be found on the streets, and people deal less favourably with strangers."
			s.setValidForDays(4);
			this.m.SituationID = this.m.Home.addSituation(s);
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.m.Home.getSprite("selection").Visible = false;

			this.World.getGuestRoster().clear();
		}
		else
		{
			local s = this.new("scripts/entity/world/settlements/situations/raided_situation");
			
			s.setValidForDays(4);
			this.m.Home.removeSituationByID(this.m.SituationID);
		}
		
	}



});

