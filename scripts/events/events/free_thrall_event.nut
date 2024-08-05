this.free_thrall_event <- this.inherit("scripts/events/event", {
	m = {
		LastCombatID = 0,
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.free_thrall";
		this.m.Title = "After the battle...";
		this.m.Cooldown = 10 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_139.png[/img]{%thrall%, a thrall bound to your service, approaches with a steady walk and calm eyes. As he draws nearer, the determination in his stride and the intensity in his gaze speak volumes about the weight of his request.%SPEECH_ON%Chief, I\'ve fought for you, I\'ve bled for you, and I\'ve killed for you. I\'ve done it all quite well, if you ask me. By the gods and ancestors, I\'ve done enough to no longer be called a thrall. If you grant me my freedom, I will continue to follow you, but as a free man.%SPEECH_OFF%Silence spreads among your crew as his words hang in the air. The other warriors pause in their tasks, their eyes turning to you and %thrall%, curiosity and respect evident in their gazes. They know %thrall%\'s worth; they\'ve seen his courage and skill in battle, his unwavering loyalty in the face of danger.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Yes. You've earned your freedom.", 
					function getResult( _event )
					{
						return "GrantFreedom";
					}

				},
				{
					Text = "No. You remain a thrall.",
					function getResult( _event )
					{
						return "RejectFreedom";
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "GrantFreedom",
			Text = "[img]gfx/ui/events/event_139.png[/img]{With a nod of your head you agree.%SPEECH_ON%Aye. %thrall%, your bravery and loyalty have earned you this day. From this moment on, you are a free man.%SPEECH_OFF%A cheer erupts from the gathered warriors, their voices rising in a chorus of approval. %thrall% stands taller, his face alight with a mixture of pride and relief. He grasps your forearm in a warrior\'s handshake, his grip firm and resolute.%SPEECH_ON%Thank you, Chief. I will fight even harder for you, now as a free man.%SPEECH_OFF%}", 
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "This is the way."
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
				
				_event.m.Dude.getSkills().removeByID("trait.thrall");
				this.List.push({
					id = 10,
					icon = "ui/traits/trait_icon_thrall.png",
					text = _event.m.Dude.getName() + " is no longer a thrall"
				});
				
				//improve mood
				_event.m.Dude.improveMood(2.0, "Accepted his request for freedom");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Dude.getMoodState()],
					text = _event.m.Dude.getName() + this.Const.MoodStateEvent[_event.m.Dude.getMoodState()]
				});
				local roster = this.World.getPlayerRoster().getAll();
				foreach (bro in roster)
				{
					if (bro == _event.m.Dude || bro.getBackground().getID() != "background.barbarian")
					{
						continue;
					}
					else
					{
						bro.improveMood(1.0, "Happy because " + _event.m.Dude.getName() + " earned his freedom");
					}
					
					if (bro.getMoodState() < this.Const.MoodState.Neutral)
					{
						this.List.push({
							id = 10,
							icon = this.Const.MoodStateIcon[bro.getMoodState()],
							text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
						});
					}
				}
			}
		});
		this.m.Screens.push({
			ID = "RejectFreedom",
			Text = "[img]gfx/ui/events/event_139.png[/img]{Silence spreads among your crew, the joyous atmosphere instantly replaced by a tense silence. %thrall%\'s expression falls, his eyes flashing with disappointment and frustration. The warriors around you exchange uneasy glances, their respect for %thrall% evident in their unhappy murmurs.%SPEECH_ON%I have fought for you, bled for you, killed for you. I hoped to do so as a free man.%SPEECH_OFF%Your decision stands firm, but the discontent is palpable. Some men are shaking their heads, but no one dares to question you. Not yet.}", 
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "It is what it is.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Dude.getImagePath());
				
				//worsen mood
				_event.m.Dude.worsenMood(5.0, "Rejected his request for freedom");
				this.List.push({
					id = 10,
					icon = this.Const.MoodStateIcon[_event.m.Dude.getMoodState()],
					text = _event.m.Dude.getName() + this.Const.MoodStateEvent[_event.m.Dude.getMoodState()]
				});
				local roster = this.World.getPlayerRoster().getAll();
				foreach (bro in roster)
				{
					if (bro == _event.m.Dude || bro.getBackground().getID() != "background.barbarian")
					{
						continue;
					}
					else
					{
						bro.worsenMood(2.0, "Angry because " + _event.m.Dude.getName() + "was rejected freedom");
					}
					
					if (bro.getMoodState() < this.Const.MoodState.Neutral)
					{
						this.List.push({
							id = 10,
							icon = this.Const.MoodStateIcon[bro.getMoodState()],
							text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
						});
					}
				}
			}
		});
	}

	function isValid()
	{		
		logInfo("is valid: " + this.m.ID);
		if (!this.Const.DLC.Wildmen)
		{
			return false;
		}
		
		if (!this.World.Flags.get("NorthExpansionActive") )
		{
			return false;
		}

		if (this.World.Statistics.getFlags().getAsInt("LastCombatID") <= this.m.LastCombatID)
		{
			return false;
		}
		
		if (this.Time.getVirtualTimeF() - this.World.Events.getLastBattleTime() > 5.0)
		{
			return false;
		}
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];
		foreach( bro in brothers )
		{
			local stats = bro.getLifetimeStats();
			local flags = bro.getFlags();
			
			if (bro.getSkills().hasSkill("trait.thrall") && (stats.Kills >= 50 || flags.getAsInt("Nem_DuelReavers") > 0))
			{
				candidates.push(bro);
			}

		}

		if (candidates.len() == 0)
		{
			return false;
		}
		
		this.m.Dude = candidates[this.Math.rand(0, candidates.len() - 1)];
		
		this.m.LastCombatID = this.World.Statistics.getFlags().get("LastCombatID");
		return true;

	}
	
	
	function onPrepare()
	{		
		logInfo("prepare: " + this.m.ID);
		local brothers = this.World.getPlayerRoster().getAll();
		local candidates = [];
		foreach( bro in brothers )
		{
			local stats = bro.getLifetimeStats();
			local flags = bro.getFlags();
			
			if (bro.getSkills().hasSkill("trait.thrall") && (stats.Kills >= 50 || flags.getAsInt("Nem_DuelReavers") > 0))
			{
				candidates.push(bro);
			}

		}

		if (candidates.len() == 0)
		{
			return;
		}
		
		this.m.Dude = candidates[this.Math.rand(0, candidates.len() - 1)];
		
	}
	
	function onPrepareVariables( _vars )
	{
		if (this.m.Dude != null)
		{
			_vars.push([
				"thrall",
				this.m.Dude.getNameOnly()
			]);
		}
	
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

