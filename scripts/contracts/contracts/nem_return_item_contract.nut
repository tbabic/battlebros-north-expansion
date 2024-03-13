this.nem_return_item_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Target = null,
		IsPlayerAttacking = true
	},
	function create()
	{
		this.contract.create();
		this.m.Type = "contract.nem_return_item";
		this.m.Name = "Return Item";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function start()
	{
		this.m.Payment.Pool = 400 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();

		this.m.Payment.Completion = 1.0;

		local items = [
			"Ceremonial Staff",
			"Idol of Fertility",
			"Lucky Talisman",
			"Ancient broken blade",
			"Sacred Statuette",
			"Horn of Giant",
			"Forefather\'s Skull"
		];
		local r = this.Math.rand(0, items.len() - 1);
		this.m.Flags.set("Item", items[r]);
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Follow the tracks near %townname%",
					"Return %item% to %townname%"
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

				if (r <= 5)
				{
					if (this.Contract.getDifficultyMult() >= 0.95)
					{
						this.Flags.set("IsNecromancer", true);
					}
					this.Flags.set("IsBandits", true);
				}
				else if (r <= 10)
				{
					this.Flags.set("IsCounterOffer", true);
					this.Flags.set("Bribe", this.Contract.beautifyNumber(this.Contract.m.Payment.getOnCompletion() * this.Math.rand(100, 300) * 0.01));
					this.Flags.set("IsBandits", true);
				}
				else if (r <= 30)
				{
					this.Flags.set("IsBandits", true);
				}
				else if (r <= 40 && this.Contract.getDifficultyMult() >= 1.15)
				{
					this.Flags.set("IsWitch", true);
					this.Flags.set("IsBarbarians", true);
					
				}
				else {
					this.Flags.set("IsBarbarians", true);
				}

				this.Flags.set("StartDay", this.World.getTime().Days);
				local playerTile = this.World.State.getPlayer().getTile();
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 5, 10, [
					this.Const.World.TerrainType.Mountains
				]);
				local party;
				if (this.Flags.get("IsBandits"))
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).spawnEntity(tile, "Thieves", false, this.Const.World.Spawn.BanditRaiders, 80 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
					party.setDescription("A group of thieves and bandits.");
					party.setFootprintType(this.Const.World.FootprintsType.Brigands);
				}
				else
				{
					party = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).spawnEntity(tile, "Thieves", false, this.Const.World.Spawn.BanditRaiders, 80 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
					party.setDescription("A group of sturdy northmen.");
					party.setFootprintType(this.Const.World.FootprintsType.Barbarians);
				}
				
				
				
				party.setAttackableByAI(false);
				party.getController().getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				party.setFootprintSizeOverride(0.75);
				this.Const.World.Common.addFootprintsFromTo(this.Contract.m.Home.getTile(), party.getTile(), this.Const.GenericFootprints, this.Const.World.FootprintsType.Brigands, 0.75);
				this.Contract.m.Target = this.WeakTableRef(party);
				party.getSprite("banner").setBrush("banner_bandits_0" + this.Math.rand(1, 6));
				local c = party.getController();
				local wait = this.new("scripts/ai/world/orders/wait_order");
				wait.setTime(9000.0);
				c.addOrder(wait);
				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Follow the tracks %direction% of %townname%",
					"Return %item% to %townname%"
				];

				if (this.Contract.m.Target != null && !this.Contract.m.Target.isNull())
				{
					this.Contract.m.Target.getSprite("selection").Visible = true;
					this.Contract.m.Target.setOnCombatWithPlayerCallback(this.onTargetAttacked.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Target == null || this.Contract.m.Target.isNull())
				{
					if (this.Flags.get("IsCounterOffer"))
					{
						this.Contract.setScreen("CounterOffer1");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("BattleDone");
						this.World.Contracts.showActiveContract();
						this.Contract.setState("Return");
					}
				}
				else if (this.World.getTime().Days - this.Flags.get("StartDay") >= 3 && this.Contract.m.Target.isHiddenToPlayer())
				{
					this.Contract.setScreen("Failure1");
					this.World.Contracts.showActiveContract();
				}
			}

			function onTargetAttacked( _dest, _isPlayerAttacking )
			{
				if (!this.Flags.get("IsAttackDialogTriggered"))
				{
					if (this.Flags.get("IsNecromancer"))
					{
						this.Flags.set("IsAttackDialogTriggered", true);
						this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
						this.Contract.setScreen("Necromancer");
						this.World.Contracts.showActiveContract();
					}
					if (this.Flags.get("IsWitch"))
					{
						this.Flags.set("IsAttackDialogTriggered", true);
						this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
						this.Contract.setScreen("Witch");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Flags.set("IsAttackDialogTriggered", true);
						this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
						this.Contract.setScreen("Bandits");
						this.World.Contracts.showActiveContract();
					}
				}
				else
				{
					this.World.Contracts.showCombatDialog(_isPlayerAttacking);
				}
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Return %item% to %townname%"
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
		this.importScreens(this.Const.Contracts.NegotiationDefault);
		this.importScreens(this.Const.Contracts.Overview);
		this.m.Screens.push({
			ID = "Task",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_20.png[/img]{%employer% restlessly walks back and forth while explaining what troubles him.%SPEECH_ON%There has been an audacious act of thievery! A group of thieves stole my %itemLower% which is of immeasurable value to me. I implore you to hunt down those bastards and return that item to me.%SPEECH_OFF%He lowers his voice to an insisting tone.%SPEECH_ON%Not only will you get paid handsomely, but you would also set the worried minds of the good people of %townname% to rest!%SPEECH_OFF% | %employer%\'s turning an apple in hand. He seems frustrated with it, almost as if he wishes it were something else like a valuable trinket or perhaps just a tastier fruit.%SPEECH_ON%Have you ever lost something you loved?%SPEECH_OFF%You shrug and answer.%SPEECH_ON%There was this girl...%SPEECH_OFF%The man shakes his head.%SPEECH_ON%No, not some woman. More important. Because I have! Thieves stole my %itemLower%. How they managed to do get beyond my warriors is, well, beyond me. But I know if I set you on them I\'ll be having what is rightfully mine back where it belongs. Isn\'t that right? Or have I been mislead as to the quality of your men?%SPEECH_OFF% | A dog is snoring at the feet of %employer%. He leans forward to gently pet the hound behind its ears.%SPEECH_ON%I hear you have a nose for finding people, warrior. For... solving problems.%SPEECH_OFF%You nod. It is true, after all.%SPEECH_ON%Good... good... I have a task for you. A simple one. Something of great value to me has been stolen, my %itemLower%. I need you to track down those who stole it, kill them, obviously, and then bring back the item.%SPEECH_OFF% }",
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
			ID = "Bandits",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_80.png[/img]{Brigands! Just as your employer had thought. They look scared, presumably understanding that %employer%\'s well-paid wrath is about to descend upon them. | Ah, the thieves are quite human - a simple crew of vagabonds and brigands. They arm themselves as you order your men to attack. | You catch a group of brigands lugging your employer\'s property around. They seem shocked that you have found them here and no time is wasted trying to parlay - they arm themselves and you order the %companyname% to charge.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To Arms!",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Barbarians",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_80.png[/img]{You follow the tracks and finally find the thieves. They are from one of the northern clans. They don\'t seem particularly worried that you found them as they grab their weapons and ready themselves for a fight. You order your men to charge.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To Arms!",
					function getResult()
					{
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Necromancer",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_76.png[/img]{There\'s brigands here, just as expected, but they are handing the %itemLower% to a man in dark, ragged clothes. Your presence, unsurprisingly, brings a halt to the transaction and both the thugs and the ghoulish figure take up weapons. | %employer%\'s property is being sold off by brigands to a pale man in black! He glares at you before anyone else, his beady black eyes narrowing on your company in an instant.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To Arms!",
					function getResult()
					{
						this.Const.World.Common.addTroop(this.Contract.m.Target, {
							Type = this.Const.World.Spawn.Troops.Necromancer
						});
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Witch",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_76.png[/img]{You follow the tracks and finally find the thieves. They are raiders from one of the northern clans, but it looks like they are not alone. There is a beautiful woman among them and the men seem strangely obedient to her. Still, you have a job to do and you order your men to charge}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To Arms!",
					function getResult()
					{
						this.Const.World.Common.addTroop(this.Contract.m.Target, {
							Type = this.Const.World.Spawn.Troops.Hexe
						});
						this.Contract.getActiveState().onTargetAttacked(this.Contract.m.Target, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CounterOffer1",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_76.png[/img]{You clean the blood off your sword and then go to retrieve the item. As you bend over to pick it up, you spot a man watching you in the distance. He comes forth, his two hands totemed together with long sleeves.%SPEECH_ON%I see you\'ve killed my benefactor\'s men.%SPEECH_OFF%Sheathing your sword, you nod at the man. He continues.%SPEECH_ON%My benefactor paid good money for that artifact. It appears those he paid are no longer owed, so maybe I can speak to you directly. I will give you %bribe% crowns for the item.%SPEECH_OFF%That... is a good amount of money. %employer%, however, will not be happy if you decide to accept... | After the battle, a man emerges from a tree line, clapping his hands together.%SPEECH_ON%I paid those men a great deal of crowns, but it appears I should have paid you. And now that all these skeevy brigands are dead, I can!%SPEECH_OFF%You tell the man to get to the point before you run him through with a sword. He gestures toward the artifact.%SPEECH_ON%I\'ll pay you %bribe% crowns for the item. It was what was originally owed to these thieves, plus a little more. What do you say?%SPEECH_OFF%%employer% won\'t take kindly to your betrayal, but that is a good bit of money... | The battle over, you pick up the %itemLower% and look it over. Was this really worth the lives of so many people?%SPEECH_ON%I know what you\'re thinking, warrior.%SPEECH_OFF%The voice breaks in. You draw your sword and aim it at a stranger who has seemingly appeared from nowhere.%SPEECH_ON%You\'re thinking, what if someone paid good money to steal that there artifact? What if that someone would pay me a good deal of money? Perhaps... more than the man who paid you to retrieve it in the first place.%SPEECH_OFF%You lower your weapon and nod.%SPEECH_ON%An interesting thought.%SPEECH_OFF%The man smiles.%SPEECH_ON%%bribe% crowns. That\'s how much I\'ll give you for it. That was the thieves\' share plus extra. A more than fair deal. Of course, your employer will be most unhappy, but... well, that\'s not my choice to make.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "I know a good deal when I see one. Hand over the crowns.",
					function getResult()
					{
						this.updateAchievement("NeverTrustAWarrior", 1, 1);
						return "CounterOffer2";
					}

				},
				{
					Text = "We\'re paid to return it, and that\'s what we\'ll do.",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CounterOffer2",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_76.png[/img]You hand over the %itemLower% and the stranger slips you a very heavy, very drooping satchel. The deal is done. It\'s safe to assume that %employer%, your employer, won\'t be happy about this.",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Good pay.",
					function getResult()
					{
						this.World.Assets.addMoney(this.Flags.get("Bribe"));
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to return stolen " + this.Flags.get("Item"));
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Flags.get("Bribe") + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "BattleDone",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_22.png[/img]{The battle over, you retrieve the %itemLower% from the wasted clutches of your enemies and prepare to return to %employer%. He will surely be happy to see of your success! | Those who stole the %itemLower% are dead, and thankfully you were able to find the item itself. %employer% will be most pleased with your work here. | Well, you found those responsible for stealing the %itemLower% and put them to the sword. Now you just need to put the %itemLower% back into %employer%\'s hands and get your reward! | The battle is done and the %itemLower% was easy to find amongst the corpses of your enemies. You should probably return it to %employer% for your just reward!}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Let\'s collect our pay.",
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
			Text = "[img]gfx/ui/events/event_04.png[/img]{%employer% takes the %itemLower% from you, hugging it close as though he\'d retrieved a lost child. His eyes get a little teary just looking at his artifact.%SPEECH_ON%Thank you, warrior. This means a lot to me... I mean, uh, the clan. You have our gratitude!%SPEECH_OFF%He pauses as you stare at him. His eyes bounce to a corner of the room.%SPEECH_ON%Our... gratitude, warrior...%SPEECH_OFF%A large wooden chest is opened by a guard. You count the crowns and go. | %employer% grins as you enter.%SPEECH_ON%Warrior, my warrior, will you tell me word of your success?%SPEECH_OFF%You take out the artifact and place it on his table.%SPEECH_ON%Sure.%SPEECH_OFF%The man jolts forward in his chair and takes the item away. He turns back to you, calming himself and returning his composure.%SPEECH_ON%Good. You did good. Very good. %reward_completion% crowns, as promised.%SPEECH_OFF%He hands over a sack of coins.}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractSuccess, "Returned stolen " + this.Flags.get("Item"));
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
			}

		});
		this.m.Screens.push({
			ID = "Failure1",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_75.png[/img]{You lower yourself to the earth, letting some dirt filter through your fingers. But it is only dirt - there are no footprints that have crossed its path. In fact, you haven\'t seen any footprints in a good while. %randombrother% joins you, crouching low and shrugging.%SPEECH_ON%Sir, I think we lost \'em.%SPEECH_OFF%You nod. %employer% won\'t be happy about this, but it is what it is. | You\'ve been following the trail of the stolen %itemLower% for a good while now, but the leads have dried up. The commoners you pass know nothing, and the earth shows no footprints with which to track. For all intents and purposes, the %itemLower% is gone. %employer% will not be pleased. | A footprint left long enough is soon stepped on by another. And another. And another. You spent so long catching up to the thieves who stole the %itemLower% that the circuitry of the world, ever busy, has covered their tracks. You\'ve no hope of finding them now and %employer% will be most displeased. | The tracks of the the %itemLower%\'s thieves have gone dry. The last set of footprints you followed took you to a homestead, and they didn\'t look like the thieving sort, nor did they know of any such fellows. %employer% won\'t be happy about the loss of his goods, but there\'s little you can do here now.}",
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
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationCivilianContractFail, "Failed to return stolen " + this.Flags.get("Item"));
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"direction",
			this.m.Target == null || this.m.Target.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Target.getTile())]
		]);
		_vars.push([
			"item",
			this.m.Flags.get("Item")
		]);
		_vars.push([
			"itemLower",
			this.m.Flags.get("Item").tolower()
		]);
		_vars.push([
			"bribe",
			this.m.Flags.get("Bribe")
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

