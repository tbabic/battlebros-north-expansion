this.barbarian_dueling_circle_event <- this.inherit("scripts/events/event", {
	m = {
		Home = null,
		DuelingCircle = null,
		ChampionName = null,
		ChampionBro = null,
		BroHasChampion = false,
		SortedRoster = [],
		PageSize = 3,
		CurrentPage = 0
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
				
				local champion = _event.m.DuelingCircle.getChampion();
				
				if (champion == null)
				{
					this.Text += "There are no worthy fighters in this place that are willing to step forth to combat one of your warriors. Come back tomorrow."
					return;
				}

				if (champion.Level == 1)
				{
					this.Text += "There are no great champions in this place, but one of the thralls comes forth to fight you and earn his status as a free man."
				}
				
				if (champion.Level == 2)
				{
					this.Text += "There are no great champions in this place, but a marauder, with the experience of many raids, comes forth to fight you."
				}
				
				if (champion.Level == 3)
				{
					this.Text += "There are no great champions in this place, but there is an experienced warrior with many victories that comes forth to fight you."
				}
				
				if (champion.Level == 4)
				{
					this.Text += "%enemy% steps forth, you can see he is an impressive warrior with a body of pure muscle, tendon, and scars. A worthy champion."
				}
				
				
				
				
				local startIdx = _event.m.PageSize * _event.m.CurrentPage;
				local endIdx = this.Math.min(startIdx + _event.m.PageSize -1, _event.m.SortedRoster.len()-1);
				if(startIdx == 0 && endIdx +1 == _event.m.SortedRoster.len() -1 )
				{
					endIdx++;
				}

				for( local i = startIdx; i <= endIdx; i++ )
				{
					local bro = _event.m.SortedRoster[i];
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
				if(startIdx != 0 || endIdx < _event.m.SortedRoster.len() -1 )
				{
					this.Options.push({
						Text = "Someone else will fight you...",
						function getResult(_event)
						{
							this.logInfo("old page: " + _event.m.CurrentPage);
							_event.m.CurrentPage++;
							
							if (_event.m.CurrentPage* _event.m.PageSize >= _event.m.SortedRoster.len() )
							{
								_event.m.CurrentPage = 0;
							}
							this.logInfo("new page: " + _event.m.CurrentPage);
							return "A";	
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
				_event.m.DuelingCircle.championDefeated();
				if(_event.getChampion().Level >= 4 && !_event.m.BroHasChampion)
				{
					
					local trait = this.new("scripts/skills/traits/champion_trait");
					_event.m.ChampionBro.getSkills().add(trait);
					
					if(_event.m.ChampionBro.getSkills().hasSkill("trait.player"))
					{
						this.Text += "\n\n You have now won a number of duel against renowned champion. This experience has made you a better fighter, particularly when in single combat."
					}
					else
					{
						this.Text += "\n\n %champbrother% has now won a number of duel against renowned champion. This experience has made him a better fighter, particularly when in single combat."
					}
					
					this.List.push({
						id = 10,
						icon = trait.getIcon(),
						text = _event.m.ChampionBro.getName() + " becomes " + trait.getName()
					});
				}
				
				if(_event.m.ChampionBro.getLevel() < 11)
				{
					local duelExperience = _event.m.ChampionBro.getSkills().getSkillByID("effects.duel_experience");
					if(duelExperience == null)
					{
						duelExperience = this.new("scripts/skills/effects/duel_experience_effect");
						duelExperience.updateExperienceLevel(_event.getChampion().Level);
						_event.m.ChampionBro.getSkills().add(duelExperience);
						
						this.List.push({
							id = 11,
							icon = duelExperience.getIcon(),
							text = _event.m.ChampionBro.getName() + " now has " + duelExperience.getName()
						});
					}
					else
					{
						duelExperience.updateExperienceLevel(_event.getChampion().Level);
					}
					
					
				}
				
				local duelFighter = _event.m.ChampionBro.getSkills().getSkillByID("trait.duel_fighter");
				if(duelFighter == null)
				{
					duelFighter = this.new("scripts/skills/traits/duel_fighter_trait");
					_event.m.ChampionBro.getSkills().add(duelFighter);
					this.List.push({
						id = 12,
						icon = duelFighter.getIcon(),
						text = _event.m.ChampionBro.getName() + " is now " + duelFighter.getName()
					});
				}
				duelFighter.updateStatistics(_event.getChampion().Level);
				
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

		this.m.ChampionName = "";
		local champion = this.getChampion();
		this.logInfo("champion: " + champion);
		if (champion == null)
		{
			return;
		}
		if (champion.Variant == 1)
		{
			this.m.ChampionName = ::NorthMod.Utils.barbarianNameAndTitle();
		}
		
		local raw_roster = this.World.getPlayerRoster().getAll();
		this.m.SortedRoster = [];
		this.logInfo("create roster");
		foreach( bro in raw_roster )
		{
			if (bro.getPlaceInFormation() <= 17 && bro.getLevel() <= champion.MaxBroLevel)
			{
				this.m.SortedRoster.push(bro);
			}
		}
		this.logInfo("sorted roster len:" + this.m.SortedRoster.len());
		::NorthMod.Utils.duelRosterSort(this.m.SortedRoster);

		
	}
	
	function getChampion()
	{
		return this.m.DuelingCircle.getChampion();
	}
	
	function onPrepareVariables( _vars )
	{
		_vars.push([
			"enemy",
			this.m.ChampionName
		]);
		
		
		
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
		local champion = this.getChampion();
		local name = this.m.ChampionName;
		properties.Entities.push({
			ID = champion.ID,
			Name = name,
			Variant = champion.Variant,
			Row = 0,
			Script = champion.Script,
			Faction = this.Const.Faction.Enemy
			function Callback( _entity, _tag )
			{
				if(name != "")
				{
					_entity.setName(name);
				}
				
			}

		});
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
		this.World.State.startScriptedCombat(properties, false, false, false);

	}

	function onClear()
	{
		this.m.Home = null;
		this.m.DuelingCircle = null;
		this.m.ChampionBro = null;
		this.m.ChampionName = null;
		this.m.BroHasChampion = false;
	}

});

