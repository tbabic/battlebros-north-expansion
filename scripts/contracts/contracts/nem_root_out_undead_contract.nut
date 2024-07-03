this.nem_root_out_undead_contract <- this.inherit("scripts/contracts/barbarian_contract", {
	m = {
		Objective1 = null,
		Objective2 = null,
		Target = null,
		Current = null,
		IsPlayerAttacking = false
	},
	function create()
	{
		this.contract.create();
		local r = this.Math.rand(1, 100);

		if (r <= 70)
		{
			this.m.DifficultyMult = this.Math.rand(95, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(115, 135) * 0.01;
		}

		this.m.Type = "contract.nem_root_out_undead";
		this.m.Name = "Root Out The Undead";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}
	
	function start()
	{
		if (this.m.Origin == null)
		{
			this.setOrigin(this.World.State.getCurrentTown());
		}

		local nearest_undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getNearestSettlement(this.m.Origin.getTile());
		local nearest_zombies = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getNearestSettlement(this.m.Origin.getTile());

		if (this.Math.rand(1, 100) <= 50)
		{
			this.m.Objective1 = this.WeakTableRef(nearest_undead);
			this.m.Objective2 = this.WeakTableRef(nearest_zombies);
		}
		else
		{
			this.m.Objective2 = this.WeakTableRef(nearest_undead);
			this.m.Objective1 = this.WeakTableRef(nearest_zombies);
		}

		this.m.Flags.set("Objective1Name", this.m.Objective1.getName());
		this.m.Flags.set("Objective2Name", this.m.Objective2.getName());
		this.m.Payment.Pool = 1500 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
		local r = this.Math.rand(1, 2);

		if (r == 1)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else if (r == 2)
		{
			this.m.Payment.Completion = 1.0;
		}

		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Destroy %objective1%",
					"Destroy %objective2%",
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
				this.Contract.m.Objective1.setLootScaleBasedOnResources(120 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				this.Contract.m.Objective1.setResources(120 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				this.Contract.m.Objective1.clearTroops();
				this.Contract.addUnitsToEntity(this.Contract.m.Objective1, this.Contract.m.Objective1.getDefenderSpawnList(), 120 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				this.Contract.m.Objective1.setDiscovered(true);

				if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Objective1.getFlags().get("IsEventLocation"))
				{
					this.Contract.m.Objective1.getLoot().clear();
				}

				this.World.uncoverFogOfWar(this.Contract.m.Objective1.getTile().Pos, 500.0);
				this.Contract.m.Objective2.setLootScaleBasedOnResources(120 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				this.Contract.m.Objective2.setResources(120 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				this.Contract.m.Objective2.clearTroops();
				this.Contract.addUnitsToEntity(this.Contract.m.Objective2, this.Contract.m.Objective2.getDefenderSpawnList(), 120 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				this.Contract.m.Objective2.setDiscovered(true);

				if (this.Contract.getDifficultyMult() <= 1.15 && !this.Contract.m.Objective2.getFlags().get("IsEventLocation"))
				{
					this.Contract.m.Objective2.getLoot().clear();
				}

				this.World.uncoverFogOfWar(this.Contract.m.Objective2.getTile().Pos, 500.0);
				local r = this.Math.rand(1, 100);

				if (r <= 10)
				{
					this.Flags.set("IsNecromancers", true);
				}
				else if (r <= 25)
				{
					this.Flags.set("IsBandits", true);
				}

				this.Flags.set("ObjectivesDestroyed", 0);
				this.Flags.set("Objective1ID", this.Contract.m.Objective1.getID());
				this.Flags.set("Objective2ID", this.Contract.m.Objective2.getID());
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [];

				if (this.Contract.m.Target != null && !this.Contract.m.Target.isNull() && this.Contract.m.Target.isAlive())
				{
					this.Contract.m.Target.getSprite("selection").Visible = true;
					this.Contract.m.BulletpointsObjectives.push("Kill the fleeing necromancers");
				}

				if (this.Contract.m.Objective1 != null && !this.Contract.m.Objective1.isNull() && this.Contract.m.Objective1.isAlive())
				{
					this.Contract.m.Objective1.getSprite("selection").Visible = true;
					this.Contract.m.BulletpointsObjectives.push("Destroy %objective1%");
					this.Contract.m.Objective1.setOnCombatWithPlayerCallback(this.onCombatWithPlayer.bindenv(this));
				}

				if (this.Contract.m.Objective2 != null && !this.Contract.m.Objective2.isNull() && this.Contract.m.Objective2.isAlive())
				{
					this.Contract.m.Objective2.getSprite("selection").Visible = true;
					this.Contract.m.BulletpointsObjectives.push("Destroy %objective2%");
					this.Contract.m.Objective2.setOnCombatWithPlayerCallback(this.onCombatWithPlayer.bindenv(this));
				}
			}

			function update()
			{
				if (this.Flags.get("ObjectiveDestroyed"))
				{
					this.Flags.set("ObjectiveDestroyed", false);

					if (this.Flags.get("IsBanditsCoop"))
					{
						this.Contract.setScreen("BanditsAftermathCoop");
					}
					else if (this.Flags.get("IsBandits3Way"))
					{
						this.Contract.setScreen("BanditsAftermath3Way");
					}
					else if (this.Flags.get("ObjectivesDestroyed") == 1)
					{
						this.Contract.setScreen("Aftermath1");
					}
					else
					{
						this.Contract.setScreen("Aftermath2");
					}

					this.World.Contracts.showActiveContract();
				}

				if (this.Flags.get("IsNecromancersSpawned"))
				{
					if (this.Contract.m.Target == null || this.Contract.m.Target.isNull())
					{
						this.Contract.setScreen("NecromancersAftermath");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Contract.m.Target.getTile().getDistanceTo(this.World.State.getPlayer().getTile()) >= 9)
					{
						this.Contract.setScreen("NecromancersFail");
						this.World.Contracts.showActiveContract();
					}
				}

				if (!this.Flags.get("IsBandits") || this.Flags.get("ObjectivesDestroyed") != 0)
				{
					if (this.Contract.m.Objective1 != null && !this.Contract.m.Objective1.isNull() && !this.Contract.m.Objective1.getFlags().has("TriggeredContractDialog") && this.Contract.isPlayerNear(this.Contract.m.Objective1, 450))
					{
						this.Contract.m.Objective1.getFlags().add("TriggeredContractDialog");
						this.Contract.setScreen("UndeadRepository");
						this.World.Contracts.showActiveContract();
					}
					else if (this.Contract.m.Objective2 != null && !this.Contract.m.Objective2.isNull() && !this.Contract.m.Objective2.getFlags().has("TriggeredContractDialog") && this.Contract.isPlayerNear(this.Contract.m.Objective2, 450))
					{
						this.Contract.m.Objective2.getFlags().add("TriggeredContractDialog");

						if (this.Flags.get("IsNecromancers"))
						{
							this.Flags.set("IsNecromancersSpawned", true);
							this.Contract.setScreen("Necromancers");
							this.World.Contracts.showActiveContract();
						}
						else
						{
							this.Contract.setScreen("UndeadRepository");
							this.World.Contracts.showActiveContract();
						}
					}
				}
			}

			function onCombatWithPlayer( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
				this.Contract.m.Current = _dest;

				if (_dest != null && !_dest.getFlags().has("TriggeredContractDialog") && this.Flags.get("IsBandits") && this.Flags.get("ObjectivesDestroyed") == 0)
				{
					_dest.getFlags().add("TriggeredContractDialog");
					this.Contract.setScreen("Bandits");
					this.World.Contracts.showActiveContract();
				}
				else
				{
					_dest.m.IsShowingDefenders = true;
					local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					p.EnemyBanners.push(_dest.getBanner());

					if (this.Flags.get("IsBandits") && this.Flags.get("ObjectivesDestroyed") == 0)
					{
						if (this.Flags.get("IsBanditsCoop"))
						{
							p.AllyBanners.push("banner_bandits_06");
							this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.BanditRaiders, 90 * this.Contract.getScaledDifficultyMult(), this.Const.Faction.PlayerAnimals);
						}
						else
						{
							p.EnemyBanners.push("banner_bandits_06");
							this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.BanditRaiders, 90 * this.Contract.getScaledDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getID());
						}
					}

					this.World.Contracts.startScriptedCombat(p, this.Contract.m.IsPlayerAttacking, true, true);
				}
			}

			function onLocationDestroyed( _location )
			{
				if (_location.getID() == this.Flags.get("Objective1ID"))
				{
					this.Contract.m.Objective1 = null;
					this.Flags.set("ObjectiveDestroyed", true);
					this.Flags.set("ObjectivesDestroyed", this.Flags.get("ObjectivesDestroyed") + 1);
				}
				else if (_location.getID() == this.Flags.get("Objective2ID"))
				{
					this.Contract.m.Objective2 = null;
					this.Flags.set("ObjectiveDestroyed", true);
					this.Flags.set("ObjectivesDestroyed", this.Flags.get("ObjectivesDestroyed") + 1);
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
		this.importScreens(::NorthMod.Const.Contracts.NegotiationDefault);
		this.importScreens(::NorthMod.Const.Contracts.Overview);
		this.m.Screens.push({
			ID = "Task",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_45.png[/img]{You step into %employer%\'s room. His warriors are red-faced, the crimson bookend of an argument gone south. The chieftain waves you in.%SPEECH_ON%Ah, a man I\'d actually like to farkin\' speak to. Men, make a path.%SPEECH_OFF%Being scornfully eyed, you step through the sea of haughty warriors. %employer% slaps a map into your chest. There are two locations highlighted with circles and crudely drawn skulls and crossbones.%SPEECH_ON%Go to both, warrior. \'%objective1%\' and \'%objective2%\'.The elders believe that these are critical to the waves of undead. My warriors disagree, but why not have a look? Now if you see any of those scary shits, kill them, destroy whatever goddam holes they\'re crawling out of, and return to me with the brilliant news of your heroics. Sound like a deal?%SPEECH_OFF% | %employer% is standing with a road-worn scout at his side. The pathfinder is eating his fill of food and drink, replenishing whatever he lost sprinting across the lands. %employer% presents you a crudely drawn map.%SPEECH_ON%\'%objective1%\' and \'%objective2%\'. We, well, my scout here, believes that these are repositories for the undead, no doubt aptly named. From these spots spawn all manner of unholies. Go to them, destroy all that you see, and come back. You\'ll be a hero.%SPEECH_OFF%You shrug.%SPEECH_ON%The %companyname% prefers crowns to accolades.%SPEECH_OFF% | %employer% welcomes you with a map.%SPEECH_ON%\'%objective1%\' and \'%objective2%\', recognize those places? No, of course not. But I want you to go to each, root out what evil lies in them, and come back. Short and simple jaunt into the repositories of the dead, right?%SPEECH_OFF%Right. What could possibly go wrong? | %employer% asks if you fear the undead. You shrug and respond.%SPEECH_ON%I fear dying with regret that I did not do all that I wanted to do. That\'s about all I fear. That and horses.%SPEECH_OFF%The chieftain laughs.%SPEECH_ON%Well, alright then. Here\'s a map. You\'ll see marked \'%objective1%\' and \'%objective2%\'. My scouts believe they are havens for the undead. Makes sense as that is where we put our dead in the first place. Go to both, destroy them, and head on back for your pay. Simple enough, yeah?%SPEECH_OFF% | %employer% greets you at his door with a map in hand.%SPEECH_ON%\'%objective1%\' and \'%objective2%\', marked clearly, see? Of course you do. Well my scouts say great evils are pouring out of both. If that\'s true, then I need a man of fearless, killing stature to go to both and destroy all that is there. I believe you are such a man. Are you?%SPEECH_OFF% | %employer% welcomes you into his room with an odd question.%SPEECH_ON%Ever been to a graveyard, warrior?%SPEECH_OFF%Before you answer, the man pours himself a drink and takes a swig, holding the other hand out to keep you silent.%SPEECH_ON%They\'re curious things. Unnatural, really. What sort of creature takes its dead and goes out to some land, a good piece of land no less, and buries them there? How gaudy. How inconsequential. Is it any surprise, then, that the dead come back? Perhaps they\'re haunting us for breaking the natural order.%SPEECH_OFF%The man tosses you a crude map. Two spots are marked.%SPEECH_ON%\'%objective1%\' and \'%objective2%\'. I need you to go to both, destroy them, and come on back. Simple enough for a man of your skill, right?%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{What\'s the pay? | What interests me is the payment.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{This isn\'t worth it. | We\'re needed elsewhere.}",
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
			ID = "UndeadRepository",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_57.png[/img]{A familiar stench begins to waft over the company. %randombrother% remarks that they must be getting close to the repository. You remark that he is a goddam genius and should be making inventions and discoveries for the betterment of mankind. You can practically hear his silence over the laughter of the company. | As you near your objective, it becomes increasingly obvious that %employer%\'s assessments of the area were correct. The stench is undeniable: whatever dead were in this area have returned to roam the lands. | You find a corpse tangled in a bush, its branch-strung hands repeatedly pedaling outward with a sort of deadly indifference. %randombrother% steps close, carefully keeping his distance, and puts a blade through its skull. He steps back, cleaning his weapon and remarks that the company must be getting close to what you came to destroy. | Judging by the overbearing smell of ripened bodies and the belching gasses they produce, it\'s of little doubt that this %objective% is near. | You find half a man crawling across the ground. It stares up at you, groaning mindlessly, indifferent to its newfound existence though yet yearning to end yours. With a boot, you push its head into the mud. Its growls become gurgles and you carefully put a dagger through its earhole. %randombrother% looks around.%SPEECH_ON%This %objective% shan\'t be too far off now.%SPEECH_OFF% | Your destination is barely in view yet, but its smells are hitting the nose with a ferocity you hope is not reflected by whatever dwells there. You should prepare the men for the upcoming battle. | %randombrother% points off the path to a bunch of corpses strewn there in what appears to be a series of most acrobatic deaths. You\'ve no idea what happened, but the bodies have been long dead and yet there\'s no sign of flies or other animals having set upon them. You inform the men that your destination is close and that they should ready themselves for a coming fight. | The company stumbles upon a shambling corpse with shackled hands and legs. Imprisonment in life did not end upon reanimation and so you do what an executioner should have however long ago and remove the wiederganger\'s head. %randombrother% asks if your destination is close and you nod. It surely is, and with it will come a battle which the %companyname% would best prepare for. | Your destination mustn\'t be far off if the horrid smell wafting over the company is anything to go by. Whether it is the walking dead or a man with most pernicious bowel movements, the %companyname% should prepare for a fight. | The walking dead greet you one by one, a series of easily dispatched breadcrumbs leading the %companyname% straight to its target. You should prepare for a fight because soon you\'ll have the whole loaf on your plate. | An old man greets the company and states that %objective% is not far off. You ask what the hell he\'s still doing around then. He shrugs.%SPEECH_ON%Being old, what else?%SPEECH_OFF% | %randombrother% sniffs the air.%SPEECH_ON%I know %randombrother2%\'s farting arse and that ain\'t him.%SPEECH_OFF%The insulted warrior shrugs.%SPEECH_ON%Not for a lack of tryin\', but yeah, I think yer right. We gotta be getting close to this %objective%.%SPEECH_OFF%You nod and tell the men to prepare for a coming battle. | You find an earthworn corpse with abyssal eye sockets flailing around a big rock. It shuffles about scraping the stone with an earnest effort to kill it. %randombrother% decapitates the wiederganger with a swipe of his blade, like a man slicing through a totem of butter. He nods toward the distance.%SPEECH_ON%%objective% is close.%SPEECH_OFF%If so, the %companyname% should prepare for battle.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Prepare for the worst!",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Aftermath1",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_46.png[/img]{The evil in the place has been extinguished. You take a breath that feels like the first in years, as though the air itself had warmed to your victory. Only the so-called %objective2% remains now. | As the last of the undead are put to rest, you get a sense that the air is clearing up, like a fog of smoky air giving way to crisp, springtime aromas. The quick change in scents no doubt means you\'ve cleaned whatever evil dwelled there. Now to cleanse %objective2% and be done with this contract. | The evil of the place has been put to rest. Your next target awaits. | With the horrid place cleansed of evil, only %objective2% remains on the contract. | As the last wiederganger is put to rest, you feel a sudden change in the air. Cleanliness punches your lungs with unexpected clarity as you stand in a world of muck and mire. %randombrother% wipes his brow.%SPEECH_ON%Must be the end of it. On our way to %objective2% then?%SPEECH_OFF% | You entered a domain of evil, but with the last wiederganger slain you see the light of the world brighten and the smell of the earth beneath your feet returns to the natural order. With this place laid to rest, it\'s time to go on to %objective2%. | The victory was hard fought. Wiedergangers and the oddities of more ancient undead litter the field. You hope %objective2% will be easier to sort out, but you doubt it. | You step over the corpse of an ancient deadman. It\'s so different from yourself that it may as well be alien to all life you know of. The skull is ill-shaped, like a shrunken precursor to your own, and the armor and weapons appear out of this world.\n\n You prepare the men for the journey to %objective2%. | The earth is strewn with the ruinous corpses of the undead. You step over their bodies to find the ground beneath you returning to health, as if the soil was turning over from hiding, and the air itself is easier to breathe. Perhaps the evil truly has left the place? Regardless, it is time to go on to %objective2% and give it the friendly %companyname% treatment. | With the last of the undead slain, you look about the field. The dead are not of one source, judging by their variety of clothes and armors, but they are not of one timeline either. Some wear the armors of ancients and carry with them disturbing uniformity in their effort to kill.\n\n %randombrother% comes by, stating that the company is ready to move onto this %objective2% whenever you are.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{Victory! | And stay dead!}",
					function getResult()
					{
						this.Contract.getActiveState().start();
						this.World.Contracts.updateActiveContract();
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Aftermath2",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_46.png[/img]{%objective2% is in ruins, though from your perspective it\'s looking better than ever. It\'s probably best to head on back to %employer% now and get your reward. | You gave %objective2% a righteous corrective measure, swinging it out of the grips of the undead and back into the world of the living. Already, you see the grass and trees grow livelier, and a breeze comes with refreshing briskness. %employer% would be best told of these doings so you can go on and get your payday. | The darkness that resided within %objective2% has been destroyed. Well, except for those pockets of existence beneath the rubble. Still got a little bit of darkness there, but that\'s more because of the lack of light than the presence of evil. Either way, you should go and tell %employer% of what you\'ve done. | %objective2% looks a lot better with the %companyname% standing victoriously over its ruins. The way you see it, a painter should go and do a little getup of your achievement. %randombrother% looks especially good crushing wiederganger skulls with his boots. Getting paid by %employer%, however, would look even better. Probably best to get back to him. | %objective2% is destroyed and with it the evil has departed these lands. Hopefully it is gone for good, but there\'s a good chance it has simply gone to another place of weakness. Speaking of which, you\'d best get back to %employer% for your pay. | %objective2% has been laid flat and all the evil that inhabited it has gone. The air is lighter, more fresh. %employer% should be happy to see you and the results you\'ve to report. | The %companyname% stands victorious, the evils of %objective2% laid to rest, or perhaps driven out to inhabit some other place. A cynical part of you hope it\'s the latter, because in that case some other nobleman will want you to root it out and you\'ll earn yourself another payday. As thoughts of an evil-driving circle-scam fill your head, %randombrother% comes up and asks if it\'s time to return to %employer%. You nod. One step at a time. | %objective2% and all its grim, cruel inhabitants have been put to the blade. It\'s strange seeing a battlefield littered with dead that range from the freshness of a wiederganger\'s corpse, to the dusty armor shell of an ancient. The corpses carry more diversity than an antique shop.\n\n Once the company has its fill of loot, it should get on back to %employer% for your pay. | Dead wiedergangers and ancients are strewn across the ground. Dead-undead, a strange verbiage to account for the slaying of evil beyond your measure. But slain they are, proving that the monsters can be stopped. You ready the company to make a return to %employer% for a right proper payday. | %objective2% is destroyed, proving that even the reanimated dead cannot avoid the thorough destruction the %companyname% brings to the battlefield. With the evil cleared out, you get a sense of civility and nature returning to the place. The air hits your nose with welcomed briskness. Overhead, birds are zipping across the sky. Little ones, too, not just buzzards looking for a meal.\n\n You tell the company to loot what they can and get ready for a return to %employer%.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "{Victory! | Time to head back to %townname%.}",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Necromancers",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_76.png[/img]{You spot some necromancers in the distance. No doubt these men are responsible for much of the evil plaguing these lands. You can\'t let them escape! | %randombrother% comes to your side with sweat running down his face.%SPEECH_ON%Sir, we\'ve spotted some men of ill-intent running yonder.%SPEECH_OFF%Taking up a scope you see, running along the horizon like ants scuttling atop their mound, are a couple of grey-garbed men with a haze of disease lingering behind them. You clap the warrior on the shoulder.%SPEECH_ON%Good eye. Now go and tell the men that we got some necromancers to hunt down.%SPEECH_OFF% | You take up a scope and glass the surrounding lands. Surprisingly, there are a handful of figures running yonder, and they keep looking back as if you\'re in chase. You stretch the scope and get a better look at the figures. Dark garbs, pale faces, white beards, daggers with cult like carvings... necromancers! They need to be caught and killed to truly rid this land of evil. | %randombrother% reports that a couple of odd men have been spotted running away from the %companyname%. You shrug and tell him it\'s quite normal to flee from a warband. He nods, then adds.%SPEECH_ON%Right, of course, but these are greyed men with black cloaks and I\'m pretty sure they had a couple of rather dead looking corpses walking alongside them.%SPEECH_OFF%That\'s the description of a necromancer if there ever was one. The company should chase them down before they escape! | While looking over the maps, %randombrother% comes to give a scouting report.%SPEECH_ON%We got a couple of necromancers, sir. Old men, strange weapons, glowy eyes, a couple of corpses for friends, the works.%SPEECH_OFF%If these are truly necromancers, they\'re most likely responsible for a lot of the evil in these lands and should be rooted out as fast as possible. | Necromancers! Crooning, slinking men traipsing the land under the cover of corpses and other \'friendlies\' which stand in their company. They should be hunted down immediately! | Necromancers! Practitioners of dark arts, these men are no doubt partly responsible for the evils that are infecting these lands. They should be hunted down and killed! | %randombrother% hands you a scope. Looking through it, you quickly confirm his report: there are necromancers yonder, hurrying through a nearby valley and no doubt trying to elude the %companyname%. You collapse the scope and tell the warrior to ready the men. These necromancers must be hunted down and killed as soon as possible!}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "After them!",
					function getResult()
					{
						local tile = this.Contract.m.Objective2.getTile();
						local banner = this.Contract.m.Objective2.getBanner();
						this.Contract.m.Objective2.die();
						this.Contract.m.Objective2 = null;
						local playerTile = this.World.State.getPlayer().getTile();
						local camp = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getNearestSettlement(playerTile);
						local party = this.World.FactionManager.getFaction(camp.getFaction()).spawnEntity(tile, "Necromancers", false, this.Const.World.Spawn.UndeadScourge, 100 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
						party.getSprite("banner").setBrush(banner);
						party.setFootprintType(this.Const.World.FootprintsType.Undead);
						party.getSprite("body").setBrush("figure_necromancer_01");
						party.setSlowerAtNight(false);
						party.setUsingGlobalVision(false);
						party.setLooting(false);
						this.Const.World.Common.addTroop(party, {
							Type = this.Const.World.Spawn.Troops.Necromancer
						}, false);
						this.Const.World.Common.addTroop(party, {
							Type = this.Const.World.Spawn.Troops.Necromancer
						}, true);
						this.Contract.m.UnitsSpawned.push(party);
						this.Contract.m.Target = this.WeakTableRef(party);
						party.setAttackableByAI(true);
						party.setFootprintSizeOverride(0.75);
						local c = party.getController();
						c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
						local roam = this.new("scripts/ai/world/orders/roam_order");
						roam.setPivot(camp);
						roam.setMinRange(1);
						roam.setMaxRange(10);
						roam.setAllTerrainAvailable();
						roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
						roam.setTerrain(this.Const.World.TerrainType.Shore, false);
						roam.setTerrain(this.Const.World.TerrainType.Mountains, false);
						c.addOrder(roam);
						this.Contract.getActiveState().start();
						this.World.Contracts.updateActiveContract();
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "NecromancersFail",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_36.png[/img]{The necromancers\' trail has died. If only there was some force in this world to revive it. | You failed to catch up to the necromancers. You\'ve no idea where they\'ve gone, but there\'s little doubt they\'re taking they\'ve taken their evil with them. | How? How did you let the necromancers get away? Now they\'re free to run amok, spreading their evils wherever they go.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "No, no, no!",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to destroy strongholds of the undead scourge");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "NecromancersAftermath",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_46.png[/img]{The necromancers have been destroyed. Whatever evil they had in their hearts has been, by the blade, laid bare. They shan\'t haunt these lands any longer. | The necromancers lay dead, finally joining the corpses from which they so irresponsibly recruited their armies. | You stare down at a necromancer, getting a good look at the man who would so cruelly raise the dead to fight on their behalf. His mouth is still ill-shaped, as though ready to tongue forth yet another evil incantation. Thankfully, all that is over. Because cruel or not, he is but a man. | You look down at a necromancer\'s gaunt, ghoulish face. %randombrother% comes up and spits, landing a hefty goober right on the corpse\'s cheek.%SPEECH_ON%To hell wit\'em, they don\'t spook me.%SPEECH_OFF%You nod. As the spit runs down the necromancer\'s face, you see its eyes briefly glow red. You figure it\'s best to not tell your warrior about it. | The necromancers have been slain, though the light in their eyes is disturbingly slow to depart. %randombrother% still seems rather proud about the battle.%SPEECH_ON%Look at them. All dead and shite.%SPEECH_OFF%He bends forward, hands on his knees, shouting in the face of a corpse like it was a deaf man.%SPEECH_ON%Where\'s your dead friends now? Hmm? Oh that\'s right, yer a right dead fellow now! What a shame!%SPEECH_OFF%You tell the man to ease up lest these dark magicians have powers beyond the grave. | The foul men have been slain. Unsurprisingly, a dead necromancer looks a lot like a regular necro man. | The necromancers have been laid low and what ill governance they had over these lands has been put to rest. No doubt you\'ve done a good job of destroying much of the evil that plagues these lands.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "One less thing to worry about.",
					function getResult()
					{
						this.Flags.set("IsNecromancers", false);
						this.Flags.set("IsNecromancersSpawned", false);
						this.Flags.set("ObjectivesDestroyed", this.Flags.get("ObjectivesDestroyed") + 1);
						this.Contract.m.Target = null;

						if (this.Flags.get("ObjectivesDestroyed") == 2)
						{
							this.Contract.setState("Return");
						}
						else
						{
							this.Contract.getActiveState().start();
							this.World.Contracts.updateActiveContract();
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Bandits",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_07.png[/img]{While heading toward %objective%, you come across a group of brigands. They turn-face and draw their weapons, and the %companyname% does theirs. You hold your hand out, the leader of the vagabonds doing the same, cutting a bit of tension between the two parties. The leader speaks.%SPEECH_ON%The loot is ours, we were here first and, if you dare fight us for it, we\'ll be here last, too!%SPEECH_OFF%It looks like they just want to pillage the place. Doing so would require a lot of wiederganger killing which would definitely help. Perhaps you could join forces? Whatever you choose, do so fast, for the undead are here! | A group of brigands is readying to attack %objective%! They pull out their weapons and threaten to attack, but you parlay for a time, figuring out that they just want to loot and pillage the repository. Perhaps the %companyname% could join forces with them? Or hell, just kill them all, undead and brigands, and take everything for yourselves. | As you near %objective%, you come across a group of brigands. They\'re preparing to attack - not the %companyname%, but the repository itself. It appears they\'re just after whatever loot might be there and will fight you over it. Perhaps you could join them, at the cost of any potential loot, or just go ahead and slaughter anything that moves and take the gold and glory for yourself. Choose quickly, though, because the undead are here! | Brigands! A group of them, well-armed and ready to attack. Thankfully, they\'re looking to attack %objective% itself. Perhaps the %companyname% could join them, but no doubt the vagabonds will be wanting a large slice of the loot there is to find. The other option is to just kill everything and take the loot for yourself. Best choose quickly, though, for the undead are here! | You come across a couple of well-armed men. They quickly turn to face you, weapons drawn. %randombrother% pulls out a blade and threatens to kill the first man who moves. Despite the considerable tension, you and the leader of the vagabonds manage to settle things down and talk. He explains that they are there to pillage %objective% and take all its loot. You could pair up with the thieves or, if you want all the loot for yourself, just kill them and the wiedergangers altogether.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We share a common goal. Let\'s attack, together!",
					function getResult()
					{
						this.Flags.set("IsBanditsCoop", true);
						this.Contract.m.Current.getLoot().clear();
						this.Contract.m.Current.setDropLoot(false);
						this.Contract.getActiveState().onCombatWithPlayer(this.Contract.m.Current, false);
						return 0;
					}

				},
				{
					Text = "We\'re not here to share the spoils. Meet your end!",
					function getResult()
					{
						this.Flags.set("IsBandits3Way", true);
						this.Contract.getActiveState().onCombatWithPlayer(this.Contract.m.Current, false);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BanditsAftermathCoop",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_07.png[/img]{The evil in the place has been extinguished. After divvying up the goods with the brigands, you prepare to head toward %objective2%, being sure not to tell the thieves of it. | As the last of the undead are put to rest, you get a sense that the air is clearing up, like a fog of smoky air giving way to crisp, springtime aromas. The quick change in scents no doubt means you\'ve cleaned whatever evil dwelled there. You divide the loot with the brigands. They\'re rather smarmy, claiming the lot of you would not have survived if they weren\'t there. You almost told them of %objective2%, but this outbreak of ill-placed pride ruins any chance of you ever working with them again. | The evil of the place has been put to rest. %objective2% awaits.\n\n You divvy up the loot with the brigands who are more than happy to do business with you. They don\'t say it, but it\'s readily obvious they would have been slaughtered to the last man had you not been there. | With the horrid place cleansed of evil, only %objective2% remains on the contract. As for the brigands, they take their loot as agreed upon. They ask where you\'re going and you tell them it\'s none of their business. | As the last wiederganger is put to rest, you feel a sudden change in the air. Cleanliness punches your lungs with unexpected clarity as you stand in a world of muck and mire. %randombrother% wipes his brow.%SPEECH_ON%Must be the end of it. On our way to %objective2% then?%SPEECH_OFF%As a brigand walks up, you tell the warrior to hush. Best not to inform the bastards of the next spot. Despite taking a large share of loot, they were hardly a good goddam bit of help in the fight. | You entered a domain of evil, but with the last wiederganger slain you see the light of the world brighten and the smell of the earth beneath your feet returns to the natural order. With this place laid to rest, it\'s time to go on to %objective2%.\n\n The leader of the brigands comes up. He\'s got a scroll in hand and is keeping a tab of the divvied loot.%SPEECH_ON%Happy working with ya.%SPEECH_OFF%You tell him that his band of idiot men would have blundered to their doom had you not shown up. He shrugs.%SPEECH_ON%Nobody\'s perfect. Until next time, then?%SPEECH_OFF%You ignore him to go gather the men. | The victory was hard fought. Wiedergangers and the oddities of more ancient undead litter the field. The brigands you teamed up with are combing through the remains, taking their share of the loot as agreed upon. You hope %objective2% will be easier to sort out, but you doubt it. | Brigands scour the field picking up the loot which you and their leader agreed would be their share. You tell %randombrother% to quietly get the men ready for the march to %objective2%. He asks why quietly and you respond.%SPEECH_ON%Because the last thing we need are these useless ratfark anchors showing up in another battle and taking loot we both know they did not earn.%SPEECH_OFF%The warrior nods.%SPEECH_ON%Ah. I\'d say you took the words right of my mouth, but you got a bit creative there in the hatred, sir.%SPEECH_OFF% | You start readying the men for the march to %objective2%.\n\n The brigand\' leader comes to you.%SPEECH_ON%Good fightin\' with ya. Say, where are you off ta next? More treasures to find, eh?%SPEECH_OFF%You turn and grab the man by his shirt.%SPEECH_ON%I think we both know which of us pulled their weight in that fight. Now, you take your loot and go. That\'s what we agreed upon. If you follow us, I\'ll melt everything you\'ve pilfered and pour it over your goddam head, got it?%SPEECH_OFF%He shrinks back, nodding anxiously as though you might follow up on that promise just this second. | With the last of the undead slain, you look about the field. The dead are not of one source, judging by their variety of clothes and armors, but they are not of one timeline either. Some wear the armors of ancients and carried disturbing uniformity in their efforts to kill.\n\n %randombrother% comes by, stating that the company is ready to move onto %objective2% whenever you are. The brigand\' leader interrupts.%SPEECH_ON%Well, whenever we divvy up the loot first, right?%SPEECH_OFF%You nod. That is what was agreed upon.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Victory!",
					function getResult()
					{
						this.Flags.set("IsBanditsCoop", false);

						if (this.Flags.get("ObjectivesDestroyed") == 2)
						{
							this.Contract.setState("Return");
						}
						else
						{
							this.Contract.getActiveState().start();
							this.World.Contracts.updateActiveContract();
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BanditsAftermath3Way",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_22.png[/img]{You find the leader of the brigand\' dead amongst the bodies. He\'s got a look of regret on his face, moreso than which is usual for someone who\'d recently decided their own fate to a sour end. Ah well, how sad. You gather the men to ready for the march to %objective2%. | The brigands\' leader is dead on the ground. Half his face is missing, soon found in the maw of a nearby wiederganger. What a shame. Well, time to get on to %objective2%. | With the undead taken care of, as well as the idiotic brigands who thought they could stand up to the %companyname%, only %objective2% remains now. | The brigands chose poorly, fighting both the undead as well as the %companyname%. Shockingly, things did not go well for them. You order the men to collect all the loot and prepare for the march to %objective2%. | As the last of the undead are put to rest, you get a sense that the air is clearing up, like a fog of smoky air giving way to crisp, springtime aromas. The quick change in scents no doubt means you\'ve cleaned whatever evil dwelled there. Unfortunately, the group of dead brigands who decided to face you is gonna musk it up a bit. Oh well. Now to cleanse %objective2% and be done with this contract. | The evil of the place has been put to rest. The brigands, too, those poor idiots. %objective2% awaits. | As the last wiederganger is put to rest, and the last idiot thief beside it, you feel renewed. Part of it is showing those brigands what a horrible leader they had to get them all killed like that. The other part is no doubt the good feeling a vacating evil has left behind. Time to get going to %objective2%. | The victory was hard fought. Well, the undead put up a good fight. The brigands died like the idiots they were. You hope %objective2% will be easier to sort out, but unless it\'s actually filled with moronic thieves instead of evilness, you doubt it. | You find the leader of the brigands strewn over a wiederganger\'s corpse. %randombrother% walks up and laughs.%SPEECH_ON%Looks like they were meant to be.%SPEECH_OFF%Laughing, you tell him to get the men ready for a march to %objective2%.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Serves them right.",
					function getResult()
					{
						this.Flags.set("IsBandits3Way", false);

						if (this.Flags.get("ObjectivesDestroyed") == 2)
						{
							this.Contract.setState("Return");
						}
						else
						{
							this.Contract.getActiveState().start();
							this.World.Contracts.updateActiveContract();
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_04.png[/img]{ You step into %employer%\'s room to find the man and a woman standing over a table. A very pale child is on it and he is not moving. The mother grieves in silence, her face doing all the wailing it needs to. You break the somber mood by reporting to the chieftain that your task is complete. He nods.%SPEECH_ON%I know. There were rumors that, once you returned, it may be possible for the extinguished evil to breathe new life into the lands. The soils are richer than ever, but the dead still remain dead. Your pay is in the corner, warrior.%SPEECH_OFF%You go and retrieve your %reward_completion% crowns. %employer% is still consoling the woman as you depart. | %employer% waves you into his room with one and with the other holds out a bag of crowns.%SPEECH_ON%You need not report to me, warrior, for my scouts have already told me everything. Your payment, as agreed upon.%SPEECH_OFF% | %employer% welcomes you warmly, though a hawk-faced elder stoops angrily in the corner like you\'re a bigger scavenger come to chase him off a meal. You report what you\'ve done, but the chieftain waves it off.%SPEECH_ON%Oh warrior, I know all that happens in this land. You\'ve earned %reward_completion% crowns well.%SPEECH_OFF%The elder speaks, startling %employer%.%SPEECH_ON%Indeed the evils have been put to ruin and all that is good is permitted to grow! Now, warrior, please depart. We have important things to discuss here.%SPEECH_OFF%Hmm, yeah, of course. You take your pay and go. | You find %employer% standing over a freshly covered grave. A few clansmen sit nearby sharing a goatskin water flask. The nobleman shrugs.%SPEECH_ON%The body\'s stayed in the earth. So not only have you destroyed sources of evil, warrior, but it\'s quite possible you\'ve outright driven some of it from these lands. By the gods I hope so. Your pay is with my second. He\'ll have %reward_completion% crowns for you as promised.%SPEECH_OFF% | You find %employer% talking to an shaman. The healer has a cart of sharp tools, some of them tilted into a basin of red water. Glancing at the chieftain, you see that he\'s just recently had an arm stitched up. He waves you in.%SPEECH_ON%Boar hunting gone awry, warrior.%SPEECH_OFF%The healer cleans up and departs, telling the chieftain to stay settled for a week.%SPEECH_ON%Yeah yeah, well I got business to attend to. First of which is you, warrior. Your pay is in the corner, %reward_completion% crowns as promised. Who knows if the evil of the undead has truly been driven from these lands, but you\'ve done as asked.%SPEECH_OFF% | %employer% is talking to a woman when you enter. She makes the oddest statement you\'ve heard in sometime.%SPEECH_ON%My little boy stayed in the ground! He didn\'t come back! I\'m so happy! He stayed dead!%SPEECH_OFF%The chieftain holds her hands warmly and nods toward you.%SPEECH_ON%And there stands the man responsible for driving the evil from these lands. You\'ve earned those %reward_completion% crowns, warrior!%SPEECH_OFF% | You step into %employer%\'s room to find the man staring out his window. He remarks with sanguine sincerity.%SPEECH_ON%Alive. It\'s all so alive.%SPEECH_OFF%He turns, revealing a satchel in hand. He walks over and gives it to you.%SPEECH_ON%%reward_completion% should be in there. Good work with the undead, warrior, and may your services here put us one step closer to ending this evil altogether.%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Crowns well deserved.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Destroyed strongholds of the undead scourge");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isUndeadScourge())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCriticalContract);
						}

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
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"objective1",
			this.m.Flags.get("Objective1Name")
		]);
		_vars.push([
			"objective2",
			this.m.Flags.get("Objective2Name")
		]);
		local distToObj1 = this.m.Objective1 != null && !this.m.Objective1.isNull() && this.m.Objective1.isAlive() ? this.m.Objective1.getTile().getDistanceTo(this.World.State.getPlayer().getTile()) : 9999;
		local distToObj2 = this.m.Objective2 != null && !this.m.Objective2.isNull() && this.m.Objective2.isAlive() ? this.m.Objective2.getTile().getDistanceTo(this.World.State.getPlayer().getTile()) : 9999;

		if (distToObj1 < distToObj2)
		{
			_vars.push([
				"objective",
				this.m.Flags.get("Objective1Name")
			]);
		}
		else
		{
			_vars.push([
				"objective",
				this.m.Flags.get("Objective2Name")
			]);
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Objective1 != null && !this.m.Objective1.isNull() && this.m.Objective1.isAlive())
			{
				this.m.Objective1.getSprite("selection").Visible = false;
				this.m.Objective1.setOnCombatWithPlayerCallback(null);
			}

			if (this.m.Objective2 != null && !this.m.Objective2.isNull() && this.m.Objective2.isAlive())
			{
				this.m.Objective2.getSprite("selection").Visible = false;
				this.m.Objective2.setOnCombatWithPlayerCallback(null);
			}

			if (this.m.Target != null && !this.m.Target.isNull() && this.m.Target.isAlive())
			{
				this.m.Target.getSprite("selection").Visible = false;
				this.m.Target.setOnCombatWithPlayerCallback(null);
			}

			this.m.Current = null;
			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return false;
		}

		if (this.m.IsStarted)
		{
			if (this.m.Objective1 == null || this.m.Objective1.isNull() || !this.m.Objective1.isAlive())
			{
				return false;
			}

			if (this.m.Objective2 == null || this.m.Objective2.isNull() || !this.m.Objective2.isAlive())
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

	function onSerialize( _out )
	{
		if (this.m.Objective1 != null && !this.m.Objective1.isNull())
		{
			_out.writeU32(this.m.Objective1.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		if (this.m.Objective2 != null && !this.m.Objective2.isNull())
		{
			_out.writeU32(this.m.Objective2.getID());
		}
		else
		{
			_out.writeU32(0);
		}

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
		local obj1 = _in.readU32();

		if (obj1 != 0)
		{
			this.m.Objective1 = this.WeakTableRef(this.World.getEntityByID(obj1));
		}

		local obj2 = _in.readU32();

		if (obj2 != 0)
		{
			this.m.Objective2 = this.WeakTableRef(this.World.getEntityByID(obj2));
		}

		local target = _in.readU32();

		if (target != 0)
		{
			this.m.Target = this.WeakTableRef(this.World.getEntityByID(target));
		}

		this.contract.onDeserialize(_in);
	}

});

