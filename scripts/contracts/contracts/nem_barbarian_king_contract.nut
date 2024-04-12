this.nem_barbarian_king_contract <- this.inherit("scripts/contracts/barbarian_contract", {
	m = {
		Destination = null,
		Threat = null,
		LastHelpTime = 0.0,
		IsPlayerAttacking = false,
		IsEscortUpdated = false
	},
	function create()
	{
		this.contract.create();
		local r = this.Math.rand(1, 100);

		if (r <= 70)
		{
			this.m.DifficultyMult = this.Math.rand(90, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(115, 135) * 0.01;
		}

		this.m.Type = "contract.nem_barbarian_king";
		this.m.Name = "The Barbarian King";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 5.0;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
	}
	
	function start()
	{
		this.m.Flags.set("kingname", ::NorthMod.Utils.barbarianNameAndTitle());
	
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
					"Hunt down the Barbarian King and his warhost",
					"He was last reported to be in the region of %region%, %direction% from you"
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
				local f = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians);
				
				local nearest = ::NorthMod.Utils.nearestBarbarianNeighbour(this.Contract.m.Home);
				
				local nearest_base = nearest.settlement;
				local party = f.spawnEntity(nearest_base.getTile(), "Barbarian King", false, this.Const.World.Spawn.Barbarians, 125 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());				

				
				party.setDescription("A mighty warhost of barbarian tribes, united by a self-proclaimed barbarian king.");
				party.getSprite("body").setBrush("figure_wildman_04");
				party.setVisibilityMult(2.0);
		
				::NorthMod.Utils.addOverrideHostility(_party);
				::NorthMod.Utils.setIsHostile(_party, true);
				
				
				
				
				party.setAttackable(true);
				party.updatePlayerRelation();
				
				this.Contract.addUnitsToEntity(party, this.Const.World.Spawn.BarbarianKing, 100);
				this.Contract.m.Destination = this.WeakTableRef(party);
				party.getLoot().Money = this.Math.rand(150, 250);
				party.getLoot().ArmorParts = this.Math.rand(10, 30);
				party.getLoot().Medicine = this.Math.rand(3, 6);
				party.getLoot().Ammo = this.Math.rand(10, 30);
				party.addToInventory("supplies/roots_and_berries_item");
				party.addToInventory("supplies/dried_fruits_item");
				party.addToInventory("supplies/pickled_mushrooms_item");
				party.getSprite("banner").setBrush(nearest_base.getBanner());
				party.setAttackableByAI(false);
				local c = party.getController();
				local patrol = this.new("scripts/ai/world/orders/patrol_order");
				patrol.setWaitTime(20.0);
				c.addOrder(patrol);
				this.Contract.m.UnitsSpawned.push(party.getID());
				this.Contract.m.LastHelpTime = this.Time.getVirtualTimeF() + this.Math.rand(10, 40);
				this.Flags.set("HelpReceived", 0);
				local r = this.Math.rand(1, 100);
				
				if (r <= 15)
				{
					this.Flags.set("IsAGreaterThreat", true);
					c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				}
				
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives.clear();
				this.Contract.m.BulletpointsObjectives = [
					"Hunt down the Barbarian King and his warhost",
					"His warhost was last spotted around %region%, %terrain% %direction% from you, near %nearest_town%"
				];

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onCombatWithKing.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Destination == null || this.Contract.m.Destination.isNull())
				{
					this.Contract.setState("Return");
				}
				else if (!this.Contract.isPlayerNear(this.Contract.m.Destination, 600) && this.Flags.get("HelpReceived") < 4 && this.Time.getVirtualTimeF() >= this.Contract.m.LastHelpTime + 70.0)
				{
					this.Contract.m.LastHelpTime = this.Time.getVirtualTimeF() + this.Math.rand(0, 30);
					this.Contract.setScreen("Directions");
					this.World.Contracts.showActiveContract();
				}
				else if (!this.Contract.isPlayerNear(this.Contract.m.Destination, 600) && this.Flags.get("HelpReceived") == 4)
				{
					this.Contract.setScreen("GiveUp");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatWithKing( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;

				if (!_dest.isInCombat() && !this.Flags.get("IsKingEncountered"))
				{
					this.Flags.set("IsKingEncountered", true);

					if (this.Flags.get("IsAGreaterThreat"))
					{
						this.Contract.setScreen("AGreaterThreat1");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("Approach");
						this.World.Contracts.showActiveContract();
					}
				}
				else
				{
					this.Flags.set("IsAGreaterThreat", false);
					_dest.getController().getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(true);
					local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					properties.Music = this.Const.Music.BarbarianTracks;
					properties.TemporaryEnemies = [
						this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID()
					];
					this.World.Contracts.startScriptedCombat(properties, this.Contract.m.IsPlayerAttacking, true, true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_GreaterThreat",
			function start()
			{
				this.Contract.m.BulletpointsObjectives.clear();
				this.Contract.m.BulletpointsObjectives = [
					"Travel with the Barbarian King to face a greater threat together"
				];

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.setFaction(2);
					this.World.State.setEscortedEntity(this.Contract.m.Destination);
				}
			}

			function update()
			{
				if (this.Flags.get("IsContractFailed"))
				{
					if (this.Contract.m.Threat != null && !this.Contract.m.Threat.isNull())
					{
						this.Contract.m.Threat.getController().clearOrders();
					}

					if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
					{
						this.Contract.m.Destination.getController().clearOrders();
						this.Contract.m.Destination.setFaction(this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID());
					}

					this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
					this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Company broke a contract");
					this.World.Contracts.finishActiveContract(true);
					return;
				}

				if (this.Contract.m.Threat == null || this.Contract.m.Threat.isNull() || !this.Contract.m.Threat.isAlive())
				{
					this.Contract.setScreen("AGreaterThreat5");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					if (!this.Contract.m.IsEscortUpdated)
					{
						this.World.State.setEscortedEntity(this.Contract.m.Destination);
						this.Contract.m.IsEscortUpdated = true;
					}

					this.World.State.setCampingAllowed(false);
					this.World.State.getPlayer().setPos(this.Contract.m.Destination.getPos());
					this.World.State.getPlayer().setVisible(false);
					this.World.Assets.setUseProvisions(false);
					this.World.getCamera().moveTo(this.World.State.getPlayer());

					if (!this.World.State.isPaused())
					{
						this.World.setSpeedMult(this.Const.World.SpeedSettings.FastMult);
					}

					this.World.State.m.LastWorldSpeedMult = this.Const.World.SpeedSettings.FastMult;
				}

				if (this.Contract.isPlayerAt(this.Contract.m.Threat))
				{
					this.Contract.setScreen("AGreaterThreat4");
					this.World.Contracts.showActiveContract();
				}
			}

			function end()
			{
				this.World.State.setCampingAllowed(true);
				this.World.State.setEscortedEntity(null);
				this.World.State.getPlayer().setVisible(true);
				this.World.Assets.setUseProvisions(true);

				if (!this.World.State.isPaused())
				{
					this.World.setSpeedMult(1.0);
				}

				this.World.State.m.LastWorldSpeedMult = 1.0;
			}

			function onRetreatedFromCombat( _combatID )
			{
				this.Flags.set("IsContractFailed", true);
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
					if (this.Flags.get("IsAGreaterThreat"))
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer% and two of his henchmen are huddled over the map. Worried expressions painted all over their faces. %employer_short% looks up to you and waves you to come look at the map.%SPEECH_ON%He is here in %region%, the bastard.%SPEECH_OFF% Your confused look just brings out the sigh from %employer_short%, so he explains.%SPEECH_ON%%kingname% has proclaimed himself the king of all north. He has already managed to unite some of the clans and destroy those who would not submit. There is no doubt he will be coming for us soon and I have no intention of bending the knee to the likes of him. I need you to go to %region% and defeat him.%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{How many crowns are we talking about here? | That\'s no small feat to ask. | I could be persuaded for the right price. | A task like this better pay well.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{We\'re not about to engage an army. | That\'s not the kind of work we\'re looking for. | I won\'t risk the company against an enemy such as this.}",
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
			ID = "Directions",
			Title = "Along the way...",
			Text = "{[img]gfx/ui/events/event_59.png[/img]A throng of refugees passes the crew by. Rumors abound that the barbarian king is %distance% to the %direction%. Many of the people on the road are from %nearest_town% and seem to have no interest in waiting around for a sea of savages to descend upon them. | [img]gfx/ui/events/event_41.png[/img]A trader with an empty merchant cart crosses paths with the crew. As he sees your men, his first thought is to run, but as you explain you are not here to raid him, he does state that the roads are flowing with rumors of a savage calling himself king. He states that the barbarian is somewhere %direction% of where you stand, around %region%. He regards the path of your journey with a nod. | [img]gfx/ui/events/event_94.png[/img]A half-naked man is found sitting cross-legged to the side of the road. %SPEECH_ON%Have you come back to take the my life as well, after taking everything for me?%SPEECH_OFF%You explain that you are not here to raid in pillage, but are in fact looking for a barbarian king. The man states that a savage with an army burned his farmstead, wronged the women, and slew every swinging dick.%SPEECH_ON%I survived hiding in a brush pile with my hands wrapped over my mouth.%SPEECH_OFF%The man wipes his nose.%SPEECH_ON%I seen you with your weapons. If you seek this barbarian then I can tell ya it seemed they was heading %direction% of here, down %terrain% %distance% aways to %region%.%SPEECH_OFF% | [img]gfx/ui/events/event_94.png[/img]You find the burnt remains of a small hamlet. A few of its survivors linger, their shapes about as present as the smoke drifting off their destroyed homes. One states that a man posturing like a king came and killed everyone they got their hands on before heading %direction%. | [img]gfx/ui/events/event_60.png[/img]You\'ve come across a number of flipped carts or burning wagons. They\'re barren, all the goods gone, only the corpses of their owners remain. A few children are picking through the rubble of one such ruin. When you ask them who did this, a cheeky boy speaks up.%SPEECH_ON%Savages from the north, but they headin\' %direction% now. I seen them. They is %terrain%, %distance% I wager. %SPEECH_OFF%He picks his nose.%SPEECH_ON%They is killers, by the way. Kinda look your sort, but larger. Probably stronger.%SPEECH_OFF% | [img]gfx/ui/events/event_76.png[/img]A scout of %employer% meets you on the road. He reports that the barbarian king was sighted around %region% to the %direction% %terrain%. He is %distance%. You ask the scout if he\'d join you for the fight and the man laughs.%SPEECH_ON%No chief, I\'m quite alright. I run about, see things, and report them. In between I fark a whore or two. It\'s a good life and I don\'t need fighting no kings to ruin it!%SPEECH_OFF%Fair enough. | [img]gfx/ui/events/event_132.png[/img]%randombrother% spots them first. Signs of a skirmish, charred corpses, faded footprints and wagon tracks, so many that it is clear an army passed through here.%SPEECH_ON%Looks like they was headin\' %direction% after the battle, captain.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We\'re on his trail.",
					function getResult()
					{
						this.Flags.increment("HelpReceived", 1);
						this.Contract.getActiveState().start();
						this.World.Contracts.updateActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "GiveUp",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_45.png[/img]{There\'s no doubt now. With all the signs you\'ve encountered, and all the reports that people have given you, you finally know exactly where the Barbarian King and his warhost is headed. The only thing left is to confront him.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We should make haste.",
					function getResult()
					{
						this.Flags.increment("HelpReceived", 1);
						this.Contract.m.Destination.setVisibleInFogOfWar(true);
						this.Contract.m.Destination.setDiscovered(true)
						this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0)
						this.World.getCamera().moveTo(this.Contract.m.Destination);
						this.Contract.getActiveState().start();
						this.World.Contracts.updateActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "Approach",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_135.png[/img]{The Barbarian King comes to the field with his warhost, a party of oversized miscreants, growling warriors, sheepish slaves, and howling women. It is the army of a man who has collected from the land every scrap of resource, every inch of advantage, and will surely collect civilization itself as surely as a simple snowball may become the avalanche. You prepare the men for battle. | The Barbarian King\'s warband trundles across the land with no hint of training or even semblance of formation. But you know that with the mere wave of the savage\'s hand he may set upon his enemies a horde of killers who have more than ample supply of carnage to overcome any lack of cohesion. You prepare the men for battle. | The warband of savages is like that of a fever dream, taking shape across the horizon like travelers from every corner of the earth, dressed not in any uniform or armor, but in mockeries of those they have conquered. Warriors with wedding dresses wrapped about their arms, long coats of royal color adorned upon men of no status, some wearing ribs and clattering bones as though they got the last of the pillaging. They were but farmers of horror, villages their crop, and war but a harvest for all seasons.\n\nYou shake your head at the sight and prepare the men for battle.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult()
					{
						this.Contract.getActiveState().onCombatWithKing(this.Contract.m.Destination, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "Victory",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{The Barbarian King is dead. Though he adorned himself the title of royalty, he lies amongst the dead like any other of his people. A savage. A primitive. With a slightly hardier body and some accoutrements native to his warring and pillaging and ravaging. Little else distinguishes him. You chop into his neck with your sword and put your boot to his face as you cut him clean off the shoulders. %randombrother% 2takes the heavy head and drops it into a knapsack. You order the men to scavenge what they can before preparing a return to %employer%.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{The %companyname% prevailed! | Victory!}",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.setState("Return");
			}

		});
		this.m.Screens.push({
			ID = "AGreaterThreat1",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_136.png[/img]{You find the Barbarian King, but a parlay is made. The Barbarian King and an elder step across the field to meet you personally. Against better judgment, you go out to see them. The Barbarian King speaks and the elder nod.%SPEECH_ON%We are not here to conquer, but to defeat the Great Untoward.%SPEECH_OFF%Despite living all your life in the north, you are confused so the Elder continues to explain.%SPEECH_ON%Death has left this land, and in its absence a man slain becomes lost between worlds and will rise again. A horde of Untoward, the Undead, are on the march. We are not here for you or your clan. If you help us destroy them we will depart the land and trouble your people no more. Only the Untoward.%SPEECH_OFF%%randombrother% leans in and whispers.%SPEECH_ON%We could join them, sure, but we could also just go ahead and attack them now. They\'re clearly not at full strength and whatever they say here the fact is they\'ve been ravaging the lands anyway, chief, and raping and pillaging is just what they got in their blood.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We\'ll attack them and rid the north of this so-called king.",
					function getResult()
					{
						return "AGreaterThreat2";
					}

				},
				{
					Text = "We will join with them to march against the Untoward.",
					function getResult()
					{
						return "AGreaterThreat3";
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "AGreaterThreat2",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_136.png[/img]{You spit and nod toward the king and elder.%SPEECH_ON%We walked past burned homes, raped women, and slain men just to find your sorry lot, and now you want to band together? We ain\'t allies. We ain\'t friends. Why don\'t you go to pray to whatever your gods, you...%SPEECH_OFF%The elder holds his hand up and talks with the king. The two men nod, turn, and leave. %randombrother% laughs.%SPEECH_ON%Brevity is the soul of scorn, chief.%SPEECH_OFF%You tell the man to get back to the battle line and prepare for the fight ahead.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Prepare for battle.",
					function getResult()
					{
						this.Flags.set("IsAGreaterThreat", false);
						this.Contract.getActiveState().onCombatWithKing(this.Contract.m.Destination, this.Contract.m.IsPlayerAttacking);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "AGreaterThreat3",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_136.png[/img]{You nod toward the elder.%SPEECH_ON%Alright, we\'ll work with you to see to this greater threat.%SPEECH_OFF%The elder smiles and rubs his thumbs together and speaks a few phrases in his native tongue. The Barbarian King slams his chest with his fist and then slugs you in the shoulder with it, before arcing the hand across the sky. Laughing, the elder explains.%SPEECH_ON%So we fight together, but if we shall fall, he will not fight with you as an undead. If slain, the King shall find Death himself and bring his scythe upon his own neck.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Prepare to march.",
					function getResult()
					{
						return 0;
					}

				}
			],
			function start()
			{
				local playerTile = this.World.State.getPlayer().getTile();
				local nearest_undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getNearestSettlement(playerTile);
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 9, 15);
				local party = this.World.FactionManager.getFaction(nearest_undead.getFaction()).spawnEntity(tile, "The Untoward", false, this.Const.World.Spawn.UndeadArmy, 260 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				party.getSprite("banner").setBrush(nearest_undead.getBanner());
				party.setDescription("A legion of walking dead, back to claim from the living what was once theirs.");
				party.setSlowerAtNight(false);
				party.setUsingGlobalVision(false);
				party.setLooting(false);
				this.Contract.m.UnitsSpawned.push(party);
				this.Contract.m.Threat = this.WeakTableRef(party);
				party.setAttackableByAI(false);
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local wait = this.new("scripts/ai/world/orders/wait_order");
				wait.setTime(99999);
				c.addOrder(wait);
				this.Contract.m.Destination.getFlags().set("hostile", false);
				this.Contract.m.Destination.setFaction(2);
				this.Contract.m.Destination.getSprite("selection").Visible = false;
				this.Contract.m.Destination.setOnCombatWithPlayerCallback(null);
				c = this.Contract.m.Destination.getController();
				c.clearOrders();
				local move = this.new("scripts/ai/world/orders/move_order");
				move.setDestination(party.getTile());
				c.addOrder(move);
				this.Contract.setState("Running_GreaterThreat");
			}

		});
		this.m.Screens.push({
			ID = "AGreaterThreat4",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_73.png[/img]{The king was not lying: the ancients have put forth an army. It is a warband of decayed faces and rusted armor, a host of groaning, moaning monsters upon which light falls and instantly seeps away. It is surely an army of darkness. Were you or the barbarians to fight it alone you would surely lose, but together you may have a chance yet!}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Prepare for battle.",
					function getResult()
					{
						this.World.Contracts.showCombatDialog(false, true, true);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "AGreaterThreat5",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_136.png[/img]{The ancient dead have been slain to the last. As your men and the king\'s pick the field, the Barbarian King and the elder come to you. %SPEECH_ON%You did well, very well, and I wish men such as yourself and your crew would fight alongside me, but I guess that cannot happen. We live in a maze of many worlds and in that maze we all shall stay, lost, sometimes hearing one another\'s shouts, never having enough time to know each other. He says thanks. And he wishes you well.%SPEECH_OFF% The king turns around and leaves, but the elder hands you a horned helmet, the very one you\'d seen the Barbarian King himself wearing at times. He says nothing, only hits his chest and points to the sky and that\'s all there is.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Farewell, king.",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull() && this.Contract.m.Destination.isAlive())
				{
					this.Contract.m.Destination.die();
					this.Contract.m.Destination = null;
				}

				local item = this.new("scripts/items/helmets/barbarians/heavy_horned_plate_helmet");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + this.Const.Strings.getArticle(item.getName()) + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_31.png[/img]{%employer% stares at the Barbarian King\'s head like a wolf would meanly stare at anything not its own self.%SPEECH_ON%Interesting. You did well. I must admit, I wasn\'t sure you will be up to the task, but you delivered. So is your reward delivered to you.%SPEECH_OFF%The man points toward the satchel in the corner.}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Well deserved.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Killed a self-proclaimed barbarian king");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				local money = this.Contract.m.Payment.getOnCompletion();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "Success2",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_31.png[/img]{%employer% welcomes you reluctantly.%SPEECH_ON%You realize I have scouts everywhere, don\'t you?%SPEECH_OFF%Holding up your empty hands, you tell him you had no intent on lying. The \'barbarian king\' will bother the lands no more. Your employer taps his fingers together a few times then nods.%SPEECH_ON%Your honesty is refreshing, though I must say it is quite unfortunate the man and his warband still live. That said, all reports suggest they are moving away so I suppose your work is done all the same, a fat king head or not. Your pay, as agreed upon.%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Well deserved.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Resolved the threat of a self-proclaimed barbarian king");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				local money = this.Contract.m.Payment.getOnCompletion();
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + money + "[/color] Crowns"
				});
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"kingname",
			this.m.Flags.get("kingname")
		]);
			
		_vars.push([
			"employer_short",
			this.m.EmployerID != 0 ? this.Tactical.getEntityByID(this.m.EmployerID).getNameOnly() : ""
		]);
		if (this.m.Destination != null && !this.m.Destination.isNull() && this.m.Destination.isAlive())
		{
			local distance = this.World.State.getPlayer().getTile().getDistanceTo(this.m.Destination.getTile());
			distance = this.Const.Strings.Distance[this.Math.min(this.Const.Strings.Distance.len() - 1, distance / 30.0 * (this.Const.Strings.Distance.len() - 1))];
			local region = this.World.State.getRegion(this.m.Destination.getTile().Region);
			local settlements = this.World.EntityManager.getSettlements();
			local nearest;
			local nearest_dist = 9999;

			foreach( s in settlements )
			{
				local d = s.getTile().getDistanceTo(this.m.Destination.getTile());

				if (d < nearest_dist)
				{
					nearest = s;
					nearest_dist = d;
				}
			}

			_vars.push([
				"region",
				region.Name
			]);
			_vars.push([
				"nearest_town",
				nearest.getName()
			]);
			_vars.push([
				"distance",
				distance
			]);
			_vars.push([
				"direction",
				this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Destination.getTile())]
			]);
			_vars.push([
				"terrain",
				this.Const.Strings.Terrain[this.m.Destination.getTile().Type]
			]);
		}
		else
		{
			local nearest_base = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getNearestSettlement(this.World.State.getPlayer().getTile());
			local region = this.World.State.getRegion(nearest_base.getTile().Region);
			_vars.push([
				"region",
				region.Name
			]);
			_vars.push([
				"nearest_town",
				""
			]);
			_vars.push([
				"distance",
				""
			]);
			_vars.push([
				"direction",
				this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(region.Center)]
			]);
			_vars.push([
				"terrain",
				this.Const.Strings.Terrain[region.Type]
			]);
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.World.State.setCampingAllowed(true);
			this.World.State.setEscortedEntity(null);
			this.World.State.getPlayer().setVisible(true);
			this.World.Assets.setUseProvisions(true);

			if (!this.World.State.isPaused())
			{
				this.World.setSpeedMult(1.0);
			}

			this.World.State.m.LastWorldSpeedMult = 1.0;
			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		return true;
	}

	function onIsTileUsed( _tile )
	{
		return false;
	}

	function onSerialize( _out )
	{
		if (this.m.Destination != null && !this.m.Destination.isNull())
		{
			_out.writeU32(this.m.Destination.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		if (this.m.Threat != null && !this.m.Threat.isNull())
		{
			_out.writeU32(this.m.Threat.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local obj = _in.readU32();

		if (obj != 0)
		{
			local party = this.World.getEntityByID(obj);
			if (party != null && !partyisNull() && party.isAlive())
			{
				::NorthMod.Utils.addOverrideHostility(party);	
			}
			this.m.Destination = this.WeakTableRef(party);
		}

		obj = _in.readU32();

		if (obj != 0)
		{
			this.m.Threat = this.WeakTableRef(this.World.getEntityByID(obj));
		}

		this.contract.onDeserialize(_in);
		local partyID = this.Contract.m.UnitsSpawned[0];
		local party = this.World.getEntityByID(id);
		
		
		
	}

});

