this.threetrees_volunteer_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.threetrees_volunteer";
		this.m.Title = "Along the way...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "%terrainImage%As you walk through the wilderness you come up on an old man sitting on a large stump, huge round shield, resting next to his feet. As you come closer, he speaks in a stern, almost reprimanding tone.%SPEECH_ON%The way you\'ve been walking through the forest, any old fool could sneak up on you. You are lucky I\'ve decided to wait for you, rather than have my men come up from behind and attack you.%SPEECH_OFF%You point out to the man that he is alone and ask where his men are.%SPEECH_ON%Aye, they are all back in the snow now. That\'s why I\'m waiting here and not attacking from behind. Let me be straight with you. I\'ve heard about you, some good and some bad. Some I like, some I don\'t. But, I\'m alone here on account of my men being gone. Well not alone anymore, you boys are also here. There\'s safety in numbers and these lands are dangerous. There are giants roaming around these parts. Worse things too…%SPEECH_OFF%He continues talking about dangers and his experience. You are not sure, but think he wants to join your company, without actually asking.",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Why don't you join us, old boy.", 
					function getResult( _event )
					{
						
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
						return 0;
					}

				},
				{
					Text = "We'll continue on our way now. Goodbye.",
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
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");
				_event.m.Dude.setStartValuesEx([
					"barbarian_background"
				]);
				
				
				local actor = _event.m.Dude;
				actor.getSprite("hair").setBrush("hair_grey_03");
				local beard = actor.getSprite("beard");
				beard.setBrush("beard_grey_13");
				if (this.doesBrushExist(beard.getBrush().Name + "_top"))
				{
					logInfo("beardTop");
					local sprite = actor.getSprite("beard_top");
					sprite.setBrush(beard.getBrush().Name + "_top");
					sprite.Color = actor.getSprite("hair").Color;
				}

					
				
				_event.m.Dude.getBackground().m.RawDescription = "{%name% is a great, broad-chested old veteran warrior. He's old even for southern men, let alone northerners. Some time ago, his crew died fighting when ambushed by unholds, him being the only survivor. After that he spent his time surviving in the north, on his own, until he met you.}";
				_event.m.Dude.getBackground().buildDescription(true);
				_event.m.Dude.setName("Tormund");
				_event.m.Dude.setTitle("Old Boy");
				
				foreach( trait in this.Const.CharacterTraits ) {
					_event.m.Dude.getSkills().removeByID(trait[0]);
				}
			
				local shieldmaster = this.new("scripts/skills/traits/shieldmaster_trait");
				local tough = this.new("scripts/skills/traits/tough_trait");
				local old = this.new("scripts/skills/traits/old_trait");
				
				_event.m.Dude.getSkills().add(shieldmaster);
				_event.m.Dude.getSkills().add(tough);
				_event.m.Dude.getSkills().add(old);
				
				::NorthMod.Utils.guaranteedTalents(_event.m.Dude, this.Const.Attributes.MeleeDefense, 2);
				
				
				_event.m.Dude.getSkills().update();
				
				local items = _event.m.Dude.getItems();
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				
				items.equip(this.new("scripts/items/armor/barbarians/scrap_metal_armor"));
				items.equip(this.new("scripts/items/shields/named/threetrees_shield"));
				items.equip(this.new("scripts/items/weapons/arming_sword"));
				
				
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{	
		logInfo("update score: " + this.m.ID);	
		local multiplier = 1;
		if (!this.Const.DLC.Wildmen)
		{
			return;
		}
		
		if (!this.World.Flags.get("NorthExpansionActive") )
		{
			return;
		}
		if (this.World.getPlayerRoster().getSize() >= this.World.Assets.getBrothersMax())
		{
			return;
		}
		if(this.World.Flags.get("NorthExpansionCivilLevel") >= 3) {
			return;
		}
		
		if (this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.roster_of_12")
		{
			multiplier = 4;
		}
		
		
		
		this.m.Score = 5 * multiplier;
		logInfo("updated score: " + this.m.ID + " - " + this.m.Score);

	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

