this.nem_raid_caravan_contract <- this.inherit("scripts/contracts/barbarian_contract", {
	m = {
		Target = null,
		LastCombatTime = 0.0
	},
	
	function setCaravanInfo( _enemyFaction, _startId, _destId )
	{
		this.m.Flags.set("TargetFaction", _enemyFaction);
		this.m.Flags.set("InterceptStart", _startId);
		this.m.Flags.set("InterceptDest", _destId);
	}
	
	function chooseCaravanRoute()
	{
		
		local allSettlements = this.World.EntityManager.getSettlements();
		
		local routes = [];
		local playerTile = this.m.Home.getTile();
		local startSettlements = [];
		local allSettlements = this.World.EntityManager.getSettlements();
		
		local southY = this.World.getMapSize().Y * 0.7;
		//this.logInfo("south: " + southY);
		foreach(i, startCandidate in allSettlements)
		{
			
			//this.logInfo("start:" + startCandidate.getName() + " / " + startCandidate.getTile().SquareCoords.Y);
			if ((startCandidate.isSouthern() || startCandidate.isMilitary()) && this.getDifficultySkulls() == 1)
			{
				continue;
			}
			if(!startCandidate.isMilitary() && !startCandidate.isSouthern() && this.getDifficultySkulls() == 3)
			{
				continue;
			}
					
			foreach(j, endCandidate in allSettlements)
			{
				//this.logInfo("end:" + endCandidate.getName() + " / " + endCandidate.getTile().SquareCoords.Y);				
				if(startCandidate == endCandidate)
				{
					continue;
				}
				
				if (startCandidate.getTile().SquareCoords.Y < southY && endCandidate.getTile().SquareCoords.Y < southY)
				{
					//this.logInfo("both south");
					continue;
				}
				local distanceCaravan = this.getDistanceOnRoads(startCandidate.getTile(), endCandidate.getTile());
				local daysCaravan = this.getDaysRequiredToTravel(distanceCaravan, this.Const.World.MovementSettings.Speed * 0.6, true);
				
				local distancePlayer = endCandidate.getTile().getDistanceTo(playerTile);
				local daysPlayer = this.getDaysRequiredToTravel(distancePlayer, this.Const.World.MovementSettings.Speed * 1.0, false);
				
				
				
				//this.logInfo("daysCaravan: " + daysCaravan);
				//this.logInfo("daysPlayer: " + daysPlayer);
				
				if (daysPlayer > 1.5 * daysCaravan)
				{
					continue;
				}
				
				local route = {
					startIdx = i,
					endIdx	= j
				};

				routes.push(route);
				
				
			}
		}
		this.logInfo("caravan routes: " + routes.len());
		if(routes.len() == 0)
		{
			return;
		}
		
		local r = this.Math.rand(0, routes.len()-1);
		local startIdx = routes[r].startIdx;
		local endIdx = routes[r].endIdx;
		local start = allSettlements[startIdx];
		local end = allSettlements[endIdx];
		
		local enemyFaction = null;
		if (start.isMilitary())
		{
			enemyFaction = start.getOwner();
		}
		else if(start.isSouthern())
		{
			enemyFaction = start.getOwner();
		}
		else {
			enemyFaction = start.getFactionOfType(this.Const.FactionType.Settlement);
			if (enemyFaction == null)
			{
				return;
			}
		}
		
		this.setCaravanInfo(enemyFaction.getID(), start.getID(), end.getID());
	}
	
	function onHomeSet()
	{
		this.chooseCaravanRoute();
	}

	function create()
	{
		this.contract.create();
		this.m.Type = "contract.nem_raid_caravan";
		this.m.Name = "Raid Caravan";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
				
	}
	
	function start()
	{
		this.logInfo("caravan contract starting");
		this.m.Payment.Pool = 500 * this.getPaymentMult() * this.getDifficultyMult() * this.getReputationToPaymentMult();
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
					"Raid the caravan going from %start% to %dest%",
					"Return to %townname%"
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
				local r = this.Math.rand(1, 100);
				//this.Flags.set("Survivors", 0);

				if (r <= 10)
				{
					this.Flags.set("IsBribe", true);
					this.Flags.set("Bribe1", this.Contract.beautifyNumber(this.Contract.m.Payment.Pool * (this.Math.rand(70, 150) * 0.01)));
				}
				else if (r <= 15)
				{
					if (this.Contract.getDifficultyMult() >= 1.0)
					{
						this.Flags.set("IsSwordmaster", true);
					}
				}
				else if (r <= 20)
				{
					if (this.Contract.getDifficultyMult() >= 1.0)
					{
						this.Flags.set("IsUndeadSurprise", true);
					}
				}
				else if (r <= 25)
				{
					this.Flags.set("IsWomenAndChildren", true);
				}

				local enemyFaction = this.World.FactionManager.getFaction(this.Flags.get("TargetFaction"));
				local best_start = this.World.getEntityByID(this.Flags.get("InterceptStart"));
				local best_dest = this.World.getEntityByID(this.Flags.get("InterceptDest"));
				local template;
				local forceMultiplier = 1;
				local description = "";
				if (enemyFaction.getType() == this.Const.FactionType.NobleHouse)
				{
					description = "A caravan with armed escorts transporting provisions, supplies and equipment between settlements.";
					template = this.Const.World.Spawn.NobleCaravan;
				}
				else if(enemyFaction.getType() == this.Const.FactionType.OrientalCityState)
				{
					description = "A trading caravan from " + best_start.getName() + " that is transporting all manner of goods between settlements.";
					forceMultiplier = 0.9;
					template = this.Const.World.Spawn.CaravanSouthern;
				}
				else
				{
					description = "A trading caravan from " + best_start.getName() + " that is transporting all manner of goods between settlements.";
					forceMultiplier = 1.2;
					template = this.Const.World.Spawn.Caravan;
				}
				
				local party = enemyFaction.spawnEntity(best_start.getTile(), "Caravan", false, template, 100 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult() * forceMultiplier);
				if (best_start.getProduce().len() != 0)
				{
					for( local j = 0; j != 3; j = ++j )
					{
						party.addToInventory(best_start.getProduce()[this.Math.rand(0, best_start.getProduce().len() - 1)]);
					}
				}
				
				party.getSprite("base").Visible = false;
				if (enemyFaction.getBannerSmall() != "") {
					party.getSprite("banner").setBrush(enemyFaction.getBannerSmall());
				}
				
				party.setMirrored(true);
				party.setVisibleInFogOfWar(true);
				party.setImportant(true);
				party.setDiscovered(true);
				party.setDescription(description);
				party.setFootprintType(this.Const.World.FootprintsType.Caravan);
				party.getFlags().set("IsCaravan", true);
				party.setAttackableByAI(false);
				party.getFlags().add("ContractCaravan");
				this.Contract.m.Target = this.WeakTableRef(party);
				this.Contract.m.UnitsSpawned.push(party);
				party.getLoot().Money = this.Math.rand(50, 100);
				party.getLoot().ArmorParts = this.Math.rand(0, 10);
				party.getLoot().Medicine = this.Math.rand(0, 2);
				party.getLoot().Ammo = this.Math.rand(0, 20);
				local r = this.Math.rand(1, 6);

				if (r == 1)
				{
					party.addToInventory("supplies/bread_item");
				}
				else if (r == 2)
				{
					party.addToInventory("supplies/roots_and_berries_item");
				}
				else if (r == 3)
				{
					party.addToInventory("supplies/dried_fruits_item");
				}
				else if (r == 4)
				{
					party.addToInventory("supplies/ground_grains_item");
				}
				else if (r == 5)
				{
					party.addToInventory("supplies/pickled_mushrooms_item");
				}

				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local move = this.new("scripts/ai/world/orders/move_order");
				move.setDestination(best_dest.getTile());
				move.setRoadsOnly(true);
				local despawn = this.new("scripts/ai/world/orders/despawn_order");
				c.addOrder(move);
				c.addOrder(despawn);
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
					this.Contract.m.Target.setVisibleInFogOfWar(true);
				}
			}

			function update()
			{
				
				if (this.Contract.m.Target == null || this.Contract.m.Target.isNull())
				{
					if (this.Flags.get("IsWomenAndChildren"))
					{
						this.Contract.setScreen("WomenAndChildren1");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setState("Return");
					}
				}
				else if (this.Contract.isEntityAt(this.Contract.m.Target, this.World.getEntityByID(this.Flags.get("InterceptDest"))))
				{
					this.Contract.setScreen("CaravanDelivered");
					this.World.Contracts.showActiveContract();
				}
			}

			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				if (!this.Flags.get("IsAttackDialogTriggered"))
				{
					this.Flags.set("IsAttackDialogTriggered", true);

					if (this.Flags.get("IsBribe"))
					{
						this.Contract.setScreen("Bribe1");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsSwordmaster"))
					{
						this.Contract.setScreen("Swordmaster");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Flags.get("IsUndeadSurprise"))
					{
						this.Contract.setScreen("UndeadSurprise");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.onTargetAttacked(_dest, true);
					}
				}
				else
				{
					local enemyFaction = this.World.FactionManager.getFaction(this.Flags.get("TargetFaction"));
					enemyFaction.setIsTemporaryEnemy(true);
					this.Contract.m.LastCombatTime = this.Time.getVirtualTimeF();
					this.World.Contracts.showCombatDialog(_isPlayerAttacking);
				}
			}

			function onActorRetreated( _actor, _combatID )
			{
				if (!_actor.isNonCombatant() && _actor.getFaction() == this.Flags.get("TargetFaction") && this.Flags.get("IsAttackDialogTriggered"))
				{
					this.Flags.set("Survivors", this.Flags.get("Survivors") + 1);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.Contract.m.LastCombatTime = this.Time.getVirtualTimeF();
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Return to %townname%"
				];
				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					if (this.Flags.get("Failed")) {
						this.Contract.setScreen("Failure1");
						this.World.Contracts.showActiveContract();
					} else {
						this.Contract.setScreen("Success1");
						this.World.Contracts.showActiveContract();
					}
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{You take a seat as %employer% folds out a map before you. He drags a finger along one of the poorly drawn roads.%SPEECH_ON%A caravan travels this route, it's rich with supplies and gold.%SPEECH_OFF%He holds up the finger.%SPEECH_ON%I need it raided and the cargo brought back.%SPEECH_OFF%",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{What\'s this worth to you? | Let\'s talk pay.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{This doesn\'t sound like our kind of work. | I don\'t think so.}",
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
			ID = "Bribe1",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_41.png[/img]{While closing in on the caravan, one of the guards spots you and everyone draws their weapons. A man, shouting and running with his hands in the air, asks everyone to put their weapons down. He has a satchel in hand, heavy with %bribe% crowns, and says you can take it if you simply let them go. You wonder aloud why you would take the bribe when you could kill them all and take it anyway. The man shrugs.%SPEECH_ON%Well, it\'d certainly save you the trouble of \'killing\' us, seeing as how we\'re not gonna go down without a fight. Just take it and walk.%SPEECH_OFF% | As your men approach the caravan, one of the guards spots you and blows a horn, alarming the rest to your presence. Soon, an entire armed guard stands before you, ready to fight. The head of the wagon train comes through their line, holding his hands up.%SPEECH_ON%Stay your weapons, men! Barbarian, I\'d like to make you an offer. You take this satchel of %bribe% crowns and walk and nobody has to die here.%SPEECH_OFF%You open your mouth to respond, but the man holds a finger up and keeps talking.%SPEECH_ON%Whoa, think carefully there. You no longer have the drop on us and I hired these men to protect these wagons for good reason - they\'re killers, just like you.%SPEECH_OFF% | With your men on the approach, the destruction of the caravan seems to be at hand. Unfortunately, you watch as one of the mercenaries missteps, sliding his foot on a rolling tree limb that sends him skittering and rolling down a small hillside. The disturbance is loud enough to alert the entire wagon train to your presence and you watch as armed guards stream out to meet you. Their lieutenant runs in between the two war bands, his arms in the air.%SPEECH_ON%Wait. Just wait. Before we commence the killin\' and slaughterin\', let\'s exchange a few words, shall we? I have here %bribe% crowns.%SPEECH_OFF%The man holds up a satchel and waves it toward you.%SPEECH_ON%You take this, walk, and we can all go on our ways. No need for men to be impasses upon one another, right? I\'d say it\'s a mighty fine deal, seeing as how you ain\'t got your sneaking ways on your side anymore - it\'s gonna be man against man. So what say you?%SPEECH_OFF% | Just as you think your men are about to begin the assault on the caravan, a guard watching the wagons spots them. He hurries to an alarm bell, sounding it loudly just as %randombrother% caves his skull in. Unfortunately, a great number of the guard\'s compatriots fly out, weapons raised. Their leader is beside them, holding the order back for them to charge.%SPEECH_ON%Ho\', men! Not yet. Let us, perhaps, discuss a less... violent end to this here junction.%SPEECH_OFF%He glances at the stoved in head of the guard.%SPEECH_ON%Well, for the rest of us, anyway. I have here in my hand %bribe% crowns. It\'s yours, ambusher, assassin, whatever you call yourself, if you simply take it and walk. And I\'d suggest you do just that - you no longer have the drop on us and I paid good money for these men to watch my goods, understand?%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{So be it. Hand over the crowns. | A fair offer, we\'ll take it.}",
					function getResult()
					{
						//this.Flags.set("Failed", true)
						//this.Contract.setState("Return");
						
						this.World.Assets.addMoney(this.Flags.get("Bribe1"));
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail * 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail);
						this.World.Contracts.removeContract(this.Contract);
						
						
						return 0;
					}

				},
				{
					Text = "Nothing personal, but this caravan is going to burn. And you with it.",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});

		this.m.Screens.push({
			ID = "Swordmaster",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_35.png[/img]{While preparing to assault the caravan, %randombrother% comes to your side and points to one of the men in the wagontrain.%SPEECH_ON%Know who that is?%SPEECH_OFF%You shake your head.%SPEECH_ON%That\'s %swordmaster%.%SPEECH_OFF%Slimming your eyes to get a clearer picture, all you see is an ordinary looking man. Your man explains that he\'s a renowned swordmaster who has killed untold numbers of men. He thumbs his nose and spits.%SPEECH_ON%Still want to attack?%SPEECH_OFF% | You glass the caravan with some spectacles. This fellow is a dangerous one and should be approached carefully. | Scouting the wagontrain, you see a face that gives you\'ve seen before. %randombrother% joins you, picking his fingernails with a knife.%SPEECH_ON%That\'s %swordmaster%, the swordmaster. He\'s killed twenty men this year.%SPEECH_OFF%A voice barks from behind you.%SPEECH_ON%I heard fifty! Sixty maybe. Forty-five if we\'re being realistic...%SPEECH_OFF%Hmm, it appears there is a most dangerous opponent in that caravan\'s guard...}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To Arms!",
					function getResult()
					{
						this.Const.World.Common.addTroop(this.Contract.m.Target, {
							Type = this.Const.World.Spawn.Troops.Swordmaster
						}, true, this.Contract.getDifficultyMult() >= 1.1 ? 5 : 0);
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "UndeadSurprise",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_29.png[/img]{Ordering the assault, your men launch across the grass. The caravan guards are already running your way, but they look scared. Behind them follow a throng of garish looking creatures. It\'s safe to say this is going to be the strangest of meetings... | As the %companyname% sprints toward the caravan, weapons drawn, a few men slow down to point out that there\'s an even larger party approaching the wagon train from the other side. Pausing to get a good eye at it, you realize that there is a horde of undead converging on this very spot! | Well, it looks like this won\'t be as easy as you\'d thought: as your men begin the attack on the caravan, %randombrother% spots a horde of ghastly undead approaching from the other side! Undead or soon-to-be-dead, it doesn\'t matter. You\'re here to do what %employer% paid you to do.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To Arms!",
					function getResult()
					{
						local enemyFaction = this.World.FactionManager.getFaction(this.Flags.get("TargetFaction"));
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
						p.CombatID = "UndeadSurprise";
						p.Music = this.Const.Music.UndeadTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.TemporaryEnemies = [
							this.Flags.get("TargetFaction")
						];
						p.AllyBanners = [
							this.World.Assets.getBanner()
						];
						p.EnemyBanners = [
							enemyFaction.getBannerSmall(),
							this.Const.ZombieBanners[0]
						];
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Necromancer, 100 * this.Contract.getScaledDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WomenAndChildren1",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_97.png[/img]{As your men clean the field of any wounded, %randombrother% comes to you with a line of women and children being toted behind him. You raise your sword and ask what is this.%SPEECH_ON%Looks like they brought their families with them. What do you want us to do?%SPEECH_OFF% | Having won the battle, your men spread out to collect the goods and make sure every caravan guard is good and dead. Unfortunately, not everyone you come across is dead - and not all of them grown men. A throng of women and children emerge from the ruins of the fight, slowly approaching with all the frailty of a wounded dog. Some are covered in blood, others have been shielded from the combat. %randombrother% asks what should be done with them. | The fighting over, you stumble across a party of women and children in the ruins of the caravan. They saunter over, seeming to understand that if they just took off running you\'d have reason to chase. One of the women, clutching a babe close to her chest, pleads.%SPEECH_ON%Please, you\'ve already done so much hurt and pain. Our fathers, husbands, brothers, you already killed them all. Is that not enough? Let us go.%SPEECH_OFF%%randombrother% spits. He looks toward you, gesturing toward a half-cocked.%SPEECH_ON%What do you want us to do, chief?%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "They are worth nothing, kill them all.",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-5);
						return "WomenAndChildren2";
					}

				},
				{
					Text = "We'll take them north, as slaves.",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-5);
						this.Flags.set("Slaves", true);
						this.Contract.setState("Return");
						return 0;
					}

				},
				{
					Text = "To hell with it - let them leave.",
					function getResult()
					{
						this.World.Assets.addMoralReputation(2);
						
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WomenAndChildren2",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_60.png[/img]{You nod to %randombrother%. He steps forward, weapon in hand, and with a quick slash removes a woman\'s head. A geyser of crimson fountains forth and her children are too blinded by the blood to see the rest of the blades coming.  The screams gradually die down as your brothers hack their way through the horrified crowd, dwindling their numbers into scattered whimpers. Your men double check their work until the victims are mute and the silence is dripping. | With a quick flick of your hand, you give the order. %randombrother% doesn\'t take but a moment to drive a blade through a kid\'s face, pegging the child against its mother\'s womb before slicing upward to claim her life as well. The rest of the men fan out, some reluctant while others yet go about with reverent diligence.\n\n As the horrific shrieks fill the air, you get the sense that some men are hacking and slashing simply to drive the noise out of their heads. The violence consumes all, an orgy of madness you know not whether to claim the pinnacle or nadir of man\'s doings for all meaning is lost in the event and the words to describe it have yet to be found in your tongue or any that is ancestral or beyond the dimly lit reckoning of what your eye can see. It is simply a happening. | Unfortunately, none can be allowed to live. You bark out an order and the your men jump to the task. A woman approaches, seemingly having misheard you, and asks for directions to the nearest town. %randombrother% answers by stoving her head in with a stone. Frightened children fan out in a winding scatter that reminds you of your rabbit hunting days. Your quickest men give chase while the rest stay behind to make short work of the parents. It is a gruesome sight indeed.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Well, it\'s not a pretty job, but that\'s what we\'re here for.",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_04.png[/img]{You return to %employer% with news of your success. He\'s got a warm greeting and a horn full of mead.%SPEECH_ON%Good jobm brothers. Did you, uh, see anything else while down there?%SPEECH_OFF%It\'s an odd question, but you don\'t pursue it. You tell the man it went down just as the results show. He nods and quickly thanks you before returning to his work. | %employer%\'s standing by a window when you return. He\'s drinking a mead.%SPEECH_ON%My little birds tell me the caravan was destroyed. The songs they sing, are they true?%SPEECH_OFF%You nod and tell him of the news. He hands over your reward, thanking you for your service before returning to the window. You catch a wry grin on the side of his face just before you leave. | %employer%\'s petting a dog as you return. His hand his shaking through the fur.%SPEECH_ON%I take it the wagon train is raided?%SPEECH_OFF%You tell him the details. He nods, but his petting hand comes to a rest.%SPEECH_ON%Did you by any chance... find something interesting?%SPEECH_OFF%You think it over, but can\'t come up with anything out of the ordinary. The man grins and returns to petting his dog.%SPEECH_ON%Thank you for services.%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Job well done.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Destroyed a caravan");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] Crowns"
				});
				
				this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/well_supplied_situation"), 2, this.Contract.m.Home, this.List);
				if(this.Flags.get("Slaves")) {
					this.Contract.addSituation(this.new("scripts/entity/world/settlements/situations/high_spirits_situation"), 2, this.Contract.m.Home, this.List);
				}
			}

		});
		
		this.m.Screens.push({
			ID = "Failure1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_45.png[/img]{When you return you find %employer% standing outside the settlement, staring in the distance. Without turning to you he speaks%SPEECH_ON%You failed. We needed the resources from that caravan. Now my whole clan will suffer because we didn't get them.%SPEECH_OFF%He turns to you fixing his gaze on your eyes. His hand gripping his sword tightly. You take your cue and leave before weapons are drawn.}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Damn this contract!",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to destroy a caravan");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CaravanDelivered",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_75.png[/img]{Awaiting the caravan, a pair of travelers come up from where the convoy should be going. They remark in detail about a cart which is no doubt the one which you were supposed to be hunting down. You should return to %employer%. | Word on the road hints that the caravan you were supposed to be hunting down has given you the slip and reached its destination. The company should return to %employer%.}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Damn this contract!",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"bribe",
			this.m.Flags.get("Bribe1")
		]);
		_vars.push([
			"bribe2",
			this.m.Flags.get("Bribe2")
		]);
		_vars.push([
			"start",
			this.World.getEntityByID(this.m.Flags.get("InterceptStart")).getName()
		]);
		_vars.push([
			"dest",
			this.World.getEntityByID(this.m.Flags.get("InterceptDest")).getName()
		]);
		_vars.push([
			"swordmaster",
			this.Const.Strings.CharacterNames[this.Math.rand(0, this.Const.Strings.CharacterNames.len() - 1)]
		]);
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Target != null && !this.m.Target.isNull())
			{
				this.m.Target.getSprite("selection").Visible = false;
				this.m.Target.setOnCombatWithPlayerCallback(null);
			}

			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		return this.m.Flags.get("TargetFaction") && this.m.Flags.get("InterceptStart") && this.m.Flags.get("InterceptDest");
	}

	function onSerialize( _out )
	{
		if (this.m.Target != null && !this.m.Target.isNull())
		{
			_out.writeU32(this.m.Target.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local target = _in.readU32();

		if (target != 0)
		{
			this.m.Target = this.WeakTableRef(this.World.getEntityByID(target));
		}
		this.contract.onDeserialize(_in);
	}

});

