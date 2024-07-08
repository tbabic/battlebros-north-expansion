this.nem_privateering_contract <- this.inherit("scripts/contracts/barbarian_contract", {
	m = {
		Item = null,
		CurrentObjective = null,
		Objectives = [],
		LastOrderUpdateTime = 0.0
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

		this.m.Type = "contract.nem_privateering";
		this.m.Name = "Great raid";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
		this.m.MakeAllSpawnsAttackableByAIOnceDiscovered = true;
	}

	function start()
	{
		local nobleHouses = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);

		local targetHouseIdxs = [];
		local southY = this.World.getMapSize().Y * 0.5;
		
		foreach (i, noble in nobleHouses)
		{
			local settlements = noble.getSettlements();
			local validTargets = 0;
			foreach( s in settlements )
			{
				if (s.getTile().SquareCoords.Y > southY)
				{
					validTargets++;
				}
			}
			if(validTargets > 0)
			{
				targetHouseIdxs.push(i);
			}
		}
		local targetIdx = this.Math.rand(0, targetHouseIdxs.len()-1);
		local targetFaction = nobleHouses[targetIdx];
		nobleHouses.remove(targetIdx);
		local employerFaction = null;
		if (this.World.FactionManager.isCivilWar())
		{
			employerFaction = nobleHouses[this.Math.rand(0, nobleHouses.len()-1)];
		}
		else
		{
			local cityStates = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.OrientalCityState);
			employerFaction = cityStates[this.Math.rand(0, cityStates.len()-1)];
		}
		
		this.m.Flags.set("EmployerFactionID", employerFaction.getID());
		this.m.Flags.set("EmployerFactionName", employerFaction.getName());
		this.m.Flags.set("TargetFactionID", targetFaction.getID());
		this.m.Flags.set("TargetFactionName", targetFaction.getName());
		this.m.Payment.Pool = 1300 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
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

		this.m.Flags.set("Score", 0);
		this.m.Flags.set("StartDay", 0);
		this.m.Flags.set("LastUpdateDay", 0);
		this.m.Flags.set("SearchPartyLastNotificationTime", 0);
		this.contract.start();
	}

	function onSortBySettlements( _a, _b )
	{
		if (_a.getSettlements().len() > _b.getSettlements().len())
		{
			return -1;
		}
		else if (_a.getSettlements().len() < _b.getSettlements().len())
		{
			return 1;
		}

		return 0;
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Flags.set("StartDay", this.World.getTime().Days);
				this.Contract.m.BulletpointsObjectives = [
					"Travel to the lands of %targetfaction%",
					"Raid and burn down places",
					"Destroy any caravans or patrols",
					"Return after 5 days"
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
				local f = this.World.FactionManager.getFaction(this.Flags.get("TargetFactionID"));
				f.addPlayerRelation(-99.0, "Took sides in the war");
				this.Flags.set("StartDay", this.World.getTime().Days);
				local nonIsolatedSettlements = [];

				foreach( s in f.getSettlements() )
				{
					if (s.isIsolated() || !s.isDiscovered())
					{
						continue;
					}

					nonIsolatedSettlements.push(s);
					local a = s.getActiveAttachedLocations();

					if (a.len() == 0)
					{
						continue;
					}

					local obj = a[this.Math.rand(0, a.len() - 1)];
					this.Contract.m.Objectives.push(this.WeakTableRef(obj));
					obj.clearTroops();

					if (s.isMilitary())
					{
						if (obj.isMilitary())
						{
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Noble, this.Math.rand(90, 120) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
						}
						else
						{
							local r = this.Math.rand(1, 100);

							if (r <= 10)
							{
								this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Mercenaries, this.Math.rand(90, 110) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
							}
							else
							{
								this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Noble, this.Math.rand(70, 100) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
							}
						}
					}
					else if (obj.isMilitary())
					{
						this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Militia, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
					}
					else
					{
						local r = this.Math.rand(1, 100);

						if (r <= 15)
						{
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Mercenaries, this.Math.rand(80, 110) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
						}
						else if (r <= 30)
						{
							obj.getFlags().set("HasNobleProtection", true);
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Noble, this.Math.rand(80, 100) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
						}
						else if (r <= 70)
						{
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Militia, this.Math.rand(70, 110) * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
						}
						else
						{
							this.Contract.addUnitsToEntity(obj, this.Const.World.Spawn.Peasants, this.Math.rand(70, 100));
						}
					}

					if (this.Contract.m.Objectives.len() >= 3)
					{
						break;
					}
				}

				local origin = nonIsolatedSettlements[this.Math.rand(0, nonIsolatedSettlements.len() - 1)];
				local party = f.spawnEntity(origin.getTile(), origin.getName() + " Company", true, this.Const.World.Spawn.Noble, 190 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				party.getSprite("body").setBrush(party.getSprite("body").getBrush().Name + "_" + f.getBannerString());
				party.setDescription("Professional soldiers in service to local lords.");
				this.Contract.m.UnitsSpawned.push(party.getID());
				party.getLoot().Money = this.Math.rand(50, 200);
				party.getLoot().ArmorParts = this.Math.rand(0, 25);
				party.getLoot().Medicine = this.Math.rand(0, 3);
				party.getLoot().Ammo = this.Math.rand(0, 30);
				local r = this.Math.rand(1, 4);

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

				local c = party.getController();
				local wait = this.new("scripts/ai/world/orders/wait_order");
				wait.setTime(9000.0);
				c.addOrder(wait);
				local r = this.Math.rand(1, 100);

				if (r <= 15)
				{
					local rival = this.World.FactionManager.getFaction(this.Flags.get("EmployerFactionID"));

					if (!rival.getFlags().get("Betrayed"))
					{
						this.Flags.set("IsChangingSides", true);
						local i = this.Math.rand(1, 18);
						local item;

						if (i == 1)
						{
							item = this.new("scripts/items/weapons/named/named_axe");
						}
						else if (i == 2)
						{
							item = this.new("scripts/items/weapons/named/named_billhook");
						}
						else if (i == 3)
						{
							item = this.new("scripts/items/weapons/named/named_cleaver");
						}
						else if (i == 4)
						{
							item = this.new("scripts/items/weapons/named/named_bardiche");
						}
						else if (i == 5)
						{
							item = this.new("scripts/items/weapons/named/named_polehammer");
						}
						else if (i == 6)
						{
							item = this.new("scripts/items/weapons/named/named_flail");
						}
						else if (i == 7)
						{
							item = this.new("scripts/items/weapons/named/named_greataxe");
						}
						else if (i == 8)
						{
							item = this.new("scripts/items/weapons/named/named_greatsword");
						}
						else if (i == 9)
						{
							item = this.new("scripts/items/weapons/named/named_javelin");
						}
						else if (i == 10)
						{
							item = this.new("scripts/items/weapons/named/named_longaxe");
						}
						else if (i == 11)
						{
							item = this.new("scripts/items/weapons/named/named_mace");
						}
						else if (i == 12)
						{
							item = this.new("scripts/items/weapons/named/named_spear");
						}
						else if (i == 13)
						{
							item = this.new("scripts/items/weapons/named/named_sword");
						}
						else if (i == 14)
						{
							item = this.new("scripts/items/weapons/named/named_throwing_axe");
						}
						else if (i == 15)
						{
							item = this.new("scripts/items/weapons/named/named_two_handed_hammer");
						}
						else if (i == 16)
						{
							item = this.new("scripts/items/weapons/named/named_warbow");
						}
						else if (i == 17)
						{
							item = this.new("scripts/items/weapons/named/named_two_handed_mace");
						}
						else if (i == 18)
						{
							item = this.new("scripts/items/weapons/named/named_warhammer");
						}

						item.onAddedToStash("");
						this.Contract.m.Item = item;
					}
				}

				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [];

				foreach( obj in this.Contract.m.Objectives )
				{
					if (obj != null && !obj.isNull() && obj.isActive())
					{
						this.Contract.m.BulletpointsObjectives.push("Destroy " + obj.getName() + " near " + obj.getSettlement().getName());
						obj.getSprite("selection").Visible = true;
						obj.setAttackable(true);
						obj.setOnCombatWithPlayerCallback(this.onCombatWithLocation.bindenv(this));
					}
				}

				this.Contract.m.BulletpointsObjectives.push("Destroy any caravans or patrols of %targetfaction%");
				this.Contract.m.BulletpointsObjectives.push("Return after %days%");
				this.Contract.m.CurrentObjective = null;
			}

			function update()
			{
				if (this.Flags.get("LastUpdateDay") != this.World.getTime().Days)
				{
					if (this.World.getTime().Days - this.Flags.get("StartDay") >= 5)
					{
						this.Contract.setScreen("TimeIsUp");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Flags.set("LastUpdateDay", this.World.getTime().Days);
						this.start();
						this.World.State.getWorldScreen().updateContract(this.Contract);
					}
				}

				if (this.Contract.m.UnitsSpawned.len() != 0 && this.Time.getVirtualTimeF() - this.Contract.m.LastOrderUpdateTime > 2.0)
				{
					this.Contract.m.LastOrderUpdateTime = this.Time.getVirtualTimeF();
					local party = this.World.getEntityByID(this.Contract.m.UnitsSpawned[0]);
					local playerTile = this.World.State.getPlayer().getTile();

					if (party != null && party.getTile().getDistanceTo(playerTile) > 3)
					{
						local f = this.World.FactionManager.getFaction(this.Flags.get("TargetFactionID"));
						local nearEnemySettlement = false;

						foreach( s in f.getSettlements() )
						{
							if (s.getTile().getDistanceTo(playerTile) <= 6)
							{
								nearEnemySettlement = true;
								break;
							}
						}

						if (nearEnemySettlement)
						{
							local c = party.getController();
							c.clearOrders();
							local move = this.new("scripts/ai/world/orders/move_order");
							move.setDestination(this.World.State.getPlayer().getTile());
							c.addOrder(move);
							local wait = this.new("scripts/ai/world/orders/wait_order");
							wait.setTime(this.World.getTime().SecondsPerDay * 1);
							c.addOrder(wait);

							if (party.getTile().getDistanceTo(playerTile) <= 8 && this.Time.getVirtualTimeF() - this.Flags.get("SearchPartyLastNotificationTime") >= 300.0)
							{
								this.Flags.set("SearchPartyLastNotificationTime", this.Time.getVirtualTimeF());
								this.Contract.setScreen("SearchParty");
								this.World.Contracts.showActiveContract();
							}
						}
					}
				}

				if (this.Flags.get("IsChangingSides") && this.Contract.getDistanceToNearestSettlement() >= 5 && this.World.State.getPlayer().getTile().HasRoad && this.Math.rand(1, 1000) <= 1)
				{
					this.Flags.set("IsChangingSides", false);
					this.Contract.setScreen("ChangingSides");
					this.World.Contracts.showActiveContract();
				}

				foreach( i, obj in this.Contract.m.Objectives )
				{
					if (obj != null && !obj.isNull() && !obj.isActive() || obj.getSettlement().getOwner().isAlliedWithPlayer() || obj.isAlliedWithPlayer())
					{
						obj.getSprite("selection").Visible = false;
						obj.setAttackable(false);
						obj.getFlags().set("HasNobleProtection", false);
						obj.setOnCombatWithPlayerCallback(null);
					}

					if (obj == null || obj.isNull() || !obj.isActive() || obj.getSettlement().getOwner().isAlliedWithPlayer() || obj.isAlliedWithPlayer())
					{
						this.Contract.m.Objectives.remove(i);
						this.Flags.set("LastUpdateDay", 0);
						break;
					}
				}
			}

			function onCombatWithLocation( _dest, _isPlayerAttacking = true )
			{
				this.Contract.m.CurrentObjective = _dest;

				if (_dest.getTroops().len() == 0)
				{
					this.onCombatVictory("RazeLocation");
					return;
				}
				else
				{
					local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					p.CombatID = "RazeLocation";
					p.LocationTemplate = clone this.Const.Tactical.LocationTemplate;
					p.LocationTemplate.Template[0] = "tactical.human_camp";
					p.LocationTemplate.Fortification = this.Const.Tactical.FortificationType.None;
					p.LocationTemplate.CutDownTrees = true;
					p.LocationTemplate.AdditionalRadius = 5;

					if (_dest.isMilitary())
					{
						p.Music = this.Const.Music.NobleTracks;
					}
					else
					{
						p.Music = this.Const.Music.CivilianTracks;
					}

					p.EnemyBanners = [];

					if (_dest.getSettlement().isMilitary() || _dest.getFlags().get("HasNobleProtection"))
					{
						p.EnemyBanners.push(_dest.getSettlement().getBanner());
					}
					else
					{
						p.EnemyBanners.push("banner_noble_11");
					}

					if (_dest.getFlags().get("HasNobleProtection"))
					{
						local f = this.Flags.get("TargetFactionID");

						foreach( e in p.Entities )
						{
							if (e.Faction == _dest.getFaction())
							{
								e.Faction = f;
							}
						}
					}

					this.World.Contracts.startScriptedCombat(p, _isPlayerAttacking, true, true);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "RazeLocation")
				{
					this.Contract.m.CurrentObjective.setActive(false);
					this.Contract.m.CurrentObjective.spawnFireAndSmoke();
					this.Contract.m.CurrentObjective.clearTroops();
					this.Contract.m.CurrentObjective.getSprite("selection").Visible = false;
					this.Contract.m.CurrentObjective.setOnCombatWithPlayerCallback(null);
					this.Contract.m.CurrentObjective.setAttackable(false);
					this.Contract.m.CurrentObjective.getFlags().set("HasNobleProtection", false);
					this.Flags.set("Score", this.Flags.get("Score") + 5);

					foreach( i, obj in this.Contract.m.Objectives )
					{
						if (obj.getID() == this.Contract.m.CurrentObjective.getID())
						{
							this.Contract.m.Objectives.remove(i);
							break;
						}
					}

					this.Flags.set("LastUpdateDay", 0);
				}
			}

			function onPartyDestroyed( _party )
			{
				if (_party.getFaction() == this.Flags.get("TargetFactionID") || this.World.FactionManager.isAllied(_party.getFaction(), this.Flags.get("TargetFactionID")))
				{
					this.Flags.set("Score", this.Flags.get("Score") + 2);
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

				foreach( obj in this.Contract.m.Objectives )
				{
					if (obj != null && !obj.isNull() && obj.isActive())
					{
						obj.getSprite("selection").Visible = false;
						obj.setOnCombatWithPlayerCallback(null);
					}
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					if (this.Flags.get("Score") <= 9)
					{
						this.Contract.setScreen("Failure1");
					}
					else if (this.Flags.get("Score") <= 15)
					{
						this.Contract.setScreen("Success1");
					}
					else
					{
						this.Contract.setScreen("Success2");
					}

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
			Text = "[img]gfx/ui/events/event_45.png[/img]{You step into %employer%\'s room and he immediately begins talking.%SPEECH_ON%Good seeing you, warrior. Just a few days ago, a messenger arrived from %employerfaction%. Apparently they need help in their war against %targetfaction%.  They want us to go into their territories and burn down everything we can get our hands on. Unfortunately fighting men are scarce right now, so I made no promises, but this sounds like something you yourself could do.%SPEECH_OFF% | %employer% is surrounded by a host of large men. One of the warriors is shouting, spraying spit as he speaks in barely understandable words.%SPEECH_ON%I have no intention of fighting knights on account of other knights. Let the arsefucks kill each other, is what I say.%SPEECH_OFF%When the shouting finally ceases, %employer% is visibly agitated, but he turns to you and says in a calm voice.%SPEECH_ON%%employerfaction% sent a messenger and they need someone to hit and raid %targetfaction%. If you were to do this, they would offer a good reward plus you get to keep the loot.%SPEECH_OFF% | %employer% is pacing through his room, his back slouched as if bearing the weight of a mountain. He doesn\'t even notice you at first, it\'s only when you greet him, that he turns to you.%SPEECH_ON%Ah, it is good that you are here, warrior.I\'m trying to organize a large raid upon %targetfaction%. There was contact with %employerfaction% and they would offer a good amount of gold on top of all the bounty. Unfortunately, right now, the men are too few and not very eager for a raid of this scale. Perhaps, this is something you could take upon yourself?%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "{How much gold are we talking about. | How much?}",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{This isn\'t worth it. | We\'re needed elsewhere. | It\'s too long a commitment for the crew.}",
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
			ID = "SearchParty",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_90.png[/img]{You near a farmstead when suddenly one of the shutters bursts open. An old lady yells in a scraggly voice while waving a white flag around. %randombrother% goes to check it out, listening to her for a time before quickly hurrying back.%SPEECH_ON%Sir, she said that %targetfaction% knows where we are and there is a large contingent of enemy forces coming for us. And yes, she used the word \'contingent.\'%SPEECH_OFF% | As you pass a homestead a little boy comes running out.%SPEECH_ON%Oooh, are you the ones going to kill the raiders?%SPEECH_OFF%You ask who told him that. The boy shrugs.%SPEECH_ON%I was footsing around the pub and heard that %targetfaction% knew where the raiders were and was sending big men to smash them good!%SPEECH_OFF%The kid claps his hands together as if he was smooshing a bug. You rub the tyke\'s hair.%SPEECH_ON%Sure, that\'s us. Now run on back home.%SPEECH_OFF%You quickly inform the %companyname% of the news. | %randombrother% comes running down one of the hillsides. He seizes up next to you, drawing for air.%SPEECH_ON%Sir, I... they...%SPEECH_OFF%He straightens up.%SPEECH_ON%I need to exercise. But that\'s not what I came to tell you! There is a very large group of enemy soldiers coming our way right this minute. I think they know exactly where we are, sir.%SPEECH_OFF%You nod and tell the men to prepare themselves. | A scouting mission reports that a huge enemy patrol seemingly knows your location and is coming now! The %companyname% should prepare themselves, whether it is to run or stand their ground and fight. | You\'ve been spotted and a large force of %targetfaction% soldiers are coming! Prepare the men as best you can, because reports state that these enemies are well armed. | %randombrother% reports to you what he\'s been hearing from some of the locals. They say a large group of soldiers carrying a banner are heading your way. You ask the mercenary to describe the sigil and he does so in great detail: it belongs to %targetfaction%\'s men. They must\'ve caught up to you somehow. The %companyname% should brace itself for a hell of a fight! | A group of women cleaning clothes in a creek ask what you\'re still doing here. You ask what they mean. One laughs, a barbarous call if there ever was one.%SPEECH_ON%Come again? We asked you what you were still doing here. You know %targetfaction%\'s coming hard for the likes of men such as ye. The way I hear it, they\'ll be on yer arse real soon.%SPEECH_OFF%You ask how they know this. One of the other ladies slaps a shirt in the creek.%SPEECH_ON%Sir, you must be dumber than hell. Rumors travel faster than any horse. Don\'t ask how. Just the way it is.%SPEECH_OFF%If what these harlots say is true, then surely the %companyname% has a great fight before them! | You step atop a hillside and give the surrounding land as good of a look as you can. Ain\'t much to the sight except for a large group of men flying the banner of %targetfaction% who seem to be stepping your way. That is one hell of a sight and pretty soon you\'ll get to see it up close and personal.\n\n Enemies have caught up to the %companyname%! You should prepare yourself for a hell of a fight on account of burning all their shite.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Be on your guard!",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TimeIsUp",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_36.png[/img]{It\'s been nearly %maxdays% now. The company should start heading back to %employer% for payment. | The company has been in the field for %maxdays% now. %employer% will be expecting your return now. | With %maxdays% spent raiding, you\'ve reached the time to return to %employer% for pay. No need to spend another second doing what you won\'t be getting paid for. | While ravaging the lands is growing on you, you are only being paid for %maxdays% work. You\'d best get back to %employer%.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Time to head back to %townname%.",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ChangingSides",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_51.png[/img]{While on the road, a man in a dark cloak slowly approaches. His face is hidden behind the hood\'s tuck of darkness. He pauses before you and puts his hands out.%SPEECH_ON%Greetings. I am a messenger of %targetfaction%. We have an offer for you. Put down your arms for %employerfaction% and leave our land. We have more than enough soldiers to defeat you, but would rather not waste the men or time hunting you down. As further incentive, I am to give you a marvellous weapon called %nameditem%.%SPEECH_OFF%You mull the idea over. Honor has value amont the northern clans and while no promise was given to %targetfaction%, %employer% will not be thrilled. Also, there will be no gold or loot, but no danger for your men either. The weapon also looks nice. | You step off the path to take a piss. While relieving yourself, a man suddenly appears out of the dripping bush, although ostensibly dry. You leap back and draw a dagger, but the man puts his hands out.%SPEECH_ON%Woe there, barbarian. I\'m a messenger of %targetfaction%. I am to suggest, and only suggest, to you an offer. Leave these land and save us the time of hunting you down. We will also give you %nameditem% as a token of good will.%SPEECH_OFF%He slowly holds out a masterfully crafted weapon. You tell him to give you a moment and go back to finish pissing. Thoughts rush through your head as something else rushes out your other head. | While getting a lay of the land, a man in a dark cloak approaches. %randombrother% grabs him by the hood and puts a blade to his neck. The man only puts his hands up and says that he\'s there to send a message from %targetfaction%. You nod and let him speak and he does so.%SPEECH_ON%We have an offer: go back home. Abandon these lands and pointless endeavours. You will only get yourself killed. However, we know that men of your kind are not keen on leaving emtpy handed. As a token of good faith, I am to give you a fine weapon called %nameditem%. If you agree, of course.%SPEECH_OFF%You carefully mull the offer as boardflipping should not be taken lightly.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "An intriguing offer. I accept.",
					function getResult()
					{
						return "AcceptChangingSides";
					}

				},
				{
					Text = "You waste your time. Begone or you\'ll hang from that tree.",
					function getResult()
					{
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "AcceptChangingSides",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_51.png[/img]{You accept the offer. The mysterious messenger takes you to a hidden copse and digs the weapon out from behind some bushes and hands it over.%SPEECH_ON%Good doing business with you, northerner.%SPEECH_OFF%It\'s fair to say that %employer_faction% completely hate you now. But they hated you before, so not much has changed. | After you accept the offer, the messenger takes you off-path to fish the weapon out from behind some bushes. Handing it over, he also shakes your hand.%SPEECH_ON%You made the right choice, barbarian.%SPEECH_OFF%%employer_faction% no doubt hates you now, probably even more than before.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Good business.",
					function getResult()
					{
						this.Contract.m.Item = null;
						local f = this.World.FactionManager.getFaction(this.m.Flags.get("EmployerFactionID"));
						f.addPlayerRelation(-f.getPlayerRelation(), "Abandoned the raid");
						f.getFlags().set("Betrayed", true);
						
						f = this.World.FactionManager.getFaction(this.Contract.getFaction());
						f.addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Abandoned the raid");
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractBetrayal);
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			],
			function start()
			{
				this.World.Assets.getStash().makeEmptySlots(1);
				this.World.Assets.getStash().add(this.Contract.m.Item);
				this.List.push({
					id = 10,
					icon = "ui/items/" + this.Contract.m.Item.getIcon(),
					text = "You gain " + this.Contract.m.Item.getName()
				});
			}

		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer% welcomes you into his room. He gives you a satchel of %reward_completion% crowns.%SPEECH_ON%Good work out there, warrior. You did just about all that could have been asked of you.%SPEECH_OFF% | You return to %employer% looking rightfully smug.%SPEECH_ON%Work\'s done.%SPEECH_OFF%He nods, raising a horn of mead, saluting your name.%SPEECH_ON%Yes, %employerfaction% is very happy with the work you\'ve done.%SPEECH_OFF%The man gestures toward the corner of the room. You see a satchel of crowns there.%SPEECH_ON%%reward_completion% crowns, just as it was agreed.%SPEECH_OFF% | %employer%\'s staring out his window when you enter. He\'s almost in a dreamstate, head bent low to his hand. You interrupt his thoughts.%SPEECH_ON%Thinking of me?%SPEECH_OFF%The man chuckles and playfully clutches his chest.%SPEECH_ON%You are truly the man of my dreams, warrior.%SPEECH_OFF%He crosses the room and takes a chest from the bookshelf. He unlatches it as he sets it on the table. A glorious pile of gold crowns stare you in the face. %employer% grins.%SPEECH_ON%A gift from %employerfaction%. Now who is dreaming?%SPEECH_OFF% | When you return to %townname% a man in fine clothing is talking to %employer%. Upon seeing you the man speaks to the chieftain.%SPEECH_ON%This is your warrior? He did very good job. Everyone from %employerfaction% is very impressed.%SPEECH_OFF%. He turns to you and reveals a smile of perfect white teeth. No northerner should have teeth like that.%SPEECH_ON%A reward of %reward_completion%, as promised. Oh, and we may be happy, but that doesn\'t mean we want your kind in our lands.%SPEECH_OFF%. Suddenly, you have a strong urge to destroy that smile, but eventually decide against it.}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Honest pay for honest work.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Raided the enemy lands");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isCivilWar())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCommonContract);
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
		this.m.Screens.push({
			ID = "Success2",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_45.png[/img]{%employer% welcomes you into his room. He gives you a satchel of %reward_completion% crowns.%SPEECH_ON%There's a bit extra in there. Great work out there, warrior. You did more than could have been asked of you.%SPEECH_OFF% | You return to %employer% looking rightfully smug.%SPEECH_ON%Work\'s done.%SPEECH_OFF%He nods, raising a horn of mead, saluting your name.%SPEECH_ON%Yes, %employerfaction% is very happy with the work you\'ve done.%SPEECH_OFF%The man gestures toward the corner of the room. You see a satchel of crowns there.%SPEECH_ON%%reward_completion% crowns, even more than it was agreed, but you deserve it.%SPEECH_OFF% | %employer%\'s staring out his window when you enter. He\'s almost in a dreamstate, head bent low to his hand. You interrupt his thoughts.%SPEECH_ON%Thinking of me?%SPEECH_OFF%The man chuckles and playfully clutches his chest.%SPEECH_ON%You are truly the man of my dreams, warrior.%SPEECH_OFF%He crosses the room and takes a chest from the bookshelf. He unlatches it as he sets it on the table. A glorious pile of gold crowns stare you in the face. %employer% grins.%SPEECH_ON%A gift from %employerfaction% with a bit of extra. Now who is dreaming?%SPEECH_OFF% | When you return to %townname% a man in fine clothing is talking to %employer%. Upon seeing you the man speaks to the chieftain.%SPEECH_ON%This is your warrior? He did very good job. Everyone from %employerfaction% is very impressed.%SPEECH_OFF%. He turns to you and reveals a smile of perfect white teeth. No northerner should have teeth like that.%SPEECH_ON%A reward of %reward_completion%, more than was promised, but deserving. Oh, and we may be happy, but that doesn\'t mean we want your kind in our lands.%SPEECH_OFF%. Suddenly, you have a strong urge to destroy that smile, but eventually decide against it.}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Honest pay for honest work.",
					function getResult()
					{
						this.Contract.m.Payment.Completion = this.Math.round(this.Contract.m.Payment.Completion * 1.2);
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess * 2);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Raided the enemy lands");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isCivilWar())
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
		this.m.Screens.push({
			ID = "Failure1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_45.png[/img]{You enter %employer%\'s room and can immediately see he is not a happy man.%SPEECH_ON%This was a good opportunity, for everyone. For %employerfaction%, for %townname% and for you, personally. But now you are back and simply put the raid was a failure. Meaning there is no gold for you here.%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "To hell with you!",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Failed to raid the enemy lands");
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
			"targetfaction",
			this.m.Flags.get("TargetFactionName")
		]);
		_vars.push([
			"employerfaction",
			this.m.Flags.get("EmployerFactionName")
		]);
		_vars.push([
			"maxdays",
			"five days"
		]);
		local days = 5 - (this.World.getTime().Days - this.m.Flags.get("StartDay"));
		_vars.push([
			"days",
			days > 1 ? "" + days + " days" : "1 day"
		]);

		if (this.m.Item != null)
		{
			_vars.push([
				"nameditem",
				this.m.Item.getName()
			]);
		}
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			foreach( obj in this.m.Objectives )
			{
				if (obj != null && !obj.isNull() && obj.isActive())
				{
					obj.clearTroops();
					obj.setAttackable(false);
					obj.getSprite("selection").Visible = false;
					obj.getFlags().set("HasNobleProtection", false);
					obj.setOnCombatWithPlayerCallback(null);
				}
			}

			this.m.Item = null;
			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isCivilWar() && !this.World.FactionManager.isHolyWar())
		{
			return false;
		}

		return true;
	}

	function onSerialize( _out )
	{
		_out.writeU8(this.m.Objectives.len());

		foreach( o in this.m.Objectives )
		{
			if (o != null && !o.isNull())
			{
				_out.writeU32(o.getID());
			}
			else
			{
				_out.writeU32(0);
			}
		}

		if (this.m.Item != null)
		{
			_out.writeBool(true);
			_out.writeI32(this.m.Item.ClassNameHash);
			this.m.Item.onSerialize(_out);
		}
		else
		{
			_out.writeBool(false);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local numObjectives = _in.readU8();

		for( local i = 0; i != numObjectives; i = ++i )
		{
			local o = _in.readU32();

			if (o != 0)
			{
				this.m.Objectives.push(this.WeakTableRef(this.World.getEntityByID(o)));
				local obj = this.m.Objectives[this.m.Objectives.len() - 1];

				if (!obj.isMilitary() && !obj.getSettlement().isMilitary() && !obj.getFlags().get("HasNobleProtection"))
				{
					local garbage = [];

					foreach( i, e in obj.getTroops() )
					{
						if (e.ID == this.Const.EntityType.Footman || e.ID == this.Const.EntityType.Greatsword || e.ID == this.Const.EntityType.Billman || e.ID == this.Const.EntityType.Arbalester || e.ID == this.Const.EntityType.StandardBearer || e.ID == this.Const.EntityType.Sergeant || e.ID == this.Const.EntityType.Knight)
						{
							garbage.push(i);
						}
					}

					garbage.reverse();

					foreach( g in garbage )
					{
						obj.getTroops().remove(g);
					}
				}
			}
		}

		local hasItem = _in.readBool();

		if (hasItem)
		{
			this.m.Item = this.new(this.IO.scriptFilenameByHash(_in.readI32()));
			this.m.Item.onDeserialize(_in);
		}

		this.contract.onDeserialize(_in);
	}

});

