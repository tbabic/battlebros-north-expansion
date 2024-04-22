this.barbarian_dueling_circle_event <- this.inherit("scripts/events/event", {
	m = {
		Home = null,
		DuelingCircle = null,
		ChampionIndex = null,
		ChampionName = null,
		ChampionLevel = null
		ChampionBro = null,
		BroHasChampion = false
	},
	
	function setHome( _home)
	{
		if (typeof _home == "instance")
		{
			this.m.Home = _home;
		}
		else
		{
			this.m.Home = this.WeakTableRef(_home);
		}
	}
	
	function setChampionIndex( _championIndex)
	{
		this.m.ChampionIndex = _championIndex;
	}
	
	
	function create()
	{
		this.m.ID = "event.barbarian_dueling_circle";
		this.m.Title = "Dueling Circle";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Title = "Dueling Circle",
			Text = ""
			Image = "",
			List = [],
			Options = [
				{
					Text = "There will be no fighting today!",
					function getResult(_event)
					{
						return 0;
					}

				}
			],
			function start(_event)
			{
				if (_event.m.DuelingCircle.isClosed())
				{
					local cooldownDays = _event.m.DuelingCircle.getCooldownDays();
					this.Text = "[img]gfx/ui/events/event_138.png[/img]You approach the dueling circle but there is no one to fight you. Come back in " + _event.m.DuelingCircle.getCooldownDays() + " day";
					if (cooldownDays > 1)
					{
						this.Text += "s";
					}
					return;
				}
				this.Text = "[img]gfx/ui/events/event_139.png[/img]You approach the dueling circle and ask is there a champion in this place who will fight you or one of your men?\n\n"
				
				local championLevel = _event.m.DuelingCircle.m.ChampionLevel;
				if (championLevel == 0)
				{
					this.Text += "There are no worthy fighters in this place that are willing to step forth to combat one of your warriors."
					return;
				}

				if (championLevel == 1)
				{
					this.Text += "There are no great champions in this place, but one of the thralls comes forth to fight you and earn his status as a free man."
				}
				
				if (championLevel == 2)
				{
					this.Text += "There are no great champions in this place, but a marauder, with the experience of many raids, comes forth to fight you."
				}
				
				if (championLevel == 3)
				{
					this.Text += "There are no great champions in this place, but there is an experienced warrior with many victories that comes forth to fight you."
				}
				
				if (championLevel == 4)
				{
					this.Text += "%enemy% steps forth, you can see he is an impressive warrior with a body of pure muscle, tendon, and scars. A worthy champion."
				}
				
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
					
					if (_a.getSkills().getSkillByID("trait.player") && _b.getSkills().getSkillByID("trait.player"))
					{
						return 0;
					}
					
					if (_a.getSkills().getSkillByID("trait.player"))
					{
						return -1;
					}
					if (_b.getSkills().getSkillByID("trait.player"))
					{
						return 1;
					}
					
					
					if (_a.getSkills().getSkillByID("trait.champion") && _b.getSkills().getSkillByID("trait.champion"))
					{
						return 0;
					}
					
					if (_a.getSkills().getSkillByID("trait.champion"))
					{
						return -1;
					}
					if (_b.getSkills().getSkillByID("trait.champion"))
					{
						return 1;
					}
					
					local _a_duels_won = _a.getFlags().getAsInt("NEM_duels_won");
					local _b_duels_won = _b.getFlags().getAsInt("NEM_duels_won");
					
					if (_a_duels_won > _b_duels_won)
					{
						return -1;
					}
					if (_a_duels_won < _b_duels_won)
					{
						return 1;
					}
					
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
				
				
				local e = this.Math.min(4, roster.len());

				for( local i = 0; i < e; i = ++i )
				{
					local bro = roster[i];
					local text = bro.getName() + " will fight you!"
					local isChamp = false;
					if (bro.getSkills().hasSkill("trait.champion"))
					{
						text = bro.getName() + " is my champion!";
						isChamp = true;
						_event.m.BroHasChampion = true;
					}
					if (bro.getFlags().get("IsPlayerCharacter") || bro.getFlags().get("IsPlayerCharacterAvatar"))
					{
						text = "I, " + bro.getName() + ", will fight you!";
					}
					
					
					this.Options.push({
						Text = text,
						function getResult(_event)
						{
							this.logInfo("name:" + bro.getName());
							_event.m.ChampionBro = bro;
							_event.prepareCombat();
							return 0;
							
						}
						
					});

				}
				
				
			}

		});
		this.m.Screens.push({
			ID = "TheDuel2",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{Your opponent is slain, his beaten body lying and his blood soaking the ground. The victory and glory is yours.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "It is done.",
					function getResult(_event)
					{
						return 0;
					}

				},
				
				
			],
			function start( _event )
			{
				_event.m.DuelingCircle.setCooldown(5);
				if(_event.m.ChampionLevel >= 4 && !_event.m.BroHasChampion)
				{
					_event.m.ChampionBro.getFlags().increment("NEM_duels_won");
					if(_event.m.ChampionBro.getFlags().getAsInt("NEM_duels_won") == 5)
					{
						local trait = this.new("scripts/skills/traits/champion_trait");
						_event.m.ChampionBro.getSkills().add(trait);
						_event.resetDuels();
						
						if(_event.m.ChampionBro.getSkills().hasSkill("trait.player"))
						{
							this.Text += "\n\n You have now won a number of duels against renowned champions. This experience has made you a better fighter, particularly when in single combat."
						}
						else
						{
							this.Text += "\n\n %champbrother% has now won a number of duels against renowned champions. This experience has made him a better fighter, particularly when in single combat."
						}
						
						this.List.push({
							id = 10,
							icon = trait.getIcon(),
							text = _event.m.ChampionBro.getName() + " becomes " + trait.getName()
						});
						
					}
				}
				
				
				return 0;
			}
			

		});
		this.m.Screens.push({
			ID = "TheDuel3",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{It was a good fight, but %champbrother% lies dead on the ground. Bested and killed. The victory and glory goes to your opponent.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "It is done.",
					function getResult(_event)
					{
						
						return 0;
					}

				}
			],
			function start( _event )
			{
				_event.m.DuelingCircle.setCooldown(1);
				if(_event.m.BroHasChampion)
				{
					_event.resetDuels();
				}
				if (_event.getChampion().ID == this.Const.EntityType.BarbarianThrall)
				{
					_event.m.Home.removeTroop(_event.getChampion());
					this.Const.World.Common.addTroop(_event.m.Home, { Type = this.Const.World.Spawn.Troops.BarbarianMarauder }, true)
				}
				return 0;
			}
		});
		
		
		this.m.Screens.push({
			ID = "Champion",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "It is done.",
					function getResult(_event)
					{
						if(_event.m.BroHasChampion)
						{
							_event.resetDuels();
						}
						return 0;
					}

				}
			],
			function start( _event )
			{
				return 0;
			}
		});
	}

	function onUpdateScore()
	{	
		return 0;
	}
	
	function isValid()
	{	
		return true;
	}
	
	
	
	function onPrepare()
	{
		if(this.m.Home == null)
		{
			local player = this.World.getPlayerEntity();
			local entities = this.World.getAllEntitiesAndOneLocationAtPos(player.getPos(), 1.0);
			foreach( e in entities )
			{
				if (e.isLocation())
				{
					this.m.Home = e;
					break;
				}
			}
		}
		
		if(this.m.DuelingCircle == null)
		{
			foreach (building in this.m.Home.m.Buildings)
			{
				if (building != null && building.getID() == "building.duel")
				{
					this.m.DuelingCircle = building;
					break;
				}
			}
		}

		if(this.m.ChampionIndex == null)
		{
			this.m.ChampionIndex = this.m.DuelingCircle.m.ChampionIndex;
		}
		
		if(this.m.ChampionLevel == null)
		{
			this.m.ChampionLevel = this.m.DuelingCircle.m.ChampionLevel;
		}
		
		
	}
	
	function getChampion()
	{
		if(this.m.ChampionIndex != null && this.m.ChampionIndex >= 0 && this.m.ChampionIndex < this.m.Home.getTroops().len())
		{
			return this.m.Home.getTroops()[this.m.ChampionIndex];
		}
		
		return null;
	}
	
	function onPrepareVariables( _vars )
	{
		local champion = this.getChampion();
		if (champion != null && champion.Name != "")
		{
			_vars.push([
				"enemy",
				champion.Name
			]);
		}
		
		
		
		if (this.m.ChampionBro != null)
		{
			_vars.push([
				"champbrother",
				this.m.ChampionBro.getName()
			]);
		}
		
	}
	
	function prepareCombat()
	{
		
		local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
		properties.CombatID = "Duel";
		properties.Music = this.Const.Music.BarbarianTracks;
		properties.Entities = [];
		properties.Entities.push(this.getChampion());
		properties.EnemyBanners.push(this.m.Home.getBanner());
		properties.Players.push(this.m.ChampionBro);
		properties.IsUsingSetPlayers = true;
		properties.IsFleeingProhibited = true;
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
		
		this.registerToShowAfterCombat("TheDuel2","TheDuel3");
		properties.TemporaryEnemies = [
			this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID()
		];
		this.logInfo("StartCombat");
		this.World.State.startScriptedCombat(properties, false, false, false);
		
		
	}
	
	function resetDuels()
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

	function onClear()
	{
		this.m.Home = null;
		this.m.DuelingCircle = null;
		this.m.ChampionIndex = null;
		this.m.ChampionBro = null;
		this.m.ChampionName = null;
		this.m.ChampionLevel = null;
		this.m.BroHasChampion = false;
	}

});

