this.nem_last_stand_contract <- this.inherit("scripts/contracts/barbarian_contract", {
	m = {
		IsPlayerAttacking = true,
		SafeCooldown = 10
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

		this.m.Type = "contract.nem_last_stand";
		this.m.Name = "Defend Settlement";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		this.m.MakeAllSpawnsResetOrdersOnContractEnd = false;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
	}

	function start()
	{
		if (this.m.Home == null)
		{
			this.setHome(this.World.State.getCurrentTown());
		}

		this.m.Flags.set("ObjectiveName", this.m.Origin.getName());
		this.m.Flags.set("OriginChieftain", this.m.Origin.getChieftain().getName());
		this.m.Name = "Defend " + this.m.Origin.getName();
		this.m.Payment.Pool = 1600 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		if (this.Math.rand(1, 100) <= 33)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else
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
					"Travel to %objective% in the %direction%",
					"Defend against the undead"
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

				if (r <= 40)
				{
					this.Flags.set("IsUndeadAtTheWalls", true);
				}
				else if (r <= 70)
				{
					this.Flags.set("IsGhouls", true);
				}

				this.Flags.set("Wave", 0);
				this.Flags.set("Militia", 7);
				this.Flags.set("MilitiaStart", 7);
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
					this.Contract.m.Origin.setLastSpawnTimeToNow();
					if(this.Contract.m.UnitsSpawned.len() > 0)
					{
						local e = this.World.getEntityByID(this.Contract.m.UnitsSpawned[0]);
						
						this.Contract.setCallbackAtTheWalls(e);
					}
					
				}
				
				
			}

			function update()
			{
				if (this.Contract.m.Origin == null || this.Contract.m.Origin.isNull() || !this.Contract.m.Origin.isAlive())
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
					return;
				}
				else if (this.Contract.isPlayerNear(this.Contract.m.Origin, 600) && this.Flags.get("IsUndeadAtTheWalls") && !this.Flags.get("IsUndeadAtTheWallsShown"))
				{
					this.Flags.set("IsUndeadAtTheWallsShown", true);
					this.Contract.setScreen("UndeadAtTheWalls");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.isPlayerAt(this.Contract.m.Origin) && this.Contract.m.UnitsSpawned.len() == 0)
				{
					this.Contract.setScreen("ADireSituation");
					this.World.Contracts.showActiveContract();
				}
			}
			
			

		});
		this.m.States.push({
			ID = "Running_Wait",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Defend %objective% against the undead"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
					this.Contract.m.Origin.setLastSpawnTimeToNow();
				}
			}

			function update()
			{
				if (this.Contract.m.Origin == null || this.Contract.m.Origin.isNull() || !this.Contract.m.Origin.isAlive())
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Contract.m.UnitsSpawned.len() != 0)
				{
					local contact = false;

					foreach( id in this.Contract.m.UnitsSpawned )
					{
						local e = this.World.getEntityByID(id);

						if (e.isDiscovered())
						{
							contact = true;
							break;
						}
					}

					if (contact)
					{
						if (this.Flags.get("Wave") == 1)
						{
							this.Contract.setScreen("Wave1");
						}
						else if (this.Flags.get("Wave") == 2 && !this.Flags.get("GhoulsStarted"))
						{
							this.Contract.setScreen("Wave2");
						}
						else if (this.Flags.get("IsGhouls") && !this.Flags.get("GhoulsShown"))
						{
							this.Flags.set("GhoulsShown", true);
							this.Contract.setScreen("Ghouls");
						}
						else if (this.Flags.get("Wave") == 3)
						{
							this.Contract.setScreen("Wave3");
						}

						this.World.Contracts.showActiveContract();
					}
				}
				else if (this.Flags.get("TimeWaveHits") <= this.Time.getVirtualTimeF())
				{
					if (this.Flags.get("IsGhouls") && this.Flags.get("Wave") == 3 && !this.Flags.get("GhoulsStarted"))
					{
						this.Flags.set("GhoulsStarted", true);
						this.Flags.set("Wave", 2);
						this.Contract.spawnGhouls();
					}
					else
					{
						this.Contract.spawnWave();
					}
				}
			}

		});
		this.m.States.push({
			ID = "Running_Wave",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Defend %objective% against the undead"
				];

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull())
				{
					this.Contract.m.Origin.getSprite("selection").Visible = true;
					this.Contract.m.Origin.setLastSpawnTimeToNow();
				}

				foreach( id in this.Contract.m.UnitsSpawned )
				{
					local e = this.World.getEntityByID(id);

					if (e != null)
					{
						e.setOnCombatWithPlayerCallback(this.onCombatWithPlayer.bindenv(this));
					}
				}
			}

			function update()
			{
				if (this.Contract.m.Origin == null || this.Contract.m.Origin.isNull() || !this.Contract.m.Origin.isAlive())
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
					return;
				}

				if (this.Contract.m.UnitsSpawned.len() == 0)
				{
					if (this.Flags.get("Wave") < 3)
					{
						local militia = this.Flags.get("MilitiaStart") - this.Flags.get("Militia");
												
						if (this.Flags.get("ChieftainDead") && !this.Flags.get("ChieftainDeadShown"))
						{
							this.Contract.setScreen("ChieftainDead")
						}
						else if (militia >= 3)
						{
							this.Contract.setScreen("Militia1");
						}
						else if (militia >= 2)
						{
							this.Contract.setScreen("Militia2");
						}
						else
						{
							this.Contract.setScreen("Militia3");
						}
					}
					else
					{
						this.Contract.setScreen("TheAftermath");
					}

					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatWithPlayer( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
				local p = this.Contract.getCombatProperties(_dest);
				p.Music = this.Const.Music.UndeadTracks;
				p.CombatID = "ContractCombat";

				if (this.Contract.m.Origin != null && !this.Contract.m.Origin.isNull() && this.World.State.getPlayer().getTile().getDistanceTo(this.Contract.m.Origin.getTile()) <= 4)
				{
					p.AllyBanners.push(this.Contract.m.Origin.getBanner());

					for( local i = 0; i < this.Flags.get("Militia"); i = ++i )
					{
						if (i == 0 && !this.Flags.get("ChieftainDead"))
						{
							local name = this.Contract.m.Origin.getChieftain().getName();
							p.Entities.push({
								ID = this.Const.EntityType.BarbarianChampion,
								Name = name,
								Variant = 0,
								Row = -1,
								Script = "scripts/entity/tactical/humans/barbarian_champion",
								Faction = 2,
								function Callback( _entity, _tag )
								{
									_entity.m.Flags.add("militia");
									_entity.m.Flags.add("chieftain");
								}
							});
							continue;
						}
						
						local r = this.Math.rand(1, 100);

						if (r < 75)
						{
							p.Entities.push({
								ID = this.Const.EntityType.BarbarianThrall,
								Variant = 0,
								Row = -1,
								Script = "scripts/entity/tactical/humans/barbarian_thrall",
								Faction = 2,
								function Callback( _entity, _tag )
								{
									_entity.m.Flags.add("militia");
								}
							});
						}
						else
						{
							p.Entities.push({
								ID = this.Const.EntityType.BarbarianMarauder,
								Variant = 0,
								Row = -1,
								Script = "scripts/entity/tactical/humans/barbarian_marauder",
								Faction = 2,
								function Callback( _entity, _tag )
								{
									_entity.m.Flags.add("militia");
								}
							});
						}
					}
				}

				this.World.Contracts.startScriptedCombat(p, this.Contract.m.IsPlayerAttacking, true, true);
			}

			function onActorKilled( _actor, _killer, _combatID )
			{
				if (_combatID == "ContractCombat" && _actor.getFlags().has("militia"))
				{
					this.Flags.set("Militia", this.Flags.get("Militia") - 1);
				}
				if (_combatID == "ContractCombat" && _actor.getFlags().has("chieftain"))
				{
					this.Flags.set("ChieftainDead", true);
					this.Flags.set("ElderName", ::NorthMod.Utils.barbarianNameOnly() + " The Elder");
				}
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Return to " + this.Contract.m.Origin.getName()
				];

				this.Contract.m.Origin.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Origin))
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
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer% is found staring at one of his swords. He has it unsheathed, staring at his face in the steeled reflection.%SPEECH_ON%I know how to use it, but it was meant for men. Now? People speak of the dead, of greenskins, beasts beyond measure!%SPEECH_OFF%He slams the sword to the hilt and throws it and the scabbard on his table. He runs his hand through his hair.%SPEECH_ON%%origin_chieftain% of %objective% has asked for our help. People there have been surrounded by these... these things! I know not what they are, only that they kill and kill and kill! I\'ve not a man to spare, but if you go there and help them then you will be rewarded fairly!%SPEECH_OFF% | You find %employer% sitting between an experienced warior and one of the clan elders. They are yelling at each other in jowl-shaking, teeth-rattling old man voices. Given that the dead are arisen, questions of both mortality and life-after-death have become rather furiously debated. The chieftain sees you and jumps to his feet. He hurries to you, the argument raging in the background.%SPEECH_ON%Thank the old gods you are here, warrior. Just %direction% of here, %objective% is under siege by an army of horribles. Undead, foul things. Their chief, %origin_chieftain%, has sent one of their warriors to us, asking help, but I don't have the men to send. Can you go there and ensure those people are safe. You will be paid very well!%SPEECH_OFF% | You find the %employer% walking on the outskirts of the camp. The land spreads out before you, enormous forests turned into mere dots, mountains into arrowhead, birds arcing in thick formations.%SPEECH_ON%Yesterday, a man from %objective% came to us. He speaks on behalf their chieftain %origin_chieftain%, it seems that they are attacked by unbeliavable force, undead to be exact. Yes, that unbelievable. Whatever assails their camp, I have not the men to handle it. But you, warrior, might be able to help them. Would you be interested?%SPEECH_OFF% | %employer% is listening to the whispers of an elder when you enter his room. The elder glances at you with jaundiced eyes before continuing his talk. When he finishes, both men nod and the elder leaves. He doesn\'t so much as look at you as he goes. %employer% calls out.%SPEECH_ON%Glad you are here, warrior! These are indeed dire times. My men are spread across the land handling all manner of monstrous evils. I\'m sure you have heard already, but the \'dead\', or whatever they are, walk again. And they\'re assaulting %objective% %direction% of here. In fact, just yesterday a messenger from %origin_chieftain% arrived pleading for help. However, with no men to spare, I must ask you to help them.%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{How much is this worth to you? | We can defend %objective% for the right price...}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{This isn\'t worth it. | I\'m afraid %objective% is on their own.}",
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
			ID = "UndeadAtTheWalls",
			Title = "At %objective%...",
			Text = "[img]gfx/ui/events/event_29.png[/img]{Approaching %objective%, %randombrother% suddenly calls out from his lead point.%SPEECH_ON%Chief, hurry!%SPEECH_OFF%You rush over to him and look ahead. The camp is absolutely surrounded by a pale sea of bobbing, moaning undead! The %companyname% will have to cut through them if it is to get inside. | A man jogs toward the %companyname%. He\'s holding one of his arms and a crown of crimson runs down his head. He yells out.%SPEECH_ON%Go, go away! There\'s nothing for you here but horrors!%SPEECH_OFF%%randombrother% throws the stranger to the ground and draws a weapon to keep him there. You stay the warrior\'s hand as you look ahead: %objective% is already surrounded by a large number of undead. The %companyname% needs to act fast! | You\'ve arrived just in time: the walls of %objective% are already under assault by the undead! | Rounding a pathway, you\'re brought to a sudden stop. Ahead of you, %objective% is surrounded by a crowd of undead. Nearer to you, a few linger, oddly stranded from the horde. The %companyname% will need to fight its way into %objective%! | The walls of %objective% are strangely grey - wait, that\'s not the wood, it\'s the undead! To your horror, the pale monsters are already attacking, but you\'ve time yet to save %objective% and fight your way in. Drawing out your sword, you command the %companyname% to battle! | A shapeless formation of undead are already idling outside of %objective%\'s walls. You can see the heads of defenders peeking over the defenses, trying hard to not give themselves away. Drawing your sword, you tell the %companyname% that they will have to fight their way into the village. | A few undead are already at the gates of %objective%! Guards atop the gatehouse wave at you, put a finger to their lips, then point down. It appears the ghoulish monsters are yet attacking because they\'re unaware? You\'re not sure, you just know that the %companyname% only has one way in and that will be by the sword! | Luckily, you find %objective% still standing. Unluckily, the walls are being battered by a crowd of pale undead. The %companyname% will have to fight its way in!}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult()
					{
						this.Contract.spawnUndeadAtTheWalls();
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ADireSituation",
			Title = "At %objective%...",
			Text = "[img]gfx/ui/events/event_79.png[/img]{You find the clan warriors inside %objective% looking like they hadn\'t slept in weeks, but they are smiling. Apparently, your awkward trip through to their front gate was of at least some amusement.\n | Bumbling and trundling as they are, the %companyname% finally passes through the front gate. Inside, the clan warriors are standing with amused despondence, looking like they just stepped out of a horrific battle to be witnesses to a strange joke. One claps you on the shoulder.%SPEECH_ON%That was awfully funny to watch and I think we needed the lift. Thank you.%SPEECH_OFF% | Taking a look around, you see the clan warriors are frail, bony men standing watch over villagers who look almost half-dead already. The muddied roads are littered with shite, garbage, and animal carcasses. Women and children weep at a makeshift graveyard: a ditch with a scroll of names penned above it, ink freshly renewed for another addition. | You enter through the gates of %objective% and find a few clan warriors standing guard with thin hands tented atop spears. Their clothes shift about their bones like curtains astride an open window. The sense of hunger lingers thick in the air, reflected in the lip-smacking stares you\'re getting for just being here in good health. One of the defenders greets you warmly enough.%SPEECH_ON%We\'re tired and a wee bit hungry, but we\'ll manage. The fight is still in us, don\'t you doubt that.%SPEECH_OFF% | When you enter through the gates of %objective%, a dog is the first to greet you, licking your legs and sniffing deeply up your trousers. A man suddenly comes hollering, club raised, and soon man and animal go skittering down the muddied road, both seemingly barking. The mutt dodges the slow tackles of a hungry crowd and disappears entirely. A grinning man walks over, using a stick to balance himself.%SPEECH_ON%Evenin\', warrior. Food stocks are a bit low and that there doggo is fair game in a land of empty bellies.%SPEECH_OFF%You ask if they can still fight and the man laughs.%SPEECH_ON%Hell, a fight\'s all we got left!%SPEECH_OFF%}{From chieftain\'s hall, a large man comes out, you guess it must be %origin_chieftain%, himself. He\'s wearing heavy armor, bent in many places and covered in dry blood. It has obviously seen better days. %SPEECH_ON%You are most welcome warriors! I see that %townname% has sent someone to help us. That is good and you will be rewarded, if we all survive this.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We need to prepare for the coming onslaught...",
					function getResult()
					{
						this.Flags.set("Wave", 1);
						this.Flags.set("TimeWaveHits", this.Time.getVirtualTimeF() + 8.0);
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Wave1",
			Title = "At %objective%...",
			Text = "[img]gfx/ui/events/event_73.png[/img]{The wait is about to kill you when something else appears to do the job: the undead! %objective%\'s bells start ringing and the guards rush to action with a sort of unhinted liveliness. %origin_chieftain% puts his helmet on, grabs his weapon and starts moving to the outskirts of the camp. You order the %companyname% to prepare for battle. | A scout limps in to %objective%, he\'s cradling a handless arm and his face has been carved free of an ear and eye. The %origin_chieftain% rushes over and the two talk before the scout passes out. Sighing, the chieftain comes to stand.%SPEECH_ON%The undead are attacking, prepare yourselves!%SPEECH_OFF%You nod and order the %companyname% to ready itself for battle. | You set down next to the %origin_chieftain%. He breaks bread.%SPEECH_ON%It\'s been awfully quiet since you got here.%SPEECH_OFF%Taking a bite, you ask if he\'s suggesting you\'re a double-agent for the dead. He laughs.%SPEECH_ON%Can\'t be too sure these days.%SPEECH_OFF%Just then, a bell tower tolls and all the clan warriors start rushing. Yelling and screaming erupt. The undead are attacking!\n\n The chieftain throws his helmet on and helps you up.%SPEECH_ON%Time to prove your worth, warrior.%SPEECH_OFF% | The camp is quiet, the soft crackles and pops of a fire filling the muted air. You watch as men burn a rat on a spit and start slicing off chunks to share. Seeing enough, you go up the walls to find %origin_chieftain% eyeing the horizon. %SPEECH_ON%Well fark me arseways, they\'re coming.%SPEECH_OFF%He points a direction with his finger and you see a throng of fish-eyed, warped-looking undead are shambling toward %objective%. The chieftain turns to you. %SPEECH_ON%Time to earn your pay, warrior.%SPEECH_OFF% | One of the villagers has found a den of rats which is cause for depressingly incredible celebration. As the clanfolk cheer and weep, and the shrill cries of the rodents go into spits and fires, %origin_chieftain% comes over. He observes the scene with a smile, but it fades when a high-pitched scream breaks the air. Everyone turns to the outskirts of the camp where one of the guards is pointing toward the horizon. Even from where you\'re standing you can see the whites in his frightened eyes.%SPEECH_ON%The dead are comin\'! They\'re comin\' to kill us all! We ain\'t have enough men!%SPEECH_OFF%The chieftain tells the man to grow some balls, then quietly turns to you.%SPEECH_ON%Prepare your men, warrior, and prove you\'re worthy of your ancestors. If you are not, then we\'ll all join them soon.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Defend the camp!",
					function getResult()
					{
						this.Contract.setState("Running_Wave");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Wave2",
			Title = "At %objective%...",
			Text = "",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Defend the camp!",
					function getResult()
					{
						this.Contract.setState("Running_Wave");
						return 0;
					}

				}
			],
			
			function start()
			{
				this.Text = "[img]gfx/ui/events/event_73.png[/img]{As the %companyname% rests, cleaning sickly slough off their blades, another signal comes from the bell tower. The undead are attacking again! | You watch as %randombrother% scrubs his blades of pale flesh and sopped clothing.%SPEECH_ON%By the old gods do they leave a mess.%SPEECH_OFF%Just then, a watchman whistles and barks out that the undead are attacking again! The warrior angrily flings a strand of brain off his weapon.%SPEECH_ON%And just as I was starting to see my reflection!%SPEECH_OFF%You help the man to his feet, clapping him on the shoulder.%SPEECH_ON%Trust me, you ain\'t missing much.%SPEECH_OFF% | One of the clan warriors breaks a hard roll into crumbs and starts doling out the scraps. Another warrior asks where he got it and the man answers bluntly.%SPEECH_ON%Found it in the pockets of one of them dead fellas.%SPEECH_OFF%The eaters spit out the food and one even vomits. You watch as the men start fighting, but it\'s quickly broken up by the whistle of a watchman.%SPEECH_ON%Here they come again! To battle!%SPEECH_OFF%Prepare for battle and try hard to not loot food off corpses that see you yourself as lunch. | As your men rest and recuperate, one of the watchman calls out.%SPEECH_ON%Here they come again!%SPEECH_OFF%War rarely gives one a proper break, especially wars with the undead. | You see %randombrother% wiping his face with mud. He pauses, glancing at your staring.%SPEECH_ON%Mudbath, sir. You know, to clean off the... bloodbath.%SPEECH_OFF%You roll your eyes. Just then, the town bell starts bonging and a watchman calls out, having sighted another attack on the way! You tell the warrior to finish up his \'bath\' and get ready for battle. | You find %randombrother% washing strings of grey innards out from behind his ears.%SPEECH_ON%Momma always said get behind yer ears, but I don\'t think she foresaw this mess!%SPEECH_OFF%You tell him a good mother foresees all. The man laughs and nods.%SPEECH_ON%Yeah, she\'d just yell at me and ask where I got that mess from!%SPEECH_OFF%Just then, one of the watchmen along the towers calls out that the undead are attacking again. You turn to the warrior.%SPEECH_ON%Well, time to get ourselves dirty again.%SPEECH_OFF% | You find one of the peasants carving lines into a stonewall. Seeing you, he explains himself.%SPEECH_ON%Just accounting for the lost. There\'s been so many I can\'t keep their names in order, but I can count.%SPEECH_OFF%You look down the length of the wall to see that it slowly traded names for numbers.%SPEECH_ON%We do what we can to remember, you know?%SPEECH_OFF%You nod and then, as if on cue, the watchmen call out, announcing another attack is on the way. The peasant grabs you by the arm with a pleading look.%SPEECH_ON%Tell me yer name and I\'ll put it up for ya if the time comes.%SPEECH_OFF%You yank your arm free and glare at the man, shrinking him down with a furious stare.%SPEECH_ON%I\'m a killer you fool and I have no intention of being killed, certainly not by those that are already dead!%SPEECH_OFF%The man nods. You nod back and leave to prepare your warriors for battle. | Just as you and the men settle down for a rest, the watchmen holler out and the town bell begins to toll. Another attack is on the way! You order the %companyname% to prepare for battle.";
				if(!this.Flags.get("ChieftainDead"))
				{
					this.Text += " | The %origin_chieftain% goes around making sure his men are resting and drinking water. Just as he gets to you for a talk, the town bell tolls and the watchman hollers out that another attack is coming! You grin and clap the chieftain on the shoulder.%SPEECH_ON%We just do what we\'re supposed to. Nothing simpler, right?%SPEECH_OFF%He nods and goes to get his men prepared. | You walk to the %objective%\'s outskirts and find the %origin_chieftain%. He sighs.%SPEECH_ON%They\'re attacking. Again.%SPEECH_OFF%You stare toward the horizon and, indeed, there\'s another wave on its way. The lieutenant goes to collect his men for another fight and you do the same.";
				}
				
				this.Text += "}";
			}
		});
		
		this.m.Screens.push({
			ID = "Wave3",
			Title = "At %objective%...",
			Text = "[img]gfx/ui/events/event_73.png[/img]{}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Defend the camp!",
					function getResult()
					{
						this.Contract.setState("Running_Wave");
						return 0;
					}

				}
			],
			function start()
			{
				this.Text = "[img]gfx/ui/events/event_73.png[/img]{";
				this.Text += "As all the fighters rest, one of the watchman, his voice hoarse, yells out, defeated and despondent.%SPEECH_ON%Again. Here they come... again.%SPEECH_OFF%The %companyname% must rise to the challenge if %objective% is to survive! | One of the watchmen spots another attack coming! The man screams out so hard his voice breaks and he passes out. %objective%\'s warriors are at their wit\'s end, hopefully this is the last of the assaults! | You stand at the walls of %objective% and look across the horizon. Another attack is coming, but there\'s no excitement in facing it. No screaming, no hysterics. Not anymore. It simply comes. A bulbous, shuffling ill-shapen army of corpses, bubbling and trundling forth, asking for yet another lancing. You order the %companyname% to prepare themselves. %randombrother% incredulously opens his arms, half his body caked in the sopping remains of undead torn asunder.%SPEECH_ON%Chief, I think we got it.%SPEECH_OFF%The men laugh and laugh, the clan warriors joining in, and soon the hilarity fills the air, in part joined by the groaning of an increasingly close undead, madness made legion. | %randombrother% walks over to a campfire, drawing long strands of innards off his shoulders and slinging them away. A peasant eyes the viscera as though he\'s about one stomach growl away from taking a bite. The warrior sits down with a discomfited plop.%SPEECH_ON%If I see one more corpse walking at me like it\'s lunchtime I\'m gonna...%SPEECH_OFF%Before he can even finish the sentence, a watchman along the walls gasses himself out on a horn, bellowing a warning for all to hear. He drops it at his side, face red and out of breath.%SPEECH_ON%The... undead... they\'re attacking again!%SPEECH_OFF%The warrior\'s face goes dead still. He stands up and, not saying a word, slowly goes to arm himself.";
				if(!this.Flags.get("ChieftainDead"))
				{
					this.Text += "| A watchman whistles out a warning that more undead are coming. %origin_chieftain% shakes his head.%SPEECH_ON%By the old gods, will they ever stop coming? You\'re truly earning your keep this day.%SPEECH_OFF%You think to joke about how you should earn more, but it just doesn\'t seem like a good time. Instead, you nod and go off to prepare the %companyname% for another battle. | While you and %origin_chieftain% exchange war stories, one of clan warriors comes up. You notice that he\'s the man supposed to be watching the outskirts. He talks bluntly.%SPEECH_ON%Chief, they\'re attacking again.%SPEECH_OFF%And just like that he turns on his heels and marches toward the armory. You get up and help the chieftain to his feet. He claps you on the shoulder with a terse, solemn smile.%SPEECH_ON%Into the fray again, huh?%SPEECH_OFF%You can only shrug.%SPEECH_ON%This is what we are here for. See you on the field, chief.%SPEECH_OFF% | You stare on the outskirts of %objective% and see another wave of undead coming. All the excitement of previous attacks has gone. Now the defenders silently watch as the corpses shamble and shuffles onward. %origin_chieftain% comes to your side.%SPEECH_ON%It has been an honor fighting by your side, warrior.%SPEECH_OFF%You nod and respond.%SPEECH_ON%Mmm, honor, of course.%SPEECH_OFF%The chieftain eyes you.%SPEECH_ON%You\'re thinking about your pay, aren\'t you?%SPEECH_OFF%Nodding again, you respond.%SPEECH_ON%I\'m thinking about what it\'ll buy: a warm bed, a warmer meal, and an even warmer wench.%SPEECH_OFF% | You meet the %origin_chieftain% on the outskirts of the camp. He\'s sharing bread with some of his warriors and offers you a piece. You decline and ask what\'s on the horizon. The chieftain points out toward the field.%SPEECH_ON%Oh, not much, they\'re just attacking again.%SPEECH_OFF%Indeed, you see a huge crowd of corpses shambling toward %objective%. You turn toward the chieftain and ask the man why weren\'t the alarms raised. He shrugs.%SPEECH_ON%Giving the men an extra minute or two. The walking dead might want to kill us all, but they\'re not in a hurry about it, you know?%SPEECH_OFF%Understandable. You go ahead and have that bread on offer, then after another minute or two you go and prepare the %companyname% for battle.";
				}
				
				this.Text += "}";
			}
		});
		this.m.Screens.push({
			ID = "ChieftainDead",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{You\'ve won the day, but the folk of %objective% have probably lost the war. %origin_chieftain% fell in battle and didn\'t get up. With their chieftain gone, many of the clansfolk are packing to leave the village altogether rather than stay and help defend. You think about doing the same but then notice an old man approaching you. He introduces himself as one of the clan elders.%SPEECH_ON%I know what you are thinking, warrior. Everybody is leaving, so why stay and fight. I\'ve been living here my whole life and I am not about to go now. If you stay and help us survive, I will see that you still get your reward.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "A victory nontheless.",
					function getResult()
					{
						this.Flags.set("Wave", this.Flags.get("Wave") + 1);
						this.Flags.set("ChieftainDeadShown", true);
						this.Flags.set("TimeWaveHits", this.Time.getVirtualTimeF() + 3.0);
						this.Flags.set("Militia", 3);
						this.Flags.set("MilitiaStart", 3);
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		
		this.m.Screens.push({
			ID = "Militia1",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_46.png[/img]{You\'ve won the day, but the folk of %objective% have probably lost the war: their warriors took so many losses, even more villagers are packing to leave the village altogether rather than stay and help defend!}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "A victory nontheless.",
					function getResult()
					{
						this.Flags.set("Wave", this.Flags.get("Wave") + 1);
						this.Flags.set("TimeWaveHits", this.Time.getVirtualTimeF() + 3.0);
						this.Flags.set("Militia", 3);
						this.Flags.set("MilitiaStart", 3);
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Militia2",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_46.png[/img]{You\'ve taken the day, but the undead made you pay for it dearly. However the clan warriors are still in good number and willing to defend their homes.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "A victory nontheless.",
					function getResult()
					{
						this.Flags.set("Wave", this.Flags.get("Wave") + 1);
						this.Flags.set("TimeWaveHits", this.Time.getVirtualTimeF() + 3.0);
						this.Flags.set("Militia", 6);
						this.Flags.set("MilitiaStart", 6);
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Militia3",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_80.png[/img]{The undead have been so thoroughly defeated that some of the villagers have decided to take up arms and help in battles to come.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Victory!",
					function getResult()
					{
						this.Flags.set("Wave", this.Flags.get("Wave") + 1);
						this.Flags.set("TimeWaveHits", this.Time.getVirtualTimeF() + 3.0);
						this.Flags.set("Militia", 8);
						this.Flags.set("MilitiaStart", 8);
						this.Contract.setState("Running_Wait");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Ghouls",
			Title = "At %objective%...",
			Text = "[img]gfx/ui/events/event_69.png[/img]{As you prepare for the fight, you notice odd shapes bumbling around the ranks of undead: nachzehrers. The ceatures must be following the hordes to feed on whatever they kill, like seagulls following a fishing boat on the sea. | Nachzehrers! The foul creatures are seen trotting and loping amidst the crowds of corpses, the damned beasts looking for their next meal, no doubt. | The undead leave a lot of dead and dying in their wake and, unsurprisingly, scavengers have started following them. In this case, they\'re nachzehrers, the ugly beasts growling and snarling as they hungrily anticipate their next meal. | If you raid a pantry, the mice are sure to come. Now that the undead are attacking %objective%, they\'ve acquired a retinue of scavengers in their wake: nachzehrers.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Defend the camp!",
					function getResult()
					{
						this.Contract.setState("Running_Wave");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TheAftermath",
			Title = "After the battle...",
			Text = "",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We did it!",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			],
			function start()
			{
				if (this.Flags.get("ChieftainDead") && !this.Flags.get("ChieftainDeadShown"))
				{
					this.Text = "[img]gfx/ui/events/event_46.png[/img]{You stare over the battlefield. It is littered with the dead, the dying, the undying, and the dying undying. Men, of the living, breathing sort, march about the muck, finishing off anything that remotely resembles a reanimation. Among the dead, you notice the body of %origin_chieftain%. You\'ll need to find someone else to sort out your payment. | The battle is over and the %objective% saved, but %origin_chieftain% did not survive the battle. Still someone should be in charge and offer you a hell of a payday.}";
				}
				else if (this.Flags.get("ChieftainDead"))
				{
					this.Text = "[img]gfx/ui/events/event_46.png[/img]{You stare over the battlefield. It is littered with the dead, the dying, the undying, and the dying undying. Men, of the living, breathing sort, march about the muck, finishing off anything that remotely resembles a reanimation. With the fight over, and the camp saved, you need to sort out payment with the elder. | The battle is over and the %objective% saved. Time to find the elder for a hell of a payday.}";
				}
				else
				{
					this.Text = this.Text = "[img]gfx/ui/events/event_46.png[/img]{You stare over the battlefield. It is littered with the dead, the dying, the undying, and the dying undying. Men, of the living, breathing sort, march about the muck, finishing off anything that remotely resembles a reanimation. With the fight over, and the camp saved, you need to sort out payment with %origin_chieftain%. | The battle is over and the %objective% saved. Time to find %origin_chieftain% for a hell of a payday.}";
				}
			}
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "On your return...",
			Text = "",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "%objective% is saved.",
					function getResult()
					{
						local payment = this.Contract.m.Payment.getOnCompletion();
						if (!this.Flags.get("ChieftainDead"))
						{
							payment = this.Math.round(payment * 1.2);
						}
						else
						{
							this.Contract.m.Origin.changeChieftain();
						}
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(payment);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Defended " + this.Flags.get("ObjectiveName") + " against undead");
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
				local payment = this.Contract.m.Payment.getOnCompletion();
				if (!this.Flags.get("ChieftainDead"))
				{
					payment = this.Math.round(payment * 1.2);
				}
				
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + payment + "[/color] Crowns"
				});
				this.Contract.m.SituationID = this.Contract.resolveSituation(this.Contract.m.SituationID, this.Contract.m.Origin, this.List);
				
				
				if (this.Flags.get("ChieftainDead") && !this.Flags.get("ChieftainDeadShown"))
				{
					this.Text = "[img]gfx/ui/events/event_04.png[/img]{The battle may have been won, but chieftain of %objective% is dead. There is a large gathering of clansfolk in front of his home, where men carried his body. From the crowd emerges an old man and warmly greets you, introducing himself as one of the clan elders. %SPEECH_ON%You saved us and even though our chieftain fell in battle, I am most grateful for your efforts. I believe this is the gold you were promised.%SPEECH_OFF%}";
				}
				else if (this.Flags.get("ChieftainDead"))
				{
					this.Text = "[img]gfx/ui/events/event_04.png[/img]{You find the elder in front of the late chieftain\'s home. His clothes are dirty, covered in mud, blood and gore, a large hammer rests on the ground next to him. Upon seeing you, he greets you warmly and offers you a handshake.%SPEECH_ON%You did well, warrior, really well. You saved %objective% and the its people and for that I am most grateful. I believe this is the gold you were promised.%SPEECH_OFF%}";
				}
				else
				{
					this.Text = this.Text = "[img]gfx/ui/events/event_04.png[/img]{You find %origin_chieftain% in front of his home. He\'s still in his armor that looks even worse than the last time you saw him. Upon seeing you, he rushes to embrace you, his strong amrs curling around your body.%SPEECH_ON%You did well, warrior, really well. You saved %objective% and the its people and for that I am most grateful. I believe you\'ve earned a bit of extra on your payment.%SPEECH_OFF%}";
				}
				
				this.Contract.m.Origin.getFlags().set("nem_last_stand_cooldown", this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * this.Contract.m.SafeCooldown);
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "Around %objective%",
			Text = "[img]gfx/ui/events/event_30.png[/img]{The undead were too many and you had to retreat. Unfortunately, a whole village doesn\'t have such liberties and so %objective% was completely overrun. You didn\'t stick around to see what became of its people, though it doesn\'t take a genius to guess. | The %companyname% has been defeated in the field by the hordes of undead! In the wake of your failure, %objective% is quickly overrun. A mass of peasants run from the camp and those too slow are added to the sea of shambling corpses. | You failed to hold back the undead! The corpses slowly shuffle through the outskirts of %objective% and eat and kill all that they come across. As you flee the field, you see the clan chieftain shuffling alongside the horde of corpses.}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = false,
			Options = [
				{
					Text = "%objective% has fallen.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to defend " + this.Flags.get("ObjectiveName") + " against undead");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
	}

	function spawnWave()
	{
		local undeadBase = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getNearestSettlement(this.m.Origin.getTile());
		local originTile = this.m.Origin.getTile();
		local tile;

		while (true)
		{
			local x = this.Math.rand(originTile.SquareCoords.X - 5, originTile.SquareCoords.X + 5);
			local y = this.Math.rand(originTile.SquareCoords.Y - 5, originTile.SquareCoords.Y + 5);

			if (!this.World.isValidTileSquare(x, y))
			{
				continue;
			}

			tile = this.World.getTileSquare(x, y);

			if (tile.getDistanceTo(originTile) <= 4)
			{
				continue;
			}

			if (tile.Type == this.Const.World.TerrainType.Ocean)
			{
				continue;
			}

			local navSettings = this.World.getNavigator().createSettings();
			navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost_Flat;
			local path = this.World.getNavigator().findPath(tile, originTile, navSettings, 0);

			if (!path.isEmpty())
			{
				break;
			}
		}

		local party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).spawnEntity(tile, "Undead Horde", false, this.Const.World.Spawn.UndeadArmy, (80 + this.m.Flags.get("Wave") * 10) * this.getDifficultyMult() * this.getScaledDifficultyMult());
		this.m.UnitsSpawned.push(party.getID());
		party.getLoot().ArmorParts = this.Math.rand(0, 15);
		party.getSprite("banner").setBrush(undeadBase.getBanner());
		party.setDescription("A legion of walking dead, back to claim from the living what was once theirs.");
		party.setFootprintType(this.Const.World.FootprintsType.Undead);
		party.setSlowerAtNight(false);
		party.setUsingGlobalVision(false);
		party.setLooting(false);
		party.setAttackableByAI(false);
		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		local move = this.new("scripts/ai/world/orders/move_order");
		move.setDestination(originTile);
		c.addOrder(move);
		local attack = this.new("scripts/ai/world/orders/attack_zone_order");
		attack.setTargetTile(originTile);
		c.addOrder(attack);
		local destroy = this.new("scripts/ai/world/orders/nem_convert_order");
		destroy.setTime(60.0);
		destroy.setTargetLocation(this.m.Origin);
		c.addOrder(destroy);
	}

	function spawnUndeadAtTheWalls()
	{
		local undeadBase = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getNearestSettlement(this.m.Origin.getTile());
		local party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).spawnEntity(this.m.Origin.getTile(), "Undead Horde", false, this.Const.World.Spawn.ZombiesOrZombiesAndGhosts, 100 * this.getDifficultyMult() * this.getScaledDifficultyMult());
		party.setPos(this.createVec(party.getPos().X - 50, party.getPos().Y - 50));
		this.m.UnitsSpawned.push(party.getID());
		party.getLoot().ArmorParts = this.Math.rand(0, 15);
		party.getSprite("banner").setBrush(undeadBase.getBanner());
		party.setDescription("A legion of walking dead, back to claim from the living what was once theirs.");
		party.setFootprintType(this.Const.World.FootprintsType.Undead);
		party.setSlowerAtNight(false);
		party.setUsingGlobalVision(false);
		party.setLooting(false);
		party.setAttackableByAI(false)
		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		local wait = this.new("scripts/ai/world/orders/wait_order");
		wait.setTime(15.0);
		c.addOrder(wait);
		local destroy = this.new("scripts/ai/world/orders/nem_convert_order");
		destroy.setTime(90.0);
		destroy.setTargetLocation(this.m.Origin);
		c.addOrder(destroy);
		party.setOnCombatWithPlayerCallback(this.onCombatAtTheWalls.bindenv(this))
	}

	function spawnGhouls()
	{
		local originTile = this.m.Origin.getTile();
		local tile;

		while (true)
		{
			local x = this.Math.rand(originTile.SquareCoords.X - 5, originTile.SquareCoords.X + 5);
			local y = this.Math.rand(originTile.SquareCoords.Y - 5, originTile.SquareCoords.Y + 5);

			if (!this.World.isValidTileSquare(x, y))
			{
				continue;
			}

			tile = this.World.getTileSquare(x, y);

			if (tile.getDistanceTo(originTile) <= 4)
			{
				continue;
			}

			if (tile.Type == this.Const.World.TerrainType.Ocean)
			{
				continue;
			}

			local navSettings = this.World.getNavigator().createSettings();
			navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost_Flat;
			local path = this.World.getNavigator().findPath(tile, originTile, navSettings, 0);

			if (!path.isEmpty())
			{
				break;
			}
		}

		local party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).spawnEntity(tile, "Nachzehrers", false, this.Const.World.Spawn.Ghouls, 110 * this.getDifficultyMult() * this.getScaledDifficultyMult());
		this.m.UnitsSpawned.push(party.getID());
		party.getSprite("banner").setBrush("banner_beasts_01");
		party.setDescription("A flock of scavenging nachzehrers.");
		party.setSlowerAtNight(false);
		party.setUsingGlobalVision(false);
		party.setLooting(false);
		party.setAttackableByAI(false);
		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		local move = this.new("scripts/ai/world/orders/move_order");
		move.setDestination(originTile);
		c.addOrder(move);
		local attack = this.new("scripts/ai/world/orders/attack_zone_order");
		attack.setTargetTile(originTile);
		c.addOrder(attack);
		local destroy = this.new("scripts/ai/world/orders/nem_convert_order");
		destroy.setTime(60.0);
		destroy.setTargetLocation(this.m.Origin);
		c.addOrder(destroy);
	}
	
	function setCallbackAtTheWalls(party)
	{
		party.setOnCombatWithPlayerCallback(this.onCombatAtTheWalls.bindenv(this))
	}
	
	function onCombatAtTheWalls( _dest, _isPlayerAttacking = true )
	{
		this.m.IsPlayerAttacking = _isPlayerAttacking;
		local p = this.getCombatProperties(_dest);
		p.Music = this.Const.Music.UndeadTracks;
		p.CombatID = "ContractCombat";
		this.World.Contracts.startScriptedCombat(p, _isPlayerAttacking, true, true);
	}
	
	function getCombatProperties(party)
	{
		local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
		p.Music = this.Const.Music.UndeadTracks;
		p.CombatID = "ContractCombat";
		p.Entities = [];
		foreach( t in party.getTroops() )
		{
			if (t.Script != "")
			{
				t.Faction <- party.getFaction();
				t.Party <- this.WeakTableRef(party);
				p.Entities.push(t);
			}
		}
		p.AllyBanners = [
			this.World.Assets.getBanner()
		];
		return p;
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"objective",
			this.m.Flags.get("ObjectiveName")
		]);
		_vars.push([
			"direction",
			this.m.Origin == null || this.m.Origin.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Origin.getTile())]
		]);
		
		_vars.push([
			"origin_chieftain",
			this.m.Flags.get("OriginChieftain")
		]);
		
	}

	function onOriginSet()
	{
		if (this.m.SituationID == 0)
		{
			this.m.SituationID = this.m.Origin.addSituation(this.new("scripts/entity/world/settlements/situations/besieged_situation"));
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			foreach( id in this.m.UnitsSpawned )
			{
				local e = this.World.getEntityByID(id);

				if (e != null && e.isAlive())
				{
					e.setAttackableByAI(true);
					e.setOnCombatWithPlayerCallback(null);
				}
			}

			if (this.m.Origin != null && !this.m.Origin.isNull() && this.m.Origin.hasSprite("selection"))
			{
				this.m.Origin.getSprite("selection").Visible = false;
			}

			if (this.m.Home != null && !this.m.Home.isNull() && this.m.Home.hasSprite("selection"))
			{
				this.m.Home.getSprite("selection").Visible = false;
			}
		}

		if (this.m.Origin != null && !this.m.Origin.isNull() && this.m.SituationID != 0)
		{
			local s = this.m.Origin.getSituationByInstance(this.m.SituationID);

			if (s != null)
			{
				s.setValidForDays(2);
			}
		}
	}

	function onIsValid()
	{
		if(this.m.Origin == null || this.m.Origin.isNull() || !this.m.Origin.isAlive())
		{
			return false;
		}
		
		if (!this.World.FactionManager.isUndeadScourge())
		{
			return false;
		}
		
		if (this.m.Origin.getFlags().getAsFloat("nem_last_stand_cooldown") > this.Time.getVirtualTimeF())
		{
			return false;
		}
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

