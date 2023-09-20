this.nem_hunting_hexen_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		Dude = null,
		IsPlayerAttacking = true
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.hunting_hexen";
		this.m.Name = "A Pact With Witches";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		
	}

	function start()
	{
		local fatherName = this.m.Flags.get("father");
		if(fatherName == false)
		{
			fatherName = ::NorthMod.Utils.barbarianNameOnly();
			this.m.Flags.set("father", fatherName);
		}
		this.m.Payment.Pool = 900 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		this.m.Payment.Completion = 1.0;

		this.m.Flags.set("ProtecteeName", ::NorthMod.Utils.barbarianNameOnly());
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Stay around %townname% and protect %father%\'s firstborn son"
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
				local r = this.Math.rand(1, 100);

				if (r <= 20)
				{
					this.Flags.set("IsSpiderQueen", true);
				}
				else if (r <= 40)
				{
					this.Flags.set("IsCurse", true);
				}
				else if (r <= 50)
				{
					this.Flags.set("IsEnchantedVillager", true);
				}
				else if (r <= 55)
				{
					this.Flags.set("IsSinisterDeal", true);
				}
				r = this.Math.rand(1, 100);
				if (r <= 10)
				{
					this.Flags.set("IsSurvivalOffer", true);
				}

				this.Flags.set("StartTime", this.Time.getVirtualTimeF());
				this.Flags.set("Delay", this.Math.rand(10, 30) * 1.0);
				local envoy = this.World.getGuestRoster().create("scripts/entity/tactical/humans/firstborn");
				envoy.setName(this.Flags.get("ProtecteeName"));
				envoy.setTitle("");
				envoy.setFaction(1);
				this.Flags.set("ProtecteeID", envoy.getID());
				this.Contract.m.Home.setLastSpawnTimeToNow();
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Home != null && !this.Contract.m.Home.isNull())
				{
					this.Contract.m.Home.getSprite("selection").Visible = true;
				}

				this.World.State.setUseGuests(true);
			}

			function update()
			{
				if (!this.Contract.isPlayerNear(this.Contract.getHome(), 600))
				{
					this.Flags.set("IsFail2", true);
				}

				if (this.Flags.has("IsFail1") || this.World.getGuestRoster().getSize() == 0)
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.has("IsFail2"))
				{
					this.Contract.setScreen("Failure2");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.has("IsVictory"))
				{
					
					local bros = this.World.getPlayerRoster().getAll();
					local candidatesDestined = [];
					local candidatesCurse = [];

					foreach( bro in bros )
					{
						if (bro.getSkills().hasSkill("trait.superstitious"))
						{
							candidatesCurse.push(bro);
						}
						if (bro.getSkills().hasSkill("trait.destined"))
						{
							candidatesDestined.push(bro);
						}
					}
					
					if(candidatesCurse.len()> 0)
					{
						this.Contract.m.Dude = candidatesCurse[this.Math.rand(0, candidatesCurse.len() - 1)];
					}
					
					if ((this.Flags.get("IsSurvivalOffer") || this.Flags.get("IsChasedOffer")) && candidatesDestined.len() != 0)
					{
						this.Contract.setScreen("SurvivalOffer");
					}
					else if (this.Flags.get("IsCurse") && candidatesCurse.len() != 0)
					{
						this.Contract.setScreen("Curse");
					}
					else if (this.Flags.get("IsEnchantedVillager"))
					{
						this.Contract.setScreen("EnchantedVillager");
					}
					else
					{
						this.Contract.setScreen("Success");
					}

					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("StartTime") + this.Flags.get("Delay") <= this.Time.getVirtualTimeF())
				{
					if (this.Flags.get("IsSpiderQueen"))
					{
						this.Contract.setScreen("SpiderQueen");
					}
					else if (this.Flags.get("IsSinisterDeal") && this.World.Assets.getStash().hasEmptySlot())
					{
						this.Contract.setScreen("SinisterDeal");
					}
					else
					{
						this.Contract.setScreen("Encounter");
					}

					this.World.Contracts.showActiveContract();
				}
				else if (!this.Flags.get("IsBanterShown") && this.Math.rand(1, 1000) <= 1 && this.Flags.get("StartTime") + 6.0 <= this.Time.getVirtualTimeF())
				{
					this.Flags.set("IsBanterShown", true);
					this.Contract.setScreen("Banter");
					this.World.Contracts.showActiveContract();
				}
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_actor.getID() == this.Flags.get("ProtecteeID"))
				{
					this.Flags.set("IsFail1", true);
					this.World.getGuestRoster().clear();
				}
			}

			function onActorRetreated( _actor, _combatID )
			{
				if (_actor.getID() == this.Flags.get("ProtecteeID"))
				{
					this.Flags.set("IsFail1", true);
					this.World.getGuestRoster().clear();
				}
				else if (_actor.getType() == this.Const.EntityType.Hexe)
				{
					this.Flags.set("IsChasedOffer", true)
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Hexen")
				{
					this.Flags.set("IsVictory", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Hexen")
				{
					this.Flags.set("IsFail2", true);
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
			Text = "[img]gfx/ui/events/event_79.png[/img]{You find %employer% in a conversation with a large man. When he notices %employer_short% motions you to come forward.%SPEECH_ON%Have you met %father%?%SPEECH_OFF%He points to the man beside him. It is the first time you see the man so you shake your head.%SPEECH_ON%He is one of my best warriors, but he tells me that some time ago, he made a deal with the witches, and now they are coming to collect. The price is his firstborn son.%SPEECH_OFF%The man, %father%, slumps his head, his expression that of shame and disgrace.%employer% continues.%SPEECH_ON%He came to me for help and now I ask the help of you and your crew. Will you save this man and his son from terrible fate?%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{You\'ll have to pay us very well in order to take on this enemy. | Convince me this is worth it with a full pouch of crowns. | I expect to be paid very well to fight an enemy as this.}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{Sounds to me like you should honor your pact. | This won\'t be worth the risk. | I\'d rather not get the company involved with an enemy like this.}",
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
			ID = "Banter",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_79.png[/img]{%randombrother% comes up to you. He\'s auguring his ear with a pinky.%SPEECH_ON%Hey there captain. You seen any of them saucy broads yet?%SPEECH_OFF%Hearing this, %randombrother2% comes over. He leans in.%SPEECH_ON%Hey, the way I hear it them hexes ARE quite the lookers, but that\'s how they get ya. They fool ya with their charms and then eat yer very soul.%SPEECH_OFF%Laughing, %randombrother% wipes the wax on %randombrother2%\'s garb.%SPEECH_ON%They\'ll have to go to %randomtown% to get my soul, then, cause another woman done beat them to the punch.%SPEECH_OFF% | You\'re inspecting inventory when %randombrother% comes up. You\'d sent him to scout the lands and he\'s readied a report.%SPEECH_ON%Sir, nothing sighted as of yet, but I got talking to some of the locals. The way they have it, the witches make pacts with regular folk and then trade on the investment years later, usually with great interest. They said they can fool you into seeing them as licentious minxes. They can bed you right into the grave! I said that sounded like cicada cockamamie to me.%SPEECH_OFF%Nodding, you ask the man what the hell a cicada is. He laughs.%SPEECH_ON%Seriously? It\'s a kind of nut, sir.%SPEECH_OFF% | The brothers are idling the time away, bantering about women and witches alike and if there\'s any real significant difference at all. %randombrother% holds his hand out.%SPEECH_ON%Now in all seriousness, I\'ve heard tales of these wenches. They can put a hex on you to make you see things. They\'ll make you sign bloodpacts and if you don\'t pay they\'ll cut your kneecaps out and use them for divination. Hell, when I was a child, my neighbor made a deal with one and then he disappeared. I later saw a mysterious woman walking around with a fresh skull being used for a lantern!%SPEECH_OFF%%randombrother2% nods attentively.%SPEECH_ON%That\'s incredible, but does anybody know what a witch does?%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Stay focused, lads.",
					function getResult()
					{
						if (this.Flags.get("StartTime") + this.Flags.get("Delay") - 3.0 <= this.Time.getVirtualTimeF())
						{
							this.Flags.set("Delay", this.Flags.get("Delay") + 5.0);
						}

						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SpiderQueen",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_106.png[/img]{A lone woman crosses your path and approaches between a gap of trees. She saunters with her thighs slipping in and out of a silk dress. Her skin is spotless and emerald eyes stare between locks of red with licentiousness you haven\'t seen since you were just a lad. You know this woman is a witch for such perfection can\'t stand in this world and in these parts it\'s like putting on makeup to go to the grave. Which is what she\'s done. You draw your sword and tell her to face her doom with honor. The witch\'s skin wrinkles to true, ghastly form, and she cackles with delight.%SPEECH_ON%Ah, for a moment I had you, but the cock slackens, and the pride returns. You\'ve such delightful scents, warrior. I\'ll make sure they save you just for me.%SPEECH_OFF%Before you can ask what she means, the two trees she stands between blossom with the stretching of spider legs. Great black bulbs emerge from the thicket and scuttle to the terra below, the webknechts clacking their mandibles with imago hunger. The witch\'s hands go up and her fingers dance like a puppeteer in command of the clouds above.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Hexen";
						p.Entities = [];
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.Entities.push({
							ID = this.Const.EntityType.Spider,
							Variant = 0,
							Row = 1,
							Script = "scripts/entity/tactical/enemies/spider_bodyguard",
							Faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID(),
							Callback = null
						});
						p.Entities.push({
							ID = this.Const.EntityType.Spider,
							Variant = 0,
							Row = 1,
							Script = "scripts/entity/tactical/enemies/spider_bodyguard",
							Faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID(),
							Callback = null
						});
						p.Entities.push({
							ID = this.Const.EntityType.Hexe,
							Variant = 0,
							Row = 2,
							Script = "scripts/entity/tactical/enemies/hexe",
							Faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID(),
							function Callback( _e, _t )
							{
								_e.m.Name = "Spider Queen";
							}

						});
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Spiders, 50 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SinisterDeal",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_106.png[/img]{%randombrother% whistles and tips his cap at the beautiful ladies which have arrived seemingly out of nowhere to swoon before the company. You hold the your man back and step forward, but before you can speak one of the women holds her hands up and strides to meet you.%SPEECH_ON%Let me show you my true self, warriors.%SPEECH_OFF%Her arms go to her sides and there turn grey and shrivel like wet almond skin. Once bright and silken hair falls out in long wispy strands until her grotesque skull is bared, the last roots there holding clumped assemblage of gnats and lice like final congregates upon a dying world. She bows, her face up toward you with a yellow grin shorn across it.%SPEECH_ON%We\'ve great power, warrior, of this you surely see. I offer you a deal.%SPEECH_OFF%She produces a tiny vial in each hand, one carrying a drop of green liquid, the other blue. She smiles and spins them in her fingers as she talks.%SPEECH_ON%A drink for the body, or for the spirit. Men would kill for either. I offer you one in exchange for the firstborn\'s life. What worth is the offspring of a stranger? You\'ve slaughtered your fair share, have you not? Stand aside, warrior, and let us have this one. Or confront us, risk your men\'s lives, and your own, all for some runt who won\'t remember your face in due time. It\'s your choice.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "I will never yield that boy to you hags. To arms!",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Hexen";
						p.Entities = [];
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.HexenAndNoSpiders, 100 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				},
				{
					Text = "I desire a drink for the body.",
					function getResult()
					{
						return "SinisterDealBodily";
					}

				},
				{
					Text = "I desire a drink for the spirit.",
					function getResult()
					{
						return "SinisterDealSpiritual";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SinisterDealBodily",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_106.png[/img]{The witch smiles.%SPEECH_ON%A man is nothing without an able body to maneuver him through the world. Here you are, warrior. Please, do not waste it.%SPEECH_OFF%She tosses you the vial. Twisting through the air, it winks viridian spectra across the earth, each dip of its faint light springing forth a tiny flower out of unseeded mud. You catch the glass. It vibrates in your hand, and the ache of your bones slowly depart, as though your fist had been asleep all this time and you just didn\'t know it. When you look up for an explanation the witches are already gone. A lone cry is all that\'s left, piping up in the great distance yet with no way to ascertain just how far off it is. No doubt it is the demise of %employer%\'s firstborn.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Too good a trade to refuse.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail * 2, "Betrayed " + this.Contract.getEmployer().getName() + " and struck a deal with witches");
						this.World.Contracts.finishActiveContract(true);
						return;
					}

				}
			],
			function start()
			{
				local item = this.new("scripts/items/special/bodily_reward_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "SinisterDealSpiritual",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_106.png[/img]{With a flip of her hand and a bump of her wrist the witch shunts the green vial down her sleeve. The remaining blue vial she holds out to you.%SPEECH_ON%A smart man you are, warrior.%SPEECH_OFF%She snorts harshly, her fat nose shriveling into a maggot\'s girth before flopping back down.%SPEECH_ON%I do sense sharp minded men in your blood, warrior. I\'d almost want to have the blood for myself.%SPEECH_OFF%Her eyes stare at you like a cat upon a delimbed cricket, a cricket which still dares to move. But then her smile returns, more gum than teeth, more black than pink.%SPEECH_ON%Ah, well, a deal is a deal. Here you are.%SPEECH_OFF%She throws the vial through the air and by the time you catch it and look back the witches are gone. You hear the faint cry of horrific torture, its distance seemingly both near and far, and you\'ve little doubt that it is the demise of %employer%\'s firstborn.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Too good a trade to refuse.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail * 2, "Betrayed " + this.Contract.getEmployer().getName() + " and struck a deal with witches");
						this.World.Contracts.finishActiveContract(true);
						return;
					}

				}
			],
			function start()
			{
				local item = this.new("scripts/items/special/spiritual_reward_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Encounter",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_106.png[/img]{%randombrother% whistles and yells out.%SPEECH_ON%We\'ve company. Nice... beautiful company...%SPEECH_OFF%A licentious looking woman is approaching the band. She sashays over the ground with ease, one finger playing with her ear, the other pinching a stone hanging over her bulging bosom. You clap the warrior on the shoulder.%SPEECH_ON%That\'s no ordinary lady.%SPEECH_OFF%Just as the words leave your lips, the woman\'s ample and youthful features shrivel into a patterned grey and her luxurious hair withers from her pate and what you\'re left with is a hag, grinning with nothing but evil intentions. To arms! Keep %protectee% safe! | You spot a woman approaching the party. She\'s wearing bright red and a necklace sways over and between her ample bosom. It\'s quite the sight, but she is flawless and such a thing does not exist in this world.\n\nYou draw your sword. The lady sees the steel and then looks at you with a wily grin. Plots of hair fall from her head and what\'s left shrivels into grey wisps. Her skin shrinks into pale valleys and her fingernails grow so long they curl. She points a finger at you and screams that nobody will prevent the conclusion of the pact she\'s made. You yell out to the company to make sure %protectee% is kept out of harm\'s way. | A woman is spotted approaching the company. Xour men are ensorcelled by her beauty, but you know better. You draw your sword and clang it loud enough to draw the ire of this supposed lady. She sneers and her lips snap back with a grin that goes from nearly ear to ear. Her skin tightens until it creases and turns a pale grey. She laughs and laughs as her hair falls out. The witch points a finger at you.%SPEECH_ON%Ah, I smell your ancestry, warrior, but it matters not where you come from. The pact must be paid by the firstborn\'s blood and anyone who stands in our way will bleed in kind!%SPEECH_OFF%The company falls into formation and you tell %protectee% to keep his head down.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Hexen";
						p.Entities = [];
						p.Music = this.Const.Music.BeastsTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.HexenAndNoSpiders, 100 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID());
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Curse",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_124.png[/img]{As you start your return trip to %employer%, you find %superstitious% staring down at a witch. You can see the damned woman\'s lips are still moving and you rush over. She\'s speaking in curses which you shutup with the heel of your boot. Teeth flutter from rent gums as she laughs. You draw your sword and stab it between her eyes, putting her to rest once and for all. %superstitious% is just about shaking.%SPEECH_ON%She knew all about me! She knew everything, captain! She knew everything! She knew when I\'d die and how!%SPEECH_OFF%You tell the man to ignore every word the witch told him. Nodding, he rejoins the company, but his face grimaces with fortunes that can\'t go unheard.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Don\'t think about it.",
					function getResult()
					{
						return "Success";
					}

				}
			],
			function start()
			{
				this.Characters.push(this.Contract.m.Dude.getImagePath());
				local effect = this.new("scripts/skills/effects_world/afraid_effect");
				this.Contract.m.Dude.getSkills().add(effect);
				this.List.push({
					id = 10,
					icon = effect.getIcon(),
					text = this.Contract.m.Dude.getName() + " is afraid"
				});
				this.Contract.m.Dude.worsenMood(1.5, "Was cursed by a witch");

				if (this.Contract.m.Dude.getMoodState() <= this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[this.Contract.m.Dude.getMoodState()],
						text = this.Contract.m.Dude.getName() + this.Const.MoodStateEvent[this.Contract.m.Dude.getMoodState()]
					});
				}
			}

		});
		this.m.Screens.push({
			ID = "EnchantedVillager",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_124.png[/img]{As the men recover from battle, a young peasant runs across the field hollering and whooping. You turn to see him fall before a witch and hold her ghastly, leathery body up, clutching it between his arms and rocking back and forth. Seeing you, he spits curses.%SPEECH_ON%Why\'d you do it, huh? Goddam bastards the lot of ya! She was wed to me a fortnight ago and now I must bury her. Well I say take me with her! Do your worst, you savages! This world will bury us both, my love!%SPEECH_OFF%You raise an eyebrow. The man must have been bewitched sometime before your arrival, probably a lackey for the witches. Whatever you think, a few of the men are a bit disturbed by the sight of the grieving boy. However, one hardier warrior with a slick grin and his hand on his weapon asks if he should grant the kid his request. You shake your head no and order the men back into formation.} ",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Poor fool.",
					function getResult()
					{
						return "Success";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_124.png[/img]{The battle over, %randombrother% comes to your side. He says %protectee% died during the fight. Says his eyeballs are gone as is his tongue, that his face looks like two wet rags folding in on each other. No point in going back to %employer% now. | You look down at %protectee%\'s corpse. The eyeballs have been yanked and hang down his cheeks like wet craw. His face is stretched into a smile, though whatever put it that way couldn\'t have been the least bit funny. %randombrother% asks if the company should return to %employer% and you shake your head no. | You find %employer%\'s firstborn crumpled on the ground. Every joint has been scooped or carved out, though when or how this happened is beyond you. %randombrother% tries to move the body, but it twists and clatters like a stringless puppet. The warrior grimaces and throws the corpse back to the ground where it rimples into a basket of its own ribcage, the head egglike in the nest. There\'s no point in returning to %employer% now.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Shite, shite, shite!",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to protect " + this.Contract.getEmployer().getName() + "\'s firstborn son");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Failure2",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_16.png[/img]{%employer% was paying you to protect %protectee%. The firstborn is hard to protect when you leave %townname% and abandon him to the witches. Don\'t bother going back for your pay. | You had been tasked to keep %protectee% safe in %townname%, or did you forget? Don\'t bother going back, the firstborn is no doubt already dead or, worse, taken by the witches for some nefarious purpose.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Oh, damn.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to protect " + this.Contract.getEmployer().getName() + "\'s firstborn son");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_79.png[/img]{You return %protectee% to %employer% and %father%. The father and firstborn embrace like the telling of two separate dreams of identical circumstance, slowly coming together despite the appeals of reality. Finally, they hug and clench one another and pause to stare at one another to be sure it\'s all real. You tell %employer% that every witch is dead, but that he should keep the tale to himself. He nods.%SPEECH_ON%Spirits feed on hubris, I know that much, and I shall take this story to the grave. I thank you for what you\'ve done today, warrior. You did a great service not just to %father% and me, but entire clan. I\'ve but one way to express my appreciation.%SPEECH_OFF%He brings you a satchel of gold. The sight of the bag bulging with coin brings a warm smile to your face.}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "All worked out in the end.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Protected " + this.Contract.getEmployer().getName() + "\'s firstborn son");
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
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
		
		this.m.Screens.push({
			ID = "SurvivalOffer",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_106.png[/img]",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Your life ends here!",
					function getResult()
					{
						if (this.Flags.get("IsCurse") && candidatesCurse.len() != 0)
						{
							return "Curse";
						}
						else if (this.Flags.get("IsEnchantedVillager"))
						{
							return "EnchantedVillager";
						}
						else
						{
							return "Success";
						}
					}

				},
				{
					Text = "I desire a drink for the body.",
					function getResult()
					{
						return "SparedDealBodily";
					}

				},
				{
					Text = "I desire a drink for the spirit.",
					function getResult()
					{
						return "SparedDealSpiritual";
					}

				}
			]
			
			function start()
			{
				if (this.Flags.get("IsSurvivalOffer"))
				{
					this.Text += "{As your men scour the battlefield %randombrother% yells that one of the witches is still alive. You race towards him and there you see her. An old hag, beaten and bruised, defenseless, but not yet dead. You could finish her off quite easily, but she raises her hand.}"
				}
				else if (this.Flags.get("IsChasedOffer"))
				{
					this.Text += "{One of the witches has escaped and you, as well as your men give chase. It\'s not long before you catch up with her and corner her. She still looks beautiful, but not as flawless as when you first saw her. You and your men could finish her off quite easily, but she raises her hand.}"
				}
				
				this.Text += "{%SPEECH_ON%Stop! Stop right there!%SPEECH_OFF%Her voice is soothing and calming, like an echo traveling through the age. Yet at the same time it is a voice of authority and commanding, leaving no option but to stand still like a mountain. You shake your head, muster all of you strength and try to make a step forward. It is a long and hard step, but you make it none the less and as your foot touches the ground the spell breaks and the weight falls from you. The witch speaks again, but this time her voice is broken and raspy and almost crying. %SPEECH_ON%You are indeed blessed by destiny. Let me live and I will not return here. You will not see me again. You shake your head and make another step towards her, raising your sword and preparing to bury it in her head. Suddenly she produces a tiny vial in each hand, one carrying a drop of green liquid, the other blue.%SPEECH_ON%Wait! A drink for the body, or for the spirit. Men would kill for either. I offer you one in exchange for my life.%SPEECH_OFF%}"
			}
		});
		
		this.m.Screens.push({
			ID = "SparedDealBodily",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_106.png[/img]{The witch smiles.%SPEECH_ON%A man is nothing without an able body to maneuver him through the world. Here you are, warrior. Please, do not waste it.%SPEECH_OFF%She tosses you the vial. Twisting through the air, it winks viridian spectra across the earth, each dip of its faint light springing forth a tiny flower out of unseeded mud. You catch the glass. It vibrates in your hand, and the ache of your bones slowly depart, as though your fist had been asleep all this time and you just didn\'t know it. When you look up for an explanation the witch is already gone.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Too good a trade to refuse.",
					function getResult()
					{
						return "SuccessDeal";
					}

				}
			],
			function start()
			{
				local item = this.new("scripts/items/special/bodily_reward_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "SparedDealSpiritual",
			Title = "Near %townname%",
			Text = "[img]gfx/ui/events/event_106.png[/img]{With a flip of her hand and a bump of her wrist the witch shunts the green vial down her sleeve. The remaining blue vial she holds out to you.%SPEECH_ON%A smart man you are, warrior.%SPEECH_OFF%She snorts harshly, her fat nose shriveling into a maggot\'s girth before flopping back down.%SPEECH_ON%I do sense sharp minded men in your blood, warrior. I\'d almost want to have the blood for myself.%SPEECH_OFF%Her eyes stare at you like a cat upon a delimbed cricket, a cricket which still dares to move. But then her smile returns, more gum than teeth, more black than pink.%SPEECH_ON%Ah, well, a deal is a deal. Here you are.%SPEECH_OFF%She throws the vial through the air and by the time you catch it and look back the witch is gone.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Too good a trade to refuse.",
					function getResult()
					{
						return "SuccessDeal";
					}

				}
			],
			function start()
			{
				local item = this.new("scripts/items/special/spiritual_reward_item");
				this.World.Assets.getStash().add(item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "You gain " + item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "SuccessDeal",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_79.png[/img]{You return %protectee% to %employer% and %father%. The father and firstborn embrace like the telling of two separate dreams of identical circumstance, slowly coming together despite the appeals of reality. Finally, they hug and clench one another and pause to stare at one another to be sure it\'s all real. %employer% asks if all the witches are dead?%SPEECH_ON%All but one that escaped, but that one will not bother you. Not for now at least.%SPEECH_OFF%%employer_short% looks visibly unhappy, but then finally nods. %SPEECH_ON%You did well today, warrior. It would be better if all the witches are dead as it was agreed. Still, you did a service not just to %father% and me, but entire clan. You deserve at least some reward for your troubles.}"
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "All worked out in the end.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion()*0.75);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Protected " + this.Contract.getEmployer().getName() + "\'s firstborn son");
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
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion()*0.75 + "[/color] Crowns"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Home, this.List);
			}

		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"superstitious",
			this.m.Dude != null ? this.m.Dude.getName() : ""
		]);
		_vars.push([
			"direction",
			this.m.Target == null || this.m.Target.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Target.getTile())]
		]);
		_vars.push([
			"protectee",
			this.m.Flags.get("ProtecteeName")
		]);
		local fatherName = this.m.Flags.get("father");
		if(fatherName == false)
		{
			fatherName = ::NorthMod.Utils.barbarianNameOnly()
			this.m.Flags.set("father", fatherName);
		}
		_vars.push([
			"father",
			fatherName
		]);
		_vars.push([
			"employer_short",
			this.m.EmployerID != 0 ? this.Tactical.getEntityByID(this.m.EmployerID).getNameOnly() : ""
		]);
	}

	function onHomeSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Home.addSituation(this.new("scripts/entity/world/settlements/situations/abducted_children_situation"));
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			this.m.Home.getSprite("selection").Visible = false;
			this.World.State.setUseGuests(true);
			this.World.getGuestRoster().clear();
		}

		if (this.m.Home != null && !this.m.Home.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Home.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(3);
			}
		}
	}

	function onIsValid()
	{
		return true;
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

