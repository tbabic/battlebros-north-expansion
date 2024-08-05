this.barbarian_chosen_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.barbarian_chosen";
		this.m.Title = "During camp...";
		this.m.Cooldown = 15 * this.World.getTime().SecondsPerDay;
		
		local options = [];
		
		
		
		
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_139.png[/img]{}",
			Image = "The clank of heavy armor draws your attention, and you look up to see %chosen% approaching. %SPEECH_ON%Chief, I wanted to speak with you.%SPEECH_OFF%You nod, gesturing for him to continue.%SPEECH_ON%We\'ve fought quite a few battles and so far you have not led us astray. It\'s an honor to fight for you chief. Just wanted to say that.%SPEECH_OFF%You can tell his words are sincere and you admit, his ability to wield %weapon% with deadly precision makes him a formidable warrior. He wears his heavy armor as if it were a second skin. Perhaps you should honor him with a position of a Chosen, an elite warrior among the tribes.",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "You will be one of Chosen!", 
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "No need to change anything.",
					function getResult( _event )
					{
						_event.m.Dude.getFlags().set("nem_chosen_rejected", true);
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath())
			}

		});
		
		this.m.Screens.push({
			ID = "B",
			Text = "[img]gfx/ui/events/event_139.png[/img]{You raise you hands and call out everybody. The conversations cease, and all eyes turn to you. %SPEECH_ON%Today, we honor one among us who has proven himself time and again in the heat of battle. A warrior whose skill is unmatched, whose loyalty is unwavering, and whose presence commands respect. I proclaim, %chosen% is now one of my Chosen. %SPEECH_OFF%A cheer rises from the gathered warriors, a sound of collective approval and excitement. %chosen% bows his head slightly, accepting this honor.%SPEECH_ON%I will not disappoint you, Chief.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			function start( _event )
			{
				
				this.Characters.push(_event.m.Dude.getImagePath())
				
				_event.m.Dude.getSkills().add(this.new("scripts/skills/traits/chosen_trait"));
				
				this.List.push({
					id = 10,
					icon = "ui/traits/trait_icon_chosen.png",
					text = _event.m.Dude.getName() + " is now Chosen"
				});
			}

		});

	}

	function onUpdateScore()
	{
		if (!this.Const.DLC.Wildmen)
		{
			return;
		}
		
		if (!this.World.Flags.get("NorthExpansionActive"))
		{
			return;
		}

		
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];
		foreach( bro in brothers )
		{
			if (bro.getFlags().get("nem_chosen_rejected"))
			{
				continue;
			}
			
			if (!bro.getSkills().hasSkill("background.barbarian"))
			{
				continue;
			}
			
			if (bro.getSkills().hasSkill("trait.thrall") || bro.getSkills().hasSkill("trait.chosen"))
			{
				continue;
			}
			
			local stats = bro.getLifetimeStats();
			if(stats.Kills < 100)
			{
				continue;
			}
			
			local props = bros[0].getBaseProperties();
			if(props.MeleeSkill < 80)
			{
				continue;
			}
			
			local armor = 0;
			local body = bro.getItems().getItemAtSlot(this.Const.ItemSlot.Body);
			local head = bro.getItems().getItemAtSlot(this.Const.ItemSlot.Head);
			armor += (body != null) ? body.getArmorMax() : 0;
			armor += (head != null) ? head.getArmorMax() : 0;
			
			if (armor < 400)
			{
				continue;
			}
			candidates.push(bro);
		}

		if (candidates.len() == 0)
		{
			return false;
		}
		
		this.m.Dude = candidates[this.Math.rand(0, candidates.len() - 1)];
		
			

		this.m.Score = 20 * candidates.len();
	}

	function onPrepareVariables( _vars )
	{
		if (this.m.Dude != null)
		{
			_vars.push([
				"chosen",
				this.m.Dude.getName()
			]);
			
			local weapon = this.m.Dude.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand);
			_vars.push([
				"weapon",
				weapon.getName()
			]);
		}
		
		
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

