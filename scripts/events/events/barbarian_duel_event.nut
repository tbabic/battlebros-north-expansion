this.barbarian_duel_event <- this.inherit("scripts/events/event", {
	m = {
		Location = null,
	},
	function create()
	{
		this.m.ID = "event.barbarian_duel";
		this.m.Title = "Along the way...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_139.png[/img]{Just as it seems the %companyname% is ready to clash with the savages, a lone figure steps out and stands between the battle lines. He\'s got a parted long beard knotted around tortoise shells and his head is sheltered beneath a sloping snout of a wolf\'s skull. The elder stands unarmed save for a long staff which clatters with tethered deer horns.He speaks out in a loud voice.%SPEECH_ON%Outsiders. Welcome to our lands. We are not so inhospitable as you may think. As is our tradition, we believe that battle between two men is just as honorable and of value as that between two armies. So it is, I offer my strongest champion, %barbarianname%.%SPEECH_OFF%A burly man steps forward. He unhooks the pelts and tosses them aside to reveal a body of pure muscle, tendon, and scars. The elder nods.%SPEECH_ON%Put forth your champion, Outsiders, and we shall share a day that all our ancestors will smile upon.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "I\'d rather burn down this whole camp. Attack!",
					function getResult()
					{
						this.World.State.showCombatDialog();
						return 0;
					}

				}
			],
			function start(_event)
			{
				this.m.Flags.set("ChampionName", this.Const.Strings.BarbarianNames[this.Math.rand(0, this.Const.Strings.BarbarianNames.len() - 1)] + " " + this.Const.Strings.BarbarianTitles[this.Math.rand(0, this.Const.Strings.BarbarianTitles.len() - 1)]);
				local raw_roster = this.World.getPlayerRoster().getAll();
				local roster = [];

				foreach( bro in raw_roster )
				{
					if (bro.getPlaceInFormation() <= 17)
					{
						roster.push(bro);
					}
				}

				roster.sort(function ( _a, _b )
				{
					if (_a.getXP() > _b.getXP())
					{
						return -1;
					}
					else if (_a.getXP() < _b.getXP())
					{
						return 1;
					}

					return 0;
				});
				local name = this.Flags.get("ChampionName");
				local difficulty = _event.getReputationToDifficultyLightMult();
				if(difficulty < 1.15 && location.getFlags().get("DuelLost"))
				{
					difficulty = 1.15;
				}
				local e = this.Math.min(3, roster.len());
				local champion;
				local avatar;
				foreach( bro in raw_roster )
				{
					if (bro.getSkills().getSkillByID("trait.champion"))
					{
						champion = bro;
					}
					
					if (bro.getFlags().get("IsPlayerCharacter") || bro.getFlags().get("IsPlayerCharacterAvatar"))
					{
						avatar = bro;
					}
				}
				local championText = champion.getName() + " is my champion and he will win!";
				if (champion == avatar)
				{
					 championText = "I, " + champion.getName() + ", will fight your champion and win!"
				}
				this.Options.push({
					Text = championText,
					function getResult() {
						this.Flags.set("ChampionBrotherName", champion.getName());
						this.Flags.set("ChampionBrother", champion.getID());
						return "TheDuel2";
					}
				});
				foreach(bro in roster)
				{
					
					if (this.Options.len() > e)
					{
						break;
					}
					if (bro == champion)
					{
						continue;
					}
					local text = bro.getName() + " will fight your champion!";
					if (bro == avatar)
					{
						text = "I, " + text;
					}
					this.Options.push({
						Text = text,
						function getResult(_event)
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
								Variant = difficulty >= 1.15 ? 1 : 0,
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
							properties.BeforeDeploymentCallback = function ()
							{
								local size = this.Tactical.getMapSize();

								for( local x = 0; x < size.X; x = ++x )
								{
									for( local y = 0; y < size.Y; y = ++y )
									{
										local tile = this.Tactical.getTileSquare(x, y);
										tile.Level = this.Math.min(1, tile.Level);
									}
								}
							};
							
							_event.registerToShowAfterCombat("TheDuel2","TheDuel3");
							this.World.State.startScriptedCombat(p, false, true, false);
							
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
			Text = "[img]gfx/ui/events/event_138.png[/img]{%champbrother% sheathes his weapons and stands over the corpse of the slain savage. Nodding, the victorious warriour stares back at you.%SPEECH_ON%Finished, chief.%SPEECH_OFF%The elder comes forward again and raises his staff.%SPEECH_ON%So it is, what is it that you wish to have been solved by the violence you sought coming here?%SPEECH_OFF%You tell him that you came to raid and plunder. You will accept loyalty as well. The elder nods.%SPEECH_ON%If by battle you would have accomplished, then by honorable duel it is finished. We shall give you your loot or you can take one of our men.%SPEECH_OFF%The savages are told to pack up and go. Surprisingly, there\'s little backtalk or complaining.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Give us valuables.",
					function getResult(_event)
					{
						local loot = [];
						this.m.Location.onDropLootForPlayer( loot );
						local stash = this.World.Assets.getStash();
						foreach (item in loot)
						{
							if (!stash.hasEmptySlot())
							{
								break;
							}
							stash.add(item);
							this.List.push({
								id = 10,
								icon = "ui/items/" + item.getIcon(),
								text = "You gain " + item.getName()
							});
						}
						
						
						this.m.Location.die();
						return 0;
					}

				},
				
				
			],
			function start()
			{
				if (this.World.getPlayerRoster().getSize() < this.World.Assets.getBrothersMax())
				{
					return;
				}
				this.Options.push({
					Text = "We always need men",
					function getResult(_event)
					{
						local loot = [];
						this.m.Location.onDropLootForPlayer( loot );
						local stash = this.World.Assets.getStash();
						foreach (item in loot)
						{
							if (!stash.hasEmptySlot())
							{
								break;
							}
							stash.add(item);
							this.List.push({
								id = 10,
								icon = "ui/items/" + item.getIcon(),
								text = "You gain " + item.getName()
							});
						}
						
						
						this.m.Location.die();
						return 0;
					}
				});
				local bro = this.Tactical.getEntityByID(this.Flags.get("ChampionBrother"));
				this.Characters.push(bro.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "TheDuel3",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{It was a good fight, a clash between men upon the earth with those in observation silent as though in awe of some timeless and honorable rite. But. %champbrother% lies dead on the ground. Bested and killed. The elder steps forward again. He does not carry any hint of gloating or grin.%SPEECH_ON%Outsiders, the battle between two men is as such as it were between all of us combined. We have won, blessed is the Far Rock\'s gaze, and so we request that you depart these lands and do not return.%SPEECH_OFF%A few of the sellswords look to you with anger. One says he doesn\'t think the savages would abide the agreement were things the other way around, that the company should wipe these barbarians out regardless of the outcome.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "What to do now?",
					function getResult()
					{	
						local duelDay = this.Time.getVirtualTimeF() / this.World.getTime().SecondsPerDay;
						location.getFlags().set("DuelLost");
						location.getFlags().set("LastDuel", duelDay);
						return 0;
					}

				}
			]
		});
	}

	function onUpdateScore()
	{	
		return;
	}
	
	function isValid()
	{
		
		if (this.World.Events.hasActiveEvent())
		{
			return false;
		}
		local activeContract = this.World.Contracts.getActiveContract();
		
		//TODO: check if part of contract
		if (activeContract != null && activeContract.getID() == "contract.drive_away_barbarians")
		{	
			if (activeContract.m.Destination == this.m.Location)
			{
				return false;
			}
		}
		
		if (this.World.Assets.getOrigin().getID() != "scenario.barbarian_raiders" )
		{
			return false;
		}
		if(this.World.Flags.get("NorthExpansionCivilLevel") >= 3)
		{
			return false;
		}
		
		
		
		local faction = this.World.FactionManager.getFaction(this.m.Location.getFaction());
		
		if(faction.getType() != this.Const.FactionType.Barbarians)
		{
			return false;
		}
	
		local day = this.Time.getVirtualTimeF() / this.World.getTime().SecondsPerDay;
		local duelLostDay = location.getFlags().getAsInt("LastDuel", duelDay)
		if (location.getFlags().get("DuelLost") && (day - duelLostDay < 30))
		{
			return false;
		}
		
		local chance = 50;
		
		local locationStrength = this.m.Location.getStrength();
		local playerStrength = this.World.State.m.Player.getStrength();
		
		local diffStrength = playerStrength- locationStrength ;
		
		chance += diffStrength;
		
		if(this.Math.rand(1, 100) > chance) {
			return false;
		}
		
		return true;
	}
	
	function onPrepareVariables( _vars )
	{
		_vars.push([
			"barbarianname",
			this.m.Flags.get("ChampionName")
		]);
		_vars.push([
			"champbrother",
			this.m.Flags.get("ChampionBrotherName")
		]);
	}

	function onClear()
	{
		this.m.Location = null;
	}

});

