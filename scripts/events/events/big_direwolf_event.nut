this.big_direwolf_event <- this.inherit("scripts/events/event", {
	m = {
		DirewolfItem = null,
		Wolfmaster = null
	},
	function create()
	{
		this.m.ID = "event.big_direwolf";
		this.m.Title = "During camp...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		
		this.m.Screens.push({
			ID = "A",
			Text = "%terrainImage%{You\'ve recently observed %wolfmaster%\'s direwolf growing larger, its size becoming increasingly imposing. When you comment on its growth, %wolfmaster% responds with a wry grin. %SPEECH_ON% Aye, he\'s also getting hungrier too. His apetite is insatiable, just now he's eaten a big chunk of meat. The good news is, I think %direwolf% is now even more aggresive in a fight.%SPEECH_OFF% You can\'t help but feel a twinge of concern, but the beast is very well trained and seems to obey %wolfmaster% without delay.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Bigger direwolf is a better direwolf",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				_event.m.DirewolfItem.m.Level = 2;
				local strangeMeat = this.World.Assets.getStash().getItemByID("supplies.strange_meat");
				
				
				this.List.push({
					id = 10,
					icon = "ui/items/" + strangeMeat.getIcon(),
					text = "You lose " + strangeMeat.getName()
				});
				
				this.List.push({
					id = 10,
					icon = "ui/items/" + _event.m.DirewolfItem.getIcon(),
					text = _event.m.DirewolfItem.getName() + " is now more effective in combat."
				});
				
				this.World.Assets.getStash().remove(strangeMeat);
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
		
		local strangeMeat = this.World.Assets.getStash().getItemByID("supplies.strange_meat");
		if (strangeMeat == null)
		{
			return;
		}
		
		local brothers = this.World.getPlayerRoster().getAll();

		foreach( bro in brothers )
		{
			
			if (bro ==null || !bro.getSkills().hasSkill("trait.wolfmaster") || bro.getLevel() < 5)
			{
				continue;
			}
			
			local accessory = bro.getItems().getItemAtSlot(this.Const.ItemSlot.Accessory);
			if(accessory != null && accessory.getID() == "accessory.direwolf" )
			{
				this.m.DirewolfItem = accessory;
				this.m.Wolfmaster = bro;
				this.m.Score = 20;
				return;
			}
		}
		
		

		
	}

	function onPrepare()
	{
		
		local brothers = this.World.getPlayerRoster().getAll();

		foreach( bro in brothers )
		{
			
			if (bro ==null || !bro.getSkills().hasSkill("trait.wolfmaster") || bro.getLevel() < 5)
			{
				continue;
			}
			
			local accessory = bro.getItems().getItemAtSlot(this.Const.ItemSlot.Accessory);
			if(accessory != null && accessory.getID() == "accessory.direwolf" )
			{
				this.m.DirewolfItem = accessory;
				this.m.Wolfmaster = bro;
				this.m.Score = 20;
				return;
			}
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"wolfmaster",
			this.m.Wolfmaster.getName()
		]);
		
		_vars.push([
			"direwolf",
			this.m.DirewolfItem.getName()
		]);
	}

	function onClear()
	{
		this.m.DirewolfItem = null;
		this.m.Wolfmaster = null;
	}
	
	function onDeserialize( _in )
	{
		this.m.CooldownUntil = _in.readF32();
		this.logInfo("big direwolf: " + this.m.CooldownUntil);
	}

});

