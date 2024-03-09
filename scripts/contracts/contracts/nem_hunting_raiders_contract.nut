this.nem_hunting_raiders_contract <- this.inherit("scripts/contracts/contract", {
	m = {
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.nem_hunting_raiders";
		this.m.Name = "Hunt down raiders";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 5.0;
		this.m.MakeAllSpawnsResetOrdersOnContractEnd = false;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
	}
	
	function setEnemyFaction(_faction)
	{
		this.getFlags().set("enemy", _faction);
	}
	
	function getEnemyFaction()
	{
		this.getFlags().getAsInt("enemy");
	}

	function start()
	{
		this.m.Payment.Pool = 500 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		this.m.Payment.Completion = 1.0;

		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Kill parties terrorizing %townname%"
				];

				if (this.Math.rand(1, 100) <= this.Const.Contracts.Settings.IntroChance)
				{
					this.Contract.setScreen("Intro");
				}
				else
				{
					this.Contract.setScreen("Task");
				}
			}

			function end()
			{
			
				local enemyFactionID = this.getEnemyFaction();
				local enemyFaction = this.World.FactionManager.getFaction(enemyFaction);
				this.World.Assets.addMoney(this.Contract.m.Payment.getInAdvance());
				local nearestBandits = this.Contract.getNearestLocationTo(this.Contract.m.Home, enemyFaction.getSettlements());
				
				local originTile = this.Contract.m.Home.getTile();
				local tile = this.Contract.getTileToSpawnLocation(originTile, 5, 10);

				local party;
				local difficulty = 110 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult();
				if (enemyFaction.getType() == this.Const.FactionType.Barbarians)
				{
					party = enemyFaction.spawnEntity(tile, "Barbarian raiders", false, this.Const.World.Spawn.Barbarians, difficulty)
				}
				else if (enemyFaction.getType() == this.Const.FactionType.NobleHouse)
				{
					local r = this.Math.rand(1, 100);
					if(r <= 50)
					{
						this.Flags.set("IsMercs", true);
						party = enemyFaction.spawnEntity(tile, "Mercenaries", false, this.Const.World.Spawn.Mercenaries, difficulty)
					}
					else {
						party = enemyFaction.spawnEntity(tile, "Mercenaries", false, this.Const.World.Spawn.Noble, difficulty)
					}
				}
				else if (enemyFaction.getType() == this.Const.FactionType.Bandits)
				{
					party = enemyFaction.spawnEntity(tile, "Raiders", false, this.Const.World.Spawn.BanditRaiders, difficulty)
				}
				else if (enemyFaction.getType() == this.Const.FactionType.Zombies)
				{
					party = enemyFaction.spawnEntity(tile, "Undead", false, this.Const.World.Spawn.Necromancer, difficulty)
				}
				else if (enemyFaction.getType() == this.Const.FactionType.Orcs)
				{
					party = enemyFaction.spawnEntity(tile, "Orc Marauders", false, this.Const.World.Spawn.OrcRaiders, difficulty)
				}
				else if (enemyFaction.getType() == this.Const.FactionType.Goblins)
				{
					party = enemyFaction.spawnEntity(tile, "Goblin Raiders", false, this.Const.World.Spawn.GoblinRaiders, difficulty)
				}
				
				
				this.Contract.m.UnitsSpawned.push(party.getID());
				this.Contract.m.Target = this.WeakTableRef(party);
				party.setAttackableByAI(false);
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local roam = this.new("scripts/ai/world/orders/roam_order");
				roam.setPivot(this.Contract.m.Home);
				roam.setMinRange(3);
				roam.setMaxRange(8);
				roam.setAllTerrainAvailable();
				roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
				roam.setTerrain(this.Const.World.TerrainType.Shore, false);
				roam.setTerrain(this.Const.World.TerrainType.Mountains, false);
				c.addOrder(roam);
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
				
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Target != null && !this.Contract.m.Target.isNull())
				{
					this.Contract.m.Target.getSprite("selection").Visible = true;
					this.Contract.m.Target.setOnCombatWithPlayerCallback(this.onTargetAttacked.bindenv(this));
				}

				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.m.Target == null || this.Contract.m.Target.isNull() || !this.Contract.m.Target.isAlive())
				{
					this.Contract.setScreen("BattleWon");
					this.World.Contracts.showActiveContract();
					this.Contract.setState("Return");
				}
			
			}
			
			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				this.World.Contracts.showCombatDialog(_isPlayerAttacking);
			}

		});
		
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Return to " + this.Contract.m.Home.getName()
				];
				this.Contract.m.BulletpointsPayment = [];

				if (this.Contract.m.Payment.Advance != 0)
				{
					this.Contract.m.BulletpointsPayment.push("Get " + this.Contract.m.Payment.getInAdvance() + " crowns in advance");
				}

				if (this.Contract.m.Payment.Completion != 0)
				{
					this.Contract.m.BulletpointsPayment.push("Get " + this.Contract.m.Payment.getOnCompletion() + " crowns on completion");
				}

				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					this.Contract.setScreen("Success1");
					this.World.Contracts.showActiveContract();
				}
			}

		});
	}

	function createScreens()
	{
		this.importScreens(this.Const.Contracts.NegotiationDefault);
		this.importScreens(this.Const.Contracts.Overview);
		
		this.m.Screens.push({
			ID = "Task",
			Title = "Negotiations",
			Text = text,
			Image = "[img]gfx/ui/events/event_60.png[/img]{%employer% meets for you in his jurt. His slouched posture and occasional groan tell you all about how his day is going. %SPEECH_ON%Welcome, warrior, you do not come at the good times for my clan, but I hope you can help us. There is a group, %raiders%, that's been troubling us lately. They've been attacking our scouting and war parties, raiding and pillaging, during the night. I'm assembling all the men I can get to drive them away, but that will take some time.%SPEECH_OFF%He pauses, as if hoping for you to say something. When you keep quiet, he simply lets a deep sigh and continues.%SPEECH_ON%Well, you and your men are here, if you can drive them off, I will find some reward for you. What do you say, warrior?%SPEECH_OFF%}",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{What is %townname% prepared to pay for their safety? | This should be worth a good amount of crowns to you, right?}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{I\'m afraid you\'re on your own. | We have more important matters to settle. | I wish you luck, but we\'ll not be part of this.}",
					function getResult()
					{
						if (this.Math.rand(1, 100) <= 60)
						{
							this.World.Contracts.removeContract(this.Contract);
							return 0;
						}
						else
						{
							return "Plea";
						}
					}

				}
			],
			function start()
			{
								
			}

		});
		this.m.Screens.push({
			ID = "Plea",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_43.png[/img]{As you\'re leaving %employer_short% with a rejection, you come outside to find a throng of clansmen standing around. Each is holding some sort of oddity, the sort of wealth that the laymen could scrounge together as best they could: chickens, cheap necklaces, worn clothes, rusted blacksmith gear, the list of belongings go on and on. One steps forward, a chicken tucked under each arm.%SPEECH_ON%Please! You can\'t leave! You have to help us!%SPEECH_OFF%%randombrother% laughs, but you have to admit that the poor folk do know how to pull a heartstring or two. Maybe you should stay and help after all? | When you leave %employer_short%, you come outside to find a woman standing there with a mob of her spawn running around and between her legs and a babe sucking her teat.%SPEECH_ON%Warrior, please, you mustn\'t leave us like this! This village needs you! The children need you!%SPEECH_OFF%She pauses, then lowers the other side of her shirt, revealing a rather salacious and seductive temptation.%SPEECH_ON%I need you...%SPEECH_OFF%You hold a hand up, both to stop her and wipe your suddenly sweaty brow. Maybe helping this pair, uh, poor people out wouldn\'t be so bad after all? | Getting ready to leave %townname%, a small puppy runs up to you barking and licking your boots. An even smaller child is in chase, practically on the coattails of its literal tail. The kid falls to the mutt and wraps his arms around its nappy fur.%SPEECH_ON%Oh {Marley | Yeller | Jo-Jo}, I love you so much!%SPEECH_OFF%An image of raiders slaughtering the child and his pet runs across your mind. You\'ve better things to do than play bounty hunter against raiders, but the dog just keeps licking the boy\'s face and the kid just seems so happy.%SPEECH_ON%Haha! We\'re going to live forever and ever, aren\'t we? Forever and ever!%SPEECH_OFF%Goddammit. | A man walks up to you as you leave %employer_short%\'s abode.%SPEECH_ON%Warrior, I heard you turn that man\'s offer down. It\'s a shame, that\'s all I wanted to say. I thought there were plenty of good men in this world, but I suppose I was wrong on that. Godspeed on your journey, and I do hope you pray for us in your travels.%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = false,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{Damn, we can\'t leave these people to die. | Fine, fine, we won\'t leave %townname%. Let\'s talk payment, at least.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{I\'m sure you\'ll pull through. Make way. | I won\'t risk the %companyname% to save some starved peasants.}",
					function getResult()
					{
						this.World.Contracts.removeContract(this.Contract);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_04.png[/img]{You return to %employer% looking rightfully smug.%SPEECH_ON%Work\'s done.%SPEECH_OFF%He nods and offers you a horn of mead.%SPEECH_ON%Yes. The %townname% is eternally grateful for your help. As promised we also have some reward for you.%SPEECH_OFF%The man gestures toward the corner of the room. You see a satchel of crowns there.%SPEECH_ON%%reward_completion% crowns, just as we had agreed. Thanks again, warrior.%SPEECH_OFF% | %employer% welcomes your return with a horn of mead.%SPEECH_ON%Drink up, warrior, you\'ve earned it.%SPEECH_OFF%It tastes... particular. Haughty, if that could be a flavor. Your employer swings around his desk, taking a gleefully happy seat.%SPEECH_ON%You managed to protect the town just as you had promised! I am most impressed.%SPEECH_OFF%He nods, tipping his horn toward a wooden chest.%SPEECH_ON%MOST impressed.%SPEECH_OFF%You open the chest to find a bevy of golden crowns. | %employer% welcomes you into his room.%SPEECH_ON%I watched from the nearby hill, you know? Saw it all. Well, most of it. The good parts, I suppose.%SPEECH_OFF%You raise an eyebrow.%SPEECH_ON%Oh, don\'t give me that look. I don\'t feel bad for enjoying what I saw. We\'re alive, right? Us, the good guys.%SPEECH_OFF%The other eyebrow goes up.%SPEECH_ON%Well... anyway, your payment, as promised.%SPEECH_OFF%The man hands over a chest of %reward_completion% crowns.}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{The %companyname% will make good use of this. | Payment for a hard day\'s work.}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Defended the town against brigands");
						this.World.Contracts.finishActiveContract();

						if (this.Flags.get("IsUndead") && this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCommonContract);
						}
						
						this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);

						return 0;
					}

				}
			],
			function start()
			{
				local reward = this.Contract.m.Payment.getOnCompletion();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + reward + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "BattleWon",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_86.png[/img]{As your men fell the last of the orcs, you take a look around. The greenskins put up a hell of a fight. Time to check on the company and prepare a return to your employer, %employer%. | %employer%\'s men could never do what you just did. Only the %companyname% could deal with these greenskins. You\'re proud of the company, but try not to show it. | The battle is settled, as is a wager or two the men had. As it turns out, an orc will stop gnashing if you remove its head from its neck! Your employer, %employer%, probably doesn\'t care about such brutish experiments, but he will pay you for the work you\'ve done today. | The orcs put up a fight that the holy men might have even dared to call righteous. But they are no better than the %companyname%, not on this day! | Your employer, %employer%, wanted you to slay the greenskins and you\'ve done exactly that. Now it\'s time to check on the men and prepare a return to get your hard-earned pay. | Battles with the orcs is never an easy task and this one was no different. %employer%\'s pay, though, will make the %companyname%\'s hardships a little bit easier to swallow. | Your employer, %employer%, better pay damn well for you to fight these brutes - they didn\'t go down easy! Check on your men and prepare a return to your employer.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Back to %townname%!",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
	}

	function onPrepareVariables( _vars )
	{		
		_vars.push([
			"employer_short",
			this.m.EmployerID != 0 ? this.Tactical.getEntityByID(this.m.EmployerID).getNameOnly() : ""
		]);
		
		local raiders = "raiders";
		local enemyFactionID = this.getEnemyFaction();
		if (enemyFactionID == null)
		{
			_vars.push([
				"raiders",
				"raiders"
			]);
			return;
		}
		local enemyFaction = this.World.FactionManager.getFaction();
		if (enemyFaction.getType() == this.Const.FactionType.Barbarians)
		{
			raiders = "raiders from one of the northern clans";
		}
		else if (enemyFaction.getType() == this.Const.FactionType.NobleHouse && this.Flags.get("IsMercs"))
		{
			raiders = "mercenaries hired by " + enemyFaction.getName();
		}
		else if (enemyFaction.getType() == this.Const.FactionType.NobleHouse)
		{
			this.Text += "soldier from " + enemyFaction.getName();
		}
		else if (enemyFaction.getType() == this.Const.FactionType.Bandits)
		{
			this.Text += "raiders and vagabonds";
		}
		else if (enemyFaction.getType() == this.Const.FactionType.Zombies)
		{
			this.Text += "dead men led by a dark wizard";
		}
		else if (enemyFaction.getType() == this.Const.FactionType.Orcs)
		{
			this.Text += "orc raiders";
		}
		else if (enemyFaction.getType() == this.Const.FactionType.Goblins)
		{
			this.Text += "goblin raiders";
		}
		
		_vars.push([
			"raiders",
			raiders
		]);
	}

	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			local s = this.new("scripts/entity/world/settlements/situations/raided_situation");
			s.setValidForDays(4);
			this.m.SituationID = this.m.Home.addSituation(s);
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.World.FactionManager.getFaction(this.getFaction()).setActive(true);
			this.m.Home.getSprite("selection").Visible = false;

			if (this.m.Kidnapper != null && !this.m.Kidnapper.isNull())
			{
				this.m.Kidnapper.getSprite("selection").Visible = false;
			}

			this.World.getGuestRoster().clear();
		}
	}

	function onIsValid()
	{
		return true;
	}

	function onSerialize( _out )
	{
		this.m.Flags.set("KidnapperID", this.m.Kidnapper != null && !this.m.Kidnapper.isNull() ? this.m.Kidnapper.getID() : 0);
		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.contract.onDeserialize(_in);
		this.m.Kidnapper = this.WeakTableRef(this.World.getEntityByID(this.m.Flags.get("KidnapperID")));
	}

});

