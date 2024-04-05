this.nem_defend_settlement_nobles_contract <- this.inherit("scripts/contracts/barbarian_contract", {
	m = {
		Reward = 0
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.nem_defend_settlement_nobles";
		this.m.Name = "Defend Settlement";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 5.0;
		this.m.MakeAllSpawnsResetOrdersOnContractEnd = false;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
		
		if (this.Math.rand(1, 100) <= 50)
		{
			this.m.DifficultyMult = this.Math.rand(90, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(115, 135) * 0.01;
		}
	}

	function onImportIntro()
	{
		this.importSettlementIntro();
	}

	function start()
	{
		this.m.Payment.Pool = 1700 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
		
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
					"Defend %townname% from noble's army"
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
				this.World.Assets.addMoney(this.Contract.m.Payment.getInAdvance());
				this.Contract.addGuests();
				local nearestSettlement = this.Contract.getNearestLocationTo(this.Contract.m.Home, this.World.EntityManager.getSettlements());
				
				local f = nearestSettlement.getOwner();
				if (this.Math.rand(1, 100) <= 30)
				{
					this.Flags.set("IsMercenary", true);
				}

				
				local r = this.Math.rand(1, 100);

				if (r <= 20)
				{
					this.Flags.set("IsMilitia", true);
				}
				
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
				
				party.setAttackableByAI(false);
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);

				local move = this.new("scripts/ai/world/orders/move_order");
				move.setDestination(this.Contract.m.Home.getTile());
				c.addOrder(move);
				local raid = this.new("scripts/ai/world/orders/nem_raid_order");
				raid.setTime(20.0);
				raid.setTargetLocation(this.Contract.m.Home);
				c.addOrder(raid);
				
				this.Contract.m.UnitsSpawned.push(party.getID())
				this.Contract.m.Home.setLastSpawnTimeToNow();
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if(this.Flags.get("IsDestroyed"))
				{
					this.logInfo("destroyed true");
					this.Contract.setScreen("FailureDestroyed");
					this.World.Contracts.showActiveContract();
					return;
				}
				
				if (this.Flags.get("IsMilitia") && !this.Flags.get("IsMilitiaDialogShown"))
				{
					this.Flags.set("IsMilitiaDialogShown", true);
					this.Contract.setScreen("Militia1");
					this.World.Contracts.showActiveContract();
				}
				
				if (this.Contract.m.UnitsSpawned.len() > 0 && this.Flags.get("IsEnemyHereDialogShown"))
				{
					foreach( id in this.Contract.m.UnitsSpawned )
					{
						local p = this.World.getEntityByID(id);
						if (p != null && p.isAlive() && !p.getController().hasOrders())
						{
						
							
							if (!p.getFlags().get("isDestroying"))
							{
								this.logInfo("defend nobles done raiding");
								p.getFlags().set("isDestroying", true);
								this.Flags.set("IsRaided", true);
								local c = p.getController();
								local destroy = this.new("scripts/ai/world/orders/wait_order");
								//destroy.setSafetyOverride(true);
								destroy.setTime(20.0);
								//destroy.setTargetLocation(this.Contract.m.Home);
								c.addOrder(destroy);
							}
							else
							{
								this.logInfo("defend nobles done destroying");
								//this.Contract.m.Home.onCombatLost();
								this.Flags.set("IsDestroyed", true);
								return;
							}
						}
					}
				}
				
				if (this.Contract.m.UnitsSpawned.len() == 0)
				{
					if (this.Flags.get("HadCombat"))
					{
						this.Contract.setScreen("ItsOver");
						this.World.Contracts.showActiveContract();
					}
					this.Contract.setState("Return");
					return;
				}
				
				if (this.Contract.m.UnitsSpawned.len() > 0 && !this.Flags.get("IsEnemyHereDialogShown"))
				{
					local isEnemyHere = false;

					foreach( id in this.Contract.m.UnitsSpawned )
					{
						local p = this.World.getEntityByID(id);

						if (p != null && p.isAlive() && p.getDistanceTo(this.Contract.m.Home) <= 700.0)
						{
							isEnemyHere = true;
							break;
						}
					}
					
					if (isEnemyHere)
					{
						this.Flags.set("IsEnemyHereDialogShown", true);
						
						if (this.Flags.get("IsMercenary"))
						{
							this.Contract.setScreen("MercenaryAttack");
						}
						else
						{
							this.Contract.setScreen("DefaultAttack");
						}
						
						this.World.Contracts.showActiveContract();
					}
					return;
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.Flags.set("HadCombat", true);
			}

			function onCombatVictory( _combatID )
			{
				this.Flags.set("HadCombat", true);
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Return to " + this.Contract.m.Home.getName()
				];
				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					if(this.Flags.get("IsRaided"))
					{
						this.Contract.setScreen("Success2");
					}
					else
					{
						this.Contract.setScreen("Success1");
					}
					
					this.World.Contracts.showActiveContract();
				}
			}

		});
	}

	function createScreens()
	{
		this.importScreens(::NorthMod.Const.Contracts.NegotiationDefault);
		this.importScreens(::NorthMod.Const.Contracts.Overview);
		this.m.Screens.push({
			ID = "Task",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_20.png[/img]{A few clansmen are roaming outside the halls of the room. You can hear their shouting and it is of a nervous tone. %employer% pours a drink and sips it with a shaking hand.%SPEECH_ON%I\'ll just be clear with you, warrior. We have many, many reports that southern nobles are about to attack this camp. If you want to know, those reports came by way of dead women and children. Clearly, we\'ve no reason to doubt the seriousness of these reports. So, the question is, will you protect us?%SPEECH_OFF% | You settle into %employer%\'s room, taking a seat, rubbing your hands along the wooden frame. It\'s a good oak. A once-tree worth sitting in.%SPEECH_ON%Glad you\'re comfortable, warrior, but I sure as hell ain\'t. We have many, many warnings that a large noble army is about to attack our camp. We\'re quite short on defense, but not short on crowns. Obviously, that\'s where you come in. Are you interested?%SPEECH_OFF% | %employer% steps forth, his voice carrying the weight of desperation. %SPEECH_ON%Warriors, we are on the brink of destruction, threatened by the army the accursed nobles seeking to drive us from our lands. We cannot withstand this attack alone, but with your help, we might have a chance%SPEECH_OF%}",
			Image = "",
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
			Text = "[img]gfx/ui/events/event_43.png[/img]{When you leave %employer%, you come outside to find a woman standing there with a mob of her spawn running around and between her legs and a babe sucking her teat.%SPEECH_ON%Warrior, please, you mustn\'t leave us like this! This camp needs you! The children need you!%SPEECH_OFF%She pauses, then lowers the other side of her shirt, revealing a rather salacious and seductive temptation.%SPEECH_ON%I need you...%SPEECH_OFF%You hold a hand up, both to stop her and wipe your suddenly sweaty brow. Maybe helping this pair, uh, poor people out wouldn\'t be so bad after all? | Getting ready to leave %townname%, a small puppy runs up to you barking and licking your boots. An even smaller child is in chase, practically on the coattails of its literal tail. The kid falls to the mutt and wraps his arms around its nappy fur.%SPEECH_ON%Oh {Marley | Yeller | Jo-Jo}, I love you so much!%SPEECH_OFF%An image of soldiers slaughtering the child and his pet runs across your mind. You\'ve better things to do than play saviour and protectos against common soldiers, but the dog just keeps licking the boy\'s face and the kid just seems so happy.%SPEECH_ON%Haha! We\'re going to live forever and ever, aren\'t we? Forever and ever!%SPEECH_OFF%Goddammit. | A man walks up to you as you leave %employer%\'s abode.%SPEECH_ON%I heard you turn chieftain\'s offer down. It\'s a shame, that\'s all I wanted to say. I thought there were plenty of good men in this world, but I suppose I was wrong on that. Godspeed on your journey, and I do hope you pray for us in your travels.%SPEECH_OFF%}",
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
					Text = "{I\'m sure you\'ll pull through. Make way. | I won\'t risk the %companyname% to save some starved villagers.}",
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
			ID = "DefaultAttack",
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
		this.m.Screens.push({
			ID = "ItsOver",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_22.png[/img]{The fighting is over and the men idle in a welcome respite. %employer% will be waiting for you back in camp. | With the battle over, you survey the corpses littered across the field. It is a gruesome sight, yet for some reason it spurs you with energy. The ghastly hills of dead only remind you of the vitality you\'ve yet to yield to this horrid world. People like %employer% should come and see it, but he won\'t, so you\'ll have to go and see him instead. | Flesh and bone scattered across the field, hardly discernible from one owner to the next. Black buzzards cycle overhead, halos of chevron shadows rippling over the dead, the birds waiting for the mourners to clear out. %randombrother% comes to your side and asks if they should start the return trip to %employer%. You leave the sight of the battlefield behind and nod. | A peaceful sort of ruin is made of the dead. Like it was their natural state, stiffened and at a permanent loss, and their whole living was but a fleeting fit of an accident finally come to an end. %randombrother% comes up and asks if you\'re alright. You\'re not sure, to be honest, and simply answer that it is time to go see %employer%. | Misshapen men and crooked corpses litter the ground for battle gives the dead no sovereignty over how one comes to a final rest. The bodiless heads look at most peace, for in battle no man or beast has time to truly hack a neck away, it only comes by the quickest and sharpest of blade swings. A part of you hopes to go with such instant finality, but another part hopes you get the chance to take your killer down with you.\n\n %randombrother% comes to your side and asks for orders. You turn away from the field and tell the %companyname% to get ready to return to %employer%.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We head back to the %townname%",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		
		this.m.Screens.push({
			ID = "Militia1",
			Title = "At %townname%",
			Text = "[img]gfx/ui/events/event_80.png[/img]{While preparing to defend %townname%, the local clansmen have come to your side. They submit to your orders, only asking that you allow them to defend their home with your men. | It appears the local clansmen have joined the battle! A ragtag group of men, but they\'ll be useful nonetheless. | %townname%\'s clansmen have joined the fight! Although a shoddy band of poorly armed men, they are eager to defend home and hovel. They submit to your command, trusting that you will lead them to victory in battle. | You\'re not alone in this fight! %townname%\'s clansmen have joined you. They\'re eager to fight and ask to stand by your warriors in battle.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Fall in line, you\'ll be under my command.",
					function getResult()
					{
						local roster = this.World.getGuestRoster();
						
						for( local i = 0; i != 4; i = ++i )
						{
							local militia = roster.create("scripts/entity/tactical/humans/barbarian_thrall_guest");
							militia.setFaction(1);
							militia.assignRandomEquipment();
						}
						this.Contract.positionGuests();
						return 0;
					}

				},
				{
					Text = "Go hide somewhere and stay out of our way.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "MilitiaVolunteer",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_80.png[/img]{The fighting over, one of the clansmen that helped in the defense comes to you personally, bending low and offering his sword.%SPEECH_ON%My time here is at an end. But the prowess of the %companyname% is truly an amazing sight. If you would permit it, chief, I would love to fight alongside you and your warriors.%SPEECH_OFF% }",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Welcome to the %companyname%!",
					function getResult()
					{
						return 0;
					}

				},
				{
					Text = "This is no place for you.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		
		
		this.m.Screens.push({
			ID = "Success1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_04.png[/img]{You return to %employer% looking rightfully smug.%SPEECH_ON%Work\'s done.%SPEECH_OFF%He nods, tipping a goblet of wine while not necessarily offering it.%SPEECH_ON%Yes. We are eternally grateful for your help, as well as... monetarily grateful.%SPEECH_OFF%The man gestures toward the corner of the room. You see a satchel of crowns there.%SPEECH_ON%%reward% crowns, just as we had agreed. Thanks again, warrior.%SPEECH_OFF% | %employer% welcomes your return with a goblet of wine.%SPEECH_ON%Drink up, warrior, you\'ve earned it.%SPEECH_OFF%It tastes... particular. Haughty, if that could be a flavor. Your employer swings around his desk, taking a gleefully happy seat.%SPEECH_ON%You managed to protect us just as you had promised! I am most impressed.%SPEECH_OFF%He nods, tipping his goblet toward a wooden chest.%SPEECH_ON%MOST impressed.%SPEECH_OFF%You open the chest to find a bevy of golden crowns. | %employer% welcomes you into his room.%SPEECH_ON%I watched from my window, you know? Saw it all. Well, most of it. The good parts, I suppose.%SPEECH_OFF%You raise an eyebrow.%SPEECH_ON%Oh, don\'t give me that look. I don\'t feel bad for enjoying what I saw. We\'re alive, right? Us, the good guys.%SPEECH_OFF%The other eyebrow goes up.%SPEECH_ON%Well... anyway, your payment, as promised.%SPEECH_OFF%The man hands over a chest of %reward% crowns. | When you return to %employer% you find his room has almost been packed up, everything ready to move and go. You raise a bit of humorous concern.%SPEECH_ON%Getting ready to go somewhere?%SPEECH_OFF%The man\'s settled down into his chair.%SPEECH_ON%I had my doubts, warrior. Can you blame me? For what it\'s worth, you shouldn\'t need doubt my ability to pay.%SPEECH_OFF%He sways a hand across his desk. On the corner is a satchel, lumpy and bulbous with coins.%SPEECH_ON%%reward% crowns, as promised.%SPEECH_OFF% | %employer% raises from his chair when you enter. He bows, somewhat incredulously, but also earnestly. He tips his head toward the window where the din of happy clanfolk murmurs.%SPEECH_ON%You hear that? You\'ve earned that, warrior. The people here love you now.%SPEECH_OFF%You nod, but the love of the common man is not what brought you here.%SPEECH_ON%What else have I earned?%SPEECH_OFF%%employer% smiles.%SPEECH_ON%A man on point. I bet that\'s what gives you your... edge. Of course, you\'ve also earned this.%SPEECH_OFF%He heaves a wooden chest onto his desk and unlatches it. The shine of gold crowns warms your heart. | %employer%\'s staring out his window when you enter. He\'s almost in a dreamstate, head bent low to his hand. You interrupt his thoughts.%SPEECH_ON%Thinking of me?%SPEECH_OFF%The man chuckles and playfully clutches his chest.%SPEECH_ON%You are truly the man of my dreams, warrior.%SPEECH_OFF%He crosses the room and takes a chest from the bookshelf. He unlatches it as he sets it on the table. A glorious pile of gold crowns stare you in the face. %employer% grins.%SPEECH_ON%Now who is dreaming?%SPEECH_OFF% | %employer%\'s at his desk when you enter.%SPEECH_ON%I saw a good deal of it. The killing, the dying.%SPEECH_OFF%You take a seat.%SPEECH_ON%Hope you enjoyed the show. Viewing\'s ain\'t free, though.%SPEECH_OFF%The man nods, taking a satchel and handing it over.%SPEECH_ON%I\'d pay for an encore, but I\'m not sure %townname% wants that.%SPEECH_OFF%}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Defended the camp against brigands");
						this.World.Contracts.finishActiveContract();

						if (this.Flags.get("IsUndead") && this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCommonContract);
						}

						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_30.png[/img]{%employer% welcomes your return with a point out his window.%SPEECH_ON%You see that? There, in the distance.%SPEECH_OFF%You join his side. He asks.%SPEECH_ON%What is it that you see?%SPEECH_OFF%There\'s smoke on the horizon. You let him know that\'s what you see.%SPEECH_ON%Right, smoke. I didn\'t hire you to let the soldiers make smoke, understand? Of course... most of the town is still upright...%SPEECH_OFF%He heaves a satchel into your chest.%SPEECH_ON%Good work, warrior. Just... not good enough.%SPEECH_OFF% | You return to %employer%, he looks a mix of happy and sad, somewhere between drunk and straight. This is not the look you want to see.%SPEECH_ON%You did good, warrior. Word has it you laid those soldiers utterly flat. Word also has it that they burned parts of our outskirts.%SPEECH_OFF%You nod. Not worth lying about what you can\'t cover up.%SPEECH_ON%You\'ll be getting paid, but you have to understand that it takes money to rebuild those areas. Obviously, the crowns for that will be coming out of your pockets...%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{That\'s just half of what we agreed to! | It is what it is...}",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion() / 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractPoor, "Defended the town against an enemy army");
						this.World.Contracts.finishActiveContract();

						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion() / 2;
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] Crowns"
				});
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/raided_situation"), 3, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "FailureDestroyed",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_30.png[/img]Smoke fills the air, smoke and the caustic smell of burning wood, burning livelihoods. %townname% is completely destroyed and wiped from the world. Their folk may have put all their hopes into hiring the %companyname%, but it was a fatal mistake.",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "{Damnit!}",
					function getResult()
					{
						this.Contract.m.Home.onCombatLost();
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to defend the camp against soldiers");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"reward",
			this.m.Reward
		]);
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

	function onIsValid()
	{


		return true;
	}

	function onSerialize( _out )
	{
		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.contract.onDeserialize(_in);
	}

});

