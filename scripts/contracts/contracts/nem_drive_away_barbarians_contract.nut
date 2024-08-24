this.nem_drive_away_barbarians_contract <- this.inherit("scripts/contracts/barbarian_contract", {
	m = {
		Destination = null,
		Dude = null,
		Reward = 0,
		OriginalReward = 0
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.nem_drive_away_barbarians";
		this.m.Name = "Drive Off Barbarians";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function start()
	{
		local nearest = ::NorthMod.Utils.nearestBarbarianNeighbour(this.m.Home);
		local banditcamp = nearest.settlement;
		this.m.Destination = this.WeakTableRef(banditcamp);
		this.m.Flags.set("DestinationName", banditcamp.getName());
		this.m.Flags.set("EnemyBanner", banditcamp.getBanner());		
		this.m.Flags.set("ChampionBrotherName", "");
		this.m.Flags.set("ChampionBrother", 0);
		this.m.Payment.Pool = 600 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

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
					"Drive off barbarians at " + this.Flags.get("DestinationName") + " %direction% of %origin%"
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
				this.Contract.m.Destination.setLastSpawnTimeToNow();
				this.Contract.m.Destination.clearTroops();

				if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Destination.getFlags().get("IsEventLocation"))
				{
					this.Contract.m.Destination.getLoot().clear();
				}
				::NorthMod.Utils.setIsHostile(this.Contract.m.Destination, true);
				this.Contract.addUnitsToEntity(this.Contract.m.Destination, this.Const.World.Spawn.Barbarians, 110 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				this.Contract.m.Destination.setLootScaleBasedOnResources(110 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				this.Contract.m.Destination.setResources(this.Math.min(this.Contract.m.Destination.getResources(), 70 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult()));
				this.Contract.m.Destination.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Destination.getTile().Pos, 500.0);
				local r = this.Math.rand(1, 100);
				this.logInfo("drive away barbarians chance: " + r);
				if (r <= 20)
				{
					if (this.World.Assets.getBusinessReputation() >= 500 && this.Contract.getDifficultyMult() >= 1.0)
					{
						this.Flags.set("IsRevenge", true);
					}
				}
				else if (r <= 30)
				{
					this.Flags.set("IsSurvivor", true);
				}
				else if (!this.World.Flags.get("ContractBarbariansRecruit") && this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
				{
					this.World.Flags.set("ContractBarbariansRecruit", true);
					this.Flags.set("Recruit", true);
				}
				if(this.Contract.getDifficultySkulls() == 3)
				{
					this.Flags.set("EnemyChampion", true);
				}
				this.Flags.set("EnemyChieftain", this.Contract.m.Destination.getChieftain().getName());
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onDestinationAttacked.bindenv(this));
				}
			}

			function update()
			{
				if (this.Flags.get("IsDuelVictory"))
				{
					this.Contract.setScreen("TheDuel2");
					this.World.Contracts.showActiveContract();
					this.Flags.set("IsDuelVictory", false);
				}
				else if (this.Flags.get("IsDuelDefeat"))
				{
					this.Contract.setScreen("TheDuel3");
					this.World.Contracts.showActiveContract();
					this.Flags.set("IsDuelDefeat", false);
				}
				else if (this.Contract.m.Destination == null || this.Contract.m.Destination.isNull() || !this.Contract.m.Destination.isAlive())
				{
					if (this.Flags.get("IsSurvivor"))
					{
						this.Contract.setScreen("Survivor1");
						this.World.Contracts.showActiveContract();
					}

					this.Contract.setState("Return");
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true )
			{
				this.logInfo("on destination attacked");
				if (this.Flags.get("Recruit") && !this.Flags.get("IsBrotherRevengeShown"))
				{
					this.logInfo("bro-revenge");
					this.Flags.set("IsAttackDialogTriggered", true);
					this.Flags.set("IsBrotherRevengeShown", true);
					this.Contract.setScreen("BrotherRevenge");
					this.World.Contracts.showActiveContract();
				}
				else if (!this.Flags.get("IsAttackDialogTriggered"))
				{
					this.logInfo("approaching");
					this.Flags.set("IsAttackDialogTriggered", true);
					this.Contract.setScreen("Approaching");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					this.logInfo("show combat");
					local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					properties.TemporaryEnemies = [
						this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID()
					];
					this.World.Contracts.startScriptedCombat(properties, _isPlayerAttacking, true, true);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Duel")
				{
					this.Flags.set("IsDuelVictory", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Duel")
				{
					this.Flags.set("IsDuelDefeat", true);
					if (this.Flags.get("PartyChampion"))
					{
						this.Contract.resetChampionDuels();
					}
					
				}
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
				if (this.Flags.get("IsRevengeVictory"))
				{
					this.Contract.setScreen("Revenge2");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsRevengeDefeat"))
				{
					this.Contract.setScreen("Revenge3");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsRevenge") && this.Contract.isPlayerNear(this.Contract.m.Home, 600))
				{
					this.Contract.setScreen("Revenge1");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.isPlayerAt(this.Contract.m.Home) && this.Flags.get("IsDuel"))
				{
					this.Contract.setScreen("Success2");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					this.Contract.setScreen("Success1");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Revenge")
				{
					this.Flags.set("IsRevengeVictory", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Revenge")
				{
					this.Flags.set("IsRevengeDefeat", true);
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
			Text = "[img]gfx/ui/events/event_20.png[/img]{You find %employer% with a dirtied and mudslaked woman sat beside his chair. Her hair is matted and her flesh stricken with all manner of punishment. She sneers at you as if it was all your doing. %employer% kicks her over.%SPEECH_ON%Don\'t mind this wench, warrior. We caught her and her friends raiding our supplies. Killed the lot of the bastards, I\'d say we spared her for the fun of it but beating on her is about as fun as doing it to a dog.%SPEECH_OFF%He kicks her again and she snarls back.%SPEECH_ON%See? Well, I have news! We have located the stain she came from and I have every intention of burning it to the ground. That\'s where you come in. Their village is %direction% of here. Stomp it out and you\'ll be rewarded very well. You interested or do I have to find a man of meaner character?%SPEECH_OFF% | %employer% has a crowd of clansmen in his room. More of them than any man should be comfortable with in such proximity, but they surprisingly don\'t seem to be interested in lynching him. Seeing you, %employer% calls you forward.%SPEECH_ON%Ah, finally! Our answer is here! Warrior, the clan %direction% of here have been pillaging our village and raping anything with a hole. We\'re sick of it we\'ll not take it anymore.%SPEECH_OFF%The crowd of peons jeers, one man yelling out that the barbarians {cut the head off his mother | also murdered his pet goats | stole all his dogs, the bastards | ate the liver of his youngest son}. %employer% nods.%SPEECH_ON%Aye. Aye, men, aye! And so I say, warrior, that you plot a path to their village and treat them to measured, appropriate revenge.%SPEECH_OFF% | %employer% waves you into his jurt. He\'s holding a spear with a bloodied tip.%SPEECH_ON%One of the clans sent me this today. A head was spiked to it. %randombarbarian%\'s son. They took the eyes and tongue out of. They are sending us a message, without speaking a word. And so I have a feeling I shall return the favor with your help, warrior. Go %direction% of here, find their little village, and burn it to the ground.%SPEECH_OFF% | %employer% welcomes you in his jurt, his face is grim as if weighed by thousand stones. He speaks succinctly.%SPEECH_ON%There is a clan, their village %direction% of here from which they are sending raiding parties. They rape, they pillage, they are nothing but insects and varmints in the shape of men. I want them all gone, to the very last. Are you willing to take on this task?%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{How many crowns are we talking about? | What is %townname% prepared to pay for their safety? | Let\'s talk money.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{Not interested. | We have more important matters to settle. | I wish you luck, but we\'ll not be part of this.}",
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
			ID = "Approaching",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{You\'ve found the clan village and a series of cairns marking a path towards it. At the end of the path a line of men stands firm. %randombrother% nods.%SPEECH_ON%They know we are coming and are well armed. We might be in for a fight. Might be better to challenge their chieftain and settle this in a duel. On the other hand %employer% will be happier if we kill them all.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Challenge the chieftain to a duel",
					function getResult()
					{
						return "TheDuel1";
					}

				}
				{
					Text = "Prepare to attack.",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "BrotherRevenge",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{You\'ve found the clan village and a series of cairns that lead toward it. Before the first of the cairns a large men is standing, as you approach he speaks.%SPEECH_ON%You the ones %employer% sent to kill these bastards?%SPEECH_OFF%You nod and say it will be done soon.%SPEECH_ON%Good, because I want to be a part of it. They killed my brother and if you'll have me, I'd join you in this fight. Might even stay afterwards.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "You can join us.",
					function getResult()
					{
						this.World.getPlayerRoster().add(this.Contract.m.Dude);
						this.World.getTemporaryRoster().clear();
						this.Contract.m.Dude.onHired();
						this.Contract.m.Dude = null;
						
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						
						return 0;
					}

				},
				{
					Text = "We don't need more men.",
					function getResult()
					{
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			],
			function start()
			{
				local roster = this.World.getTemporaryRoster();
				this.Contract.m.Dude = roster.create("scripts/entity/tactical/player");
				this.Contract.m.Dude.setStartValuesEx([
					"barbarian_background"
				]);
				this.Contract.m.Dude.getBackground().m.RawDescription = "Large and burly man, %name% has joined your crew to fight against the rival barbarian clan that killed his brother. After the deed was done and thirst for revenge satisfied, he simply decided to stay.";
				this.Contract.m.Dude.getBackground().buildDescription(true);
				local items = this.Contract.m.Dude.getItems();
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				
				items.equip(this.new("scripts/items/armor/barbarians/thick_furs_armor"));
				items.equip(this.new("scripts/items/weapons/crude_polearm"));
				
				this.Characters.push(this.Contract.m.Dude.getImagePath());
				
			}

		});
		this.m.Screens.push({
			ID = "TheDuel1",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_139.png[/img]{You've decided to honor the old ways and speak out a challenge to the chieftain of the clan. Amongst the warriors a lone figure steps out and stands between the battle lines. The man is huge even for northerners, his heavy armor adorned with bones of slain enemies. He speaks in a strong and guttural voice %SPEECH_ON%Welcome, fellow northerners. My name is %enemychieftain%, I'm the chieftain of this clan and I accept your challenge. As is tradition, the battle between two men is just as honorable and of value as that between two armies.%SPEECH_OFF%The terms are agreed quickly, if you win his clansmen will no longer raid %townname% and if he wins, they'll do as they please.}",
			Image = "",
			List = [],
			Options = [],
			function start()
			{
				
				
				local raw_roster = this.World.getPlayerRoster().getAll();
				local roster = [];
				foreach( bro in raw_roster )
				{
					if (bro.getPlaceInFormation() <= 17)
					{
						roster.push(bro);
					}
				}

				::NorthMod.Utils.duelRosterSort(roster);
				
				
				local e = this.Math.min(4, roster.len());
				local name = this.Contract.m.Destination.getChieftain().getName();
				
				for( local i = 0; i < e; i = ++i )
				{
					local bro = roster[i];
					local text = "";
					if (bro.getFlags().get("IsPlayerCharacter") || bro.getFlags().get("IsPlayerCharacterAvatar"))
					{
						text = "I, "
					}
					if (bro.getSkills().hasSkill("trait.champion"))
					{
						this.Flags.set("PartyChampion", true);
					}
					this.Options.push({
						Text = text + roster[i].getName() + " will fight you!",
						function getResult()
						{
							this.Flags.set("ChampionBrotherName", bro.getName());
							this.Flags.set("ChampionBrother", bro.getID());
							local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
							properties.CombatID = "Duel";
							properties.Music = this.Const.Music.BarbarianTracks;
							properties.Entities = [];
							properties.Entities.push({
								ID = this.Const.EntityType.BarbarianChampion,
								Name = name,
								Variant = this.Flags.get("EnemyChampion") ? 1 : 0,
								Row = 0,
								Script = "scripts/entity/tactical/humans/barbarian_champion",
								Faction = this.Contract.m.Destination.getFaction(),
								function Callback( _entity, _tag )
								{
									_entity.setName(name);
								}

							});
							properties.EnemyBanners.push(this.Contract.m.Destination.getBanner());
							properties.Players.push(bro);
							properties.IsUsingSetPlayers = true;
							properties.TemporaryEnemies = [
								this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID()
							];
							properties.BeforeDeploymentCallback = ::NorthMod.Utils.duelCleanMap.bindenv(this);
							properties.AfterDeploymentCallback = ::NorthMod.Utils.duelPlaceActors.bindenv(this);
							this.World.Contracts.startScriptedCombat(properties, false, true, false);
							return 0;
						}

					});
					  // [062]  OP_CLOSE          0      7    0    0
				}
			
			}

		});
		this.m.Screens.push({
			ID = "TheDuel2",
			Title = "After the battle...",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "A good end.",
					function getResult()
					{
						this.World.Assets.addMoralReputation(2);
						this.Flags.set("IsRevenge", false);
						this.Flags.set("IsDuel", true);
						this.Contract.m.Destination.changeChieftain();
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Destination.getSprite("selection").Visible = false;
				::NorthMod.Utils.setIsHostile(this.Contract.m.Destination, false);
				local bro = this.Tactical.getEntityByID(this.Flags.get("ChampionBrother"));
				this.Characters.push(bro.getImagePath());
				
				if(bro.getFlags().get("IsPlayerCharacter"))
				{
					this.Text = "[img]gfx/ui/events/event_138.png[/img]{Chieftain %enemychieftain% is slain, his beaten body lying before your feet. You turn your face towards his clan.}"
				}
				else {
					this.Text = "[img]gfx/ui/events/event_138.png[/img]{%champbrother% sheathes his weapons and stands over the corpse of the slain chieftain. Nodding, the victorious warrior stares back at you.%SPEECH_ON%Finished, chief.%SPEECH_OFF%}"
				}
				
				this.Text += "{One of the clan elders comes forward and raises his staff.%SPEECH_ON%So it is, our chieftain is dead and you have accomplished honorably your goal. We will stop the raiding and attacks against %townname%.%SPEECH_OFF%If they\'re true to their word then you can go and tell %employer% now.}"
				
				local championBro = this.Tactical.getEntityByID(this.Flags.get("ChampionBrother"));
				
				
				
				if(this.Flags.get("EnemyChampion") && !this.Flags.get("PartyChampion"))
				{
					
					
					local trait = this.new("scripts/skills/traits/champion_trait");
					championBro.getSkills().add(trait);
					this.Contract.resetChampionDuels();
					
					if(championBro.getSkills().hasSkill("trait.player"))
					{
						this.Text += "\n\n You have now won a duel against renowned champion. This experience has made you a better fighter, particularly when in single combat."
					}
					else
					{
						this.Text += "\n\n %champbrother% has now won a duel against renowned champion. This experience has made him a better fighter, particularly when in single combat."
					}
					
					this.List.push({
						id = 10,
						icon = trait.getIcon(),
						text = championBro.getName() + " becomes " + trait.getName()
					});
					
				}
				
				if(championBro.getLevel() < 11)
				{
					local duelExperience = championBro.getSkills().getSkillByID("effects.duel_experience");
					if(duelExperience == null)
					{
						duelExperience = this.new("scripts/skills/effects/duel_experience_effect");
						duelExperience.updateExperienceLevel(3);
						championBro.getSkills().add(duelExperience);
						
						this.List.push({
							id = 11,
							icon = duelExperience.getIcon(),
							text = championBro.getName() + " now has " + duelExperience.getName()
						});
					}
					else
					{
						duelExperience.updateExperienceLevel(3);
					}
					
					
				}
				
				
			}

		});
		this.m.Screens.push({
			ID = "TheDuel3",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{It was a good fight, a clash between men upon the earth with those in observation silent as though in awe of some timeless and honorable rite. But. %champbrother% lies dead on the ground. Bested and killed. The %barbarianname% steps forward again. He does not carry any hint of gloating or grin.%SPEECH_ON%Outsiders, the battle between two men is as such as it were between all of us combined. We have won, blessed is the Far Rock\'s gaze, and so we request that you depart these lands and do not return with weapons drawn.%SPEECH_OFF%A few of your warriors look to you awating decision. %randombrother% points out tradition is sacred, but the crew still has a job to do.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We will stay true to our word and leave you in peace.",
					function getResult()
					{
						this.Flags.set("IsRevenge", false);
						this.Contract.m.Destination.getSprite("selection").Visible = false;
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.Assets.addMoralReputation(5);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to destroy a barbarian encampment threatening " + this.Contract.m.Home.getName());
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				},
				{
					Text = "Everyone, charge!",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-10);
						local barbarians = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians);
						local relation = barbarians.getPlayerRelation();
						if (relation > 30)
						{
							local change = relation - 30;
							this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).addPlayerRelation(-change, "Broke the rules of an honorable duel");
						}
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Survivor1",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{The battle over, %randombrother% beckons you over. In one of the tents is a barbarian nursing a wound. Men, women, and children litter the floor around him. Your warrior points to him.%SPEECH_ON%We chased him in here. I think that\'s his family all around him, or someone he knows, cause he just collapsed and hasn\'t moved since.%SPEECH_OFF%You walk toward the man and crouch before him. You tap one of his deerskin boots and ask if he can hear you and respond. He nods and shrugs.%SPEECH_ON%Barely. You did this. Didn\'t have to, but did. Finish me, or I fight with you. One, the or other, all honorable.%SPEECH_OFF%It seems he\'s offering his hand to fight with the crew, according to old traditions. He\'s also offering his head if you want that, too, and he seems totally unafraid of giving it up.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We\'ll leave no one alive.",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-1);
						return "Survivor2";
					}

				},
				{
					Text = "Let him go.",
					function getResult()
					{
						this.World.Assets.addMoralReputation(2);
						return "Survivor3";
					}

				}
			],
			function start()
			{
				if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
				{
					this.Options.push({
						Text = "We could need a man like this.",
						function getResult()
						{
							return "Survivor4";
						}

					});
				}
			}

		});
		this.m.Screens.push({
			ID = "Survivor2",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{You unsheathe your sword and lower the blade toward the man, the corpses in the tent blurring along its metal curvature, and the surviving barbarian\'s face blobbing at the tip. He grins and grips the edges, sheathing it in his huge hands. Blood drips steadily from his palms.%SPEECH_ON%Death, killing, no dishonor. For us both. Yes?%SPEECH_OFF%Nodding, you push the blade into his chest and sink him back to the floor. The weight of him on the sword is like a stone and when you unstick him the corpse claps back against the pile of corpses. Sheathing the sword, you tell the crew to round up what goods they can and to ready a return to %employer%.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Time to get paid.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Survivor3",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{You unsheathe your blade halfway, hold it long enough that the wounded man sees it, then you slam it back into the scabbard. Nodding, you ask.%SPEECH_ON%Understand?%SPEECH_OFF%The warrior stands up, briefly slumping against the tent\'s post. You turn and hold your hand out to the tent flap. He nods.%SPEECH_ON%Aye, I know.%SPEECH_OFF%He stumbles out and into the light and away into the northern wastes, his shape tottering side to side, shrinking, and is then gone. You tell the crew to get ready to return to %employer% for some well-earned reward.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Time to get paid.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Survivor4",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{You stare at the man, then take out your dagger and slice the inside of your palm. Squeezing the blood, you toss the dagger to the barbarian and then hold your hand out, the blood dripping steadily. The warrior takes the blade and cuts himself in turn. He stands and puts his hand out and you shake. He nods.%SPEECH_ON%Honor, always. With you, the only way, all the way.%SPEECH_OFF%The man stumbles out of the tent. You tell the men to not kill him, but instead to arm him which raises some eyebrows. His addition to the crew is unforeseen, but useful. The other men will get used to it in time, but for now the %companyname% needs to return to %employer%.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Welcome to the %companyname%.",
					function getResult()
					{
						this.World.getPlayerRoster().add(this.Contract.m.Dude);
						this.World.getTemporaryRoster().clear();
						this.Contract.m.Dude.worsenMood(1.0, "Has seen his village being slaughtered");
						this.Contract.m.Dude.onHired();
						this.Contract.m.Dude = null;
						return 0;
					}

				}
			],
			function start()
			{
				local roster = this.World.getTemporaryRoster();
				this.Contract.m.Dude = roster.create("scripts/entity/tactical/player");
				this.Contract.m.Dude.setStartValuesEx([
					"barbarian_background"
				]);

				if (this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
				{
					this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand).removeSelf();
				}

				if (this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
				{
					this.Contract.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand).removeSelf();
				}

				this.Characters.push(this.Contract.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Revenge1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_135.png[/img]{A man stands out into your path. He\'s an elder among northmen.%SPEECH_ON%Ah, the fellow northmen. You come to our home and ravage an undefended village.%SPEECH_OFF%You spit and nod. %randombrother% yells out that it\'s what the they themselves do. The old man smiles.%SPEECH_ON%So we are in cycle, and through this violence we all shall regenerate, but violence there shall be. When we are through with you, %townname% will not be spared.%SPEECH_OFF%A line of strongmen get up out of the terrain where they were hiding. By the looks of it, this is the main war party of the village you burned down. They may have been out raiding when you sacked the place. Now here they are seeking retribution.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult()
					{
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Revenge";
						properties.Music = this.Const.Music.BarbarianTracks;
						properties.EnemyBanners.push(this.Flags.get("EnemyBanner"));
						properties.Entities = [];
						this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Barbarians, 110 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID());
						properties.TemporaryEnemies = [
							this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID()
						];
						this.World.Contracts.startScriptedCombat(properties, false, true, false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Revenge2",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{The savages are driven from %townname%. Despite the results, it takes time for the clanfolk to emerge and see your victory in full. %employer% eventually comes out clapping and hollering. %SPEECH_ON%Well done, warrior, well done! The old gods will surely reward you for this!%SPEECH_OFF%You sheathe your sword and point out old gods will not buy your men food and drinks, nor provide you with weapons. Your employer smiles and nods.%SPEECH_ON%Of course, of course, warrior. I understand you well. You shall be paid in full and then some! All well-earned, truly!%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "A hard day\'s work.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion() * 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "You destroyed a barbarian encampment that threatened " + this.Contract.m.Home.getName());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "You saved " + this.Contract.m.Home.getName() + " from barbarian revenge");
						this.World.Contracts.finishActiveContract();
						return 0;
					}

				}
			],
			function start()
			{
				this.Contract.m.Reward = this.Contract.m.Payment.getOnCompletion() * 2;
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Reward + "[/color] Crowns"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
		this.m.Screens.push({
			ID = "Revenge3",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_94.png[/img]{You\'re run off the field of battle and retreat to a safe enough spot to watch the ruination of %townname%. The savages dip into homes and start raping and murdering of both men and women. Children are collected up and heaved into cages made of bone and hide where the elder gently hands them sliced apples and cups of camphor. You watch as the raiders set upon %employer%\'s home, a few guards step forward, but they\'re cut down almost immediately. One man is laid out upon the ground and is stripped and kicked toward a pair of dogs who tear at him from every which way and he survives and uncomfortably long time. \n\n Finally, %employer% is dragged out of his home. The barbarian leader stares down at him, nods, then grabs him by the neck with one hand and covers his face with the other. In this suspension the man is suffocated. The corpse is then thrown to the warband who have it stripped, desecrated, and then impaled from anus to mouth and lifted high up in the center of the camp. Once the pillaging is done, the raiders take what they want and depart. The last you see of them is a dog trotting with a human ribcage in its maw. %randombrother% comes to your side.%SPEECH_ON%Well. I don\'t think we\'re getting paid, chief.%SPEECH_OFF%No. You suspect not.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "All is lost.",
					function getResult()
					{
						this.World.FactionManager.getFaction(this.Contract.getFaction()).getRoster().remove(this.Tactical.getEntityByID(this.Contract.m.EmployerID));
						this.Contract.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/raided_situation"), 4);
						this.Contract.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/conquered_situation"), 4);
						this.Contract.m.Home.setLastSpawnTimeToNow();
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail * 2);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail * 2, "You failed to save " + this.Contract.m.Home.getName() + " from barbarians out for revenge");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "Near %townname%...",
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer% welcomes your entrance with applause.%SPEECH_ON%My scouts tracked your crew to the north and to its, dare I say, inevitable success! Splendid work murdering those bastards. Surely this will make them think twice about coming here again!%SPEECH_OFF%The man pays you what you\'re owed. | You have a hard time finding %employer%, eventually finding him on the roof of one of the jurts, plugging a hole with wooden planks. He shouts up to you.%SPEECH_ON%Ah, my warrior. Let me come down!%SPEECH_OFF%He climbs down from in one smooth motion, as if he\'s been doing it his whole life.%SPEECH_ON%We\'ve lost some good men and repairs and rebuilding is going slowly, so I thought I\'d lend a hand myself. Nothing like a little dirty work to get a good man up in the morn\'.%SPEECH_OFF%He slaps your chest with his hand. He nods and fetches one of the men to go get your pay.%SPEECH_ON%A job well done, warrior. Very, very well done.%SPEECH_OFF% | You find %employer% attending a funeral ceremony. They\'re burning a pyre weighed with three corpses and what may possibly be a fourth, smaller one. Possibly a whole family. %employer% says a few kind words and then sets the woodwork ablaze. One of the men surprises you with a chest of crowns.%SPEECH_ON%%employer% does not wish to be bothered. Here is your pay, warrior. Please count if you do not trust it is all there.%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Gold well deserved.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "You stopped the barbarian raids against " + this.Contract.m.Home.getName());
						this.World.Contracts.finishActiveContract();
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
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
		
		
		this.m.Screens.push({
			ID = "Success2",
			Title = "Near %townname%...",
			Text = "[img]gfx/ui/events/event_04.png[/img]{As you return to your %employer%, you can sense his displeasure palpably hanging in the air.%SPEECH_ON%You know, my scouts have tracked you to the raider's camp and they report that the raiders are still alive and well. They also tell me there was no battle. So why are you back?%SPEECH_OFF%You explain that their chieftain was killed in single combat and the terms of the duel are clear. There will be no more raiding against %townname%, at least for the time being. A glimmer of relief appears on %employer%\'s face, yet his voice remains stern.%SPEECH_ON%I didn\'t hire you to fight duels, but kill every last one of them. But if the matter is settled, at least that is something. You\'ll still get paid but only half.%SPEECH_OFF% }",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "It is what it is...",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Reward);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "You destroyed a barbarian encampment that threatened " + this.Contract.m.Home.getName());
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
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"reward",
			this.m.Reward
		]);
		_vars.push([
			"original_reward",
			this.m.OriginalReward
		]);

		
		_vars.push([
			"enemychieftain",
			this.m.Flags.get("EnemyChieftain")
		]);
		
		_vars.push([
			"champbrother",
			this.m.Flags.get("ChampionBrotherName")
		]);
		_vars.push([
			"direction",
			this.m.Destination == null || this.m.Destination.isNull() || !this.m.Destination.isAlive() ? "" : this.Const.Strings.Direction8[this.m.Home.getTile().getDirection8To(this.m.Destination.getTile())]
		]);
		
		_vars.push([
			"randombarbarian"
			this.Const.Strings.BarbarianNames[this.Math.rand(0, this.Const.Strings.BarbarianNames.len() - 1)]
		]);
	}

	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/raided_situation"));
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Destination != null && !this.m.Destination.isNull() && !this.m.Destination.isAlive())
			{
				this.m.Destination.getSprite("selection").Visible = false;
				::NorthMod.Utils.setIsHostile(this.m.Destination, false);
				this.m.Destination.setOnCombatWithPlayerCallback(null);
			}

			this.m.Home.getSprite("selection").Visible = false;
		}

		if (this.m.Home != null && !this.m.Home.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Home.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(4);
			}
		}
	}
	
	function onCancel()
	{
		::NorthMod.Utils.setIsHostile(this.m.Destination, false);
	}

	function onIsValid()
	{
		if (this.m.IsStarted)
		{
			if (this.m.Destination == null || this.m.Destination.isNull() || !this.m.Destination.isAlive())
			{
				return false;
			}

			return true;
		}
		else
		{
			return true;
		}
	}
	
	function resetChampionDuels()
	{
		local roster = this.World.getPlayerRoster().getAll();
		foreach( bro in roster )
		{
			if (bro.getFlags().has("NEM_duels_won"))
			{
				bro.getFlags().remove("NEM_duels_won");
			}
			
		}
	}

	function onSerialize( _out )
	{
		_out.writeI32(0);

		if (this.m.Destination != null && !this.m.Destination.isNull())
		{
			_out.writeU32(this.m.Destination.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		_in.readI32();
		local destination = _in.readU32();

		if (destination != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(destination));
		}

		this.contract.onDeserialize(_in);
	}

});

