this.survivor_recruits_event <- this.inherit("scripts/events/event", {
	m = {
		LastCombatID = 0,
		Dude = null,
		RecruitResult = null,
		shouldTrigger = false
	},
	function create()
	{
		this.m.ID = "event.survivor_recruits";
		this.m.Title = "After the battle...";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "Civilians",
			Text = "[img]gfx/ui/events/event_53.png[/img]{After the battle you and your men scour the battlefield for loot and supplies. %randombrother% calls for you, points to one of the men who is still breathing, barely and not for long. Not without help anyway. %randombrother2% takes out his knife and asks if he should finish him off. %randombrother% stops him and speaks up.%SPEECH_ON%He fought well, that one. We need men and could use a man like that. Maybe we should offer him to fight for us in exchange for his life.%SPEECH_OFF%The dying man grumbles something, but you understand he\'s willing to accept the proposal.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "He\'s a good fighter. We\'ll take him.",
					function getResult( _event )
					{
						if(_event.m.RecruitResult != "Recruited")
						{
							return _event.m.RecruitResult;
						}
					
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude.m.MoodChanges = [];
						_event.m.Dude.worsenMood(2.0, "Fought recently against the company");
						_event.m.Dude = null;
						return 0;
					}

				},
				{
					Text = "He fought well, give him a quick death.",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-1);
						return "Executed";
					}

				}
				{
					Text = "Leave him to his fate.",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(1);
						return "LeftAlone";
					}

				}
			],
			function start( _event )
			{
				local probabilities;
				local backgrounds = [];
				local f = this.World.FactionManager.getFaction(this.World.Statistics.getFlags().getAsInt("LastCombatFaction"));
				if (f.getType() == this.Const.FactionType.NobleHouse)
				{
					probabilities = [40, 20];
					backgrounds.push({
						name = "disowned_noble_background",
						score = 5
					});
					backgrounds.push({
						name = "adventurous_noble_background",
						score = 1
					});
					backgrounds.push({
						name = "militia_background",
						score = 100
					});
					backgrounds.push({
						name = "squire_background",
						score = 20
					});
				}
				else
				{
					probabilities = [20, 40];
					backgrounds.push({
						name = "farmhand_background",
						score = 2
					});
					backgrounds.push({
						name = "bowyer_background",
						score = 1
					});
					backgrounds.push({
						name = "militia_background",
						score = 1
					});
					backgrounds.push({
						name = "mason_background",
						score = 1
					});
					backgrounds.push({
						name = "miller_background",
						score = 1
					});
					backgrounds.push({
						name = "lumberjack_background",
						score = 1
					});
					backgrounds.push({
						name = "butcher_background",
						score = 1
					});
					backgrounds.push({
						name = "daytaler_background",
						score = 1
					});
				}
				
				_event.recruit(probabilities, backgrounds);
				if(_event.m.Dude != null)
				{
					this.Characters.push(_event.m.Dude.getImagePath());
				}
			}

		});
		this.m.Screens.push({
			ID = "Barbarians",
			Text = "[img]gfx/ui/events/event_145.png[/img]{The battle is over, battlefield filled with dead enemies, or soon to be dead. Surprisingly one of the enemies is standing up, holding his weapon, barely but holding. His legs buckle and he falls to his knees, but still holds his weapon.%randombrother% comes up to you. %SPEECH_ON%He is refusing to die, have to admire that in a man. But death catches even the stubborn ones and he can't run right now. But maybe we should help him and he'll join us.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "We\'ll save his life, if he\'ll join us.",
					function getResult( _event )
					{
						logInfo("recruit result: " + _event.m.RecruitResult);
						if(_event.m.RecruitResult != "Recruited")
						{
							return _event.m.RecruitResult;
						}
						logInfo("add dude");
						if (_event.m.Dude == null)
						{
							logInfo("dude is null");
						}
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude.m.MoodChanges = [];
						_event.m.Dude.worsenMood(2.0, "Fought recently against the company");
						_event.m.Dude = null;
						return 0;
					}

				},
				{
					Text = "Finish him.",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(-1);
						return "Executed";
					}

				}
				{
					Text = "This deserves respect. Leave him be.",
					function getResult( _event )
					{
						this.World.Assets.addMoralReputation(1);
						return "LeftAlone"
					}

				}
			],
			function start( _event )
			{
				local probabilities;
				local backgrounds = [];
				local f = this.World.FactionManager.getFaction(this.World.Statistics.getFlags().getAsInt("LastCombatFaction"));
				if (f.getType() == this.Const.FactionType.Bandits)
				{
					probabilities = [30, 20];
					backgrounds.push({
						name = "raider_background",
						score = 1
					});
				}
				else
				{
					probabilities = [20, 10];
					backgrounds.push({
						name = "barbarian_background",
						score = 1
					});
				}
				
				_event.recruit(probabilities, backgrounds);
				if(_event.m.Dude != null)
				{
					this.Characters.push(_event.m.Dude.getImagePath());
				}
					
				
				
			}

		});
		this.m.Screens.push({
			ID = "KillAttempt",
			Text = "[img]gfx/ui/events/event_145.png[/img]{%randombrother% moves to help the man with his wounds, when suddenly he pulls a knife on your man. His move is too slow and predictable. %randombrother% easily parries it and then slides his blade into the man\'s chests. His body falls to the ground, a single twitch of legs and then it\'s perfectly calm. Your warrior turns to you, his expression one of regret and dissapointment. %SPEECH_ON%I guess some men don\'t want to live. Shame he was a tough bastard. Would have fit in right with our crew.%SPEECH_OFF% You agree, but what is done is done.There is nothing left to do here, so you tell your men to gather all their belongings and move on.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "I guess he didn't want to join us.",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						_event.m.Dude = null;
						return 0;
					}

				}
			],
			function start( _event )
			{
				
			}

		});
		this.m.Screens.push({
			ID = "DeadAnyway",
			Text = "[img]gfx/ui/events/event_145.png[/img]{%randombrother% moves to help the man with his wounds, but after examining him, he turns towards you and shakes his head.%SPEECH_ON%He will not make it. %SPEECH_OFF%Upon hearing that, the survivor defiantly tries to get up, but his legs fail him and he stumbles to the ground. A few more labored breaths and then the final one. %SPEECH_ON% A shame, he was a tough bastard. Just not tough enough.%SPEECH_OFF%Proclaims the %randombrother%. You agree, but such was his fate and the gods willed it so.There is nothing left to do here, so you tell your men to gather all their belongings and move on.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Such a shame.",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						_event.m.Dude = null;
						return 0;
					}

				}
			],
			function start( _event )
			{
				
			}

		});
		this.m.Screens.push({
			ID = "Executed",
			Text = "[img]gfx/ui/events/event_145.png[/img]{%randombrother% unsheathes his sword and lowers the blade towards the man, his face blobbing at the tip. He spits out, last act of defiance, before the blade slides into his chest and his body falls to the floor. %randombrother% turns toward you, his expression blank, giving away no emotions if there were some.%SPEECH_ON%I guess that needed to be done. This world isn\'t one of mercy.%SPEECH_OFF%He breathes out loudly and sheathes the sword. His expression stil one of stone, before he turns away. There is nothing left to do here, so you tell your men to gather all their belongings and move on.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Good death.",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						_event.m.Dude = null;
						return 0;
					}

				}
			],
			function start( _event )
			{
				
			}

		});
		this.m.Screens.push({
			ID = "LeftAlone",
			Text = "[img]gfx/ui/events/event_145.png[/img]{The survivor\'s expression does not change much, but it seems to show a hint of gratitude and relaxation. %randombrother% turns towards you, his face visibly bemused and confused.%SPEECH_ON%It\'s not likely, though he might survive. What if he warns his friends? Comes back with some of them for revenge?%SPEECH_OFF%You tell your man, that you make the decisions here and if this man happens to live, then that is what fate and the old gods wanted. So it will be. %randombrother% nods and agrees it will be as you want it. There is nothing left to do here, so you tell your men to gather all their belongings and move on.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Good luck.",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						_event.m.Dude = null;
						return 0;
					}

				}
			],
			function start( _event )
			{
				
			}

		});
	}

	
	function recruit(probabilities, backgrounds)
	{
		local r = this.Math.rand(1,100);
				
		if (r <= probabilities[0])
		{
			this.m.RecruitResult = "KillAttempt";
			return;
		}
		if (r <= probabilities[0] + probabilities[1])
		{
			this.m.RecruitResult = "DeadAnyway";
			return;
		}
		
		local roster = this.World.getTemporaryRoster();
		this.m.Dude = roster.create("scripts/entity/tactical/player");
		local selectedBackground;
		local totalScore = 0;
		foreach (background in backgrounds)
		{
			totalScore += background.score;
		}
		local s = this.Math.rand(1, totalScore);
		foreach (background in backgrounds)
		{
			if ( s<= background.score)
			{
				selectedBackground = background.name;
				break;
			}
			s -= background.score;
		}
		
		this.m.Dude.setStartValuesEx([
			selectedBackground
		]);
		
		this.m.Dude.getBackground().m.RawDescription = "%name% was taken to your crew after barely surviving in a battle against your men. He swore loyalty and will fight for you as well as any man.";
		this.m.Dude.getBackground().buildDescription(true);
		local permanent = this.Const.Injury.Permanent[this.Math.rand(0, this.Const.Injury.Permanent.len()-1)];
		local temporary = this.Const.Injury.All[this.Math.rand(0, this.Const.Injury.All.len()-1)];
		this.m.Dude.getSkills().add(this.new("scripts/skills/" + permanent.Script));
		this.m.Dude.getSkills().add(this.new("scripts/skills/" + temporary.Script));
		this.m.Dude.m.Hitpoints = 10;
		this.m.Dude.getSkills().update();
		local items = this.m.Dude.getItems();
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
		
		this.m.RecruitResult = "Recruited";
		return "Recruited";
	}
	
	function isValid()
	{
		
		
		if (!this.Const.DLC.Wildmen)
		{
			return;
		}

		if (!this.World.Flags.get("NorthExpansionActive") )
		{
			return;
		}
		
		if (!this.m.IsSpecial && this.Time.getVirtualTimeF() < this.m.CooldownUntil)
		{
			return;
		}
		

		if (this.World.getPlayerRoster().getSize() >= this.World.Assets.getBrothersMax())
		{
			return;
		}
		
		if(this.World.Flags.get("NorthExpansionCivilLevel") != 1) {
			return false;
		}
		
		if(!this.getFlags.get("SurvivorRecruited")) {
			return false;
		}

	
		if (this.Time.getVirtualTimeF() - this.World.Events.getLastBattleTime() > 5.0 || this.World.Statistics.getFlags().getAsInt("LastCombatResult") != 1)
		{
			return false;
		}
		
		

		local f = this.World.FactionManager.getFaction(this.World.Statistics.getFlags().getAsInt("LastCombatFaction"));

		if (f == null)
		{
			return false;
		}

		if (f.getType() != this.Const.FactionType.NobleHouse && f.getType() != this.Const.FactionType.Settlement && f.getType() != this.Const.FactionType.Bandits && f.getType() != this.Const.FactionType.Barbarians)
		{
			return false;
		}
		
		
		if (this.World.Statistics.getFlags().getAsInt("LastCombatID") <= this.m.LastCombatID && !this.m.shouldTrigger)
		{
			this.m.LastCombatID = this.World.Statistics.getFlags().getAsInt("LastCombatID");
			return false;
		}
		this.m.LastCombatID = this.World.Statistics.getFlags().getAsInt("LastCombatID");
		
		logInfo("survivors event");
		
		if (this.m.shouldTrigger)
		{
			logInfo("old trigger activated");
			return true;
		}
		
		local chance = 0;
		local enemyNumber = this.World.Statistics.getFlags().getAsInt("LastEnemiesDefeatedCount");
		chance += enemyNumber * 2;
		local freeSpots = this.World.Assets.getBrothersMax() - this.World.getPlayerRoster().getSize();
		chance += freeSpots*2;
		
		if (f.getType() == this.Const.FactionType.Barbarians)
		{
			chance += 20;
		}
		logInfo("survivors chance:" + chance);
		local roll = this.Math.rand(1, 100);
		logInfo("survivors roll:" + roll);
		if(roll > chance) {
			return false;
		}
		logInfo("survirors event trigger");
		this.m.shouldTrigger = true;
		return true;
	}

	function onUpdateScore()
	{
		return;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onDetermineStartScreen()
	{
		this.m.shouldTrigger = false;
		local f = this.World.FactionManager.getFaction(this.World.Statistics.getFlags().getAsInt("LastCombatFaction"));

		if (f.getType() == this.Const.FactionType.NobleHouse)
		{
			return "Civilians";
		}
		else if (f.getType() == this.Const.FactionType.Settlement)
		{
			return "Civilians";
		}
		if (f.getType() == this.Const.FactionType.Bandits)
		{
			return "Barbarians";
		}
		else if (f.getType() == this.Const.FactionType.Barbarians)
		{
			return "Barbarians";
		}
		else
		{
			return "Civilians";
		}
	}

	function onClear()
	{
		this.m.Dude = null;
		this.m.RecruitResult = null;
	}

	function onSerialize( _out )
	{
		this.event.onSerialize(_out);
		_out.writeU32(this.m.LastCombatID);
	}

	function onDeserialize( _in )
	{
		this.event.onDeserialize(_in);

		if (_in.getMetaData().getVersion() >= 54)
		{
			this.m.LastCombatID = _in.readU32();
		}
		this.m.shouldTrigger = false;
		
	}
	
	function getBackground()
	{
	}

});

