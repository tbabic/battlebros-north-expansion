this.bastard_volunteer_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.bastard_volunteer";
		this.m.Title = "Along the way...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "%terrainImage%You walks over a hill and sees a man in black cloak fighting undead. It looks like there is a large wolf helping him out.The man\'s sword cuts and slashes through the unded and wolf tears rips and shred them until they are all dead again.%randombrother% comes up and says%SPEECH_ON%He's not bad with that blade. Looks like he has it handled.%SPEECH_OFF%Just as he has finished those words a new group of undead comes over the hill. The man with the sword breathes visibly and you are not sure he has the strength to fight them again. He seems to realize it too and starts running away, but his steps are heavy and slow. He will not outrun them.",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Let's help him out.", 
					function getResult( _event )
					{
						
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
						p.CombatID = "JonSnow";
						p.Music = this.Const.Music.UndeadTracks;
						
						p.Entities = [];
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Zombies, 0.5* this.Math.rand(90, 110) * _event.getReputationToDifficultyLightMult(), this.Const.Faction.Enemy);
						
						
						_event.registerToShowAfterCombat("Aftermath", null);
						this.World.State.startScriptedCombat(p, false, false, true);
						
						return 0;
					}

				},
				{
					Text = "Not our troubles.",
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
					"bastard_background"
				]);
				
				
				local actor = _event.m.Dude;
				actor.getSprite("head").setBrush("bust_head_05");
				actor.getSprite("hair").setBrush("hair_black_19");
				local beard = actor.getSprite("beard");
				beard.setBrush("beard_black_16");
				if (this.doesBrushExist(beard.getBrush().Name + "_top"))
				{
					logInfo("beardTop");
					local sprite = actor.getSprite("beard_top");
					sprite.setBrush(beard.getBrush().Name + "_top");
					sprite.Color = actor.getSprite("hair").Color;
				}

					
				
				_event.m.Dude.getBackground().m.RawDescription = "{%name% was born during a fiery military campaign far away from his father\'s home. His father, head of an old and noble house provided him with same training as his half-brothers, but not the same opportunities. During a war, his father and half brother's were all killed and executed. %name% was forced to escape his home castle, save only by the fact he did not carry his father\'s name. After you saved him against the undead he is willing to follow you and fight for you, hoping one day he might have the opportunity for revenge against the nobles.";
				_event.m.Dude.getBackground().buildDescription(true);
				
				foreach( trait in this.Const.CharacterTraits ) {
					_event.m.Dude.getSkills().removeByID(trait[0]);
				}
				
				_event.m.Dude.setName("Jon");
				_event.m.Dude.setTitle("The Crow");
				
				
				local b = _event.m.Dude.getBaseProperties();
				b.Bravery = 35;
				if (b.MeleeDefense < 0) {
					b.MeleeDefense = 0;
				}
				local survivor = this.new("scripts/skills/traits/survivor_trait");
				local wolfmaster = this.new("scripts/skills/traits/wolfmaster_trait");
				if (survivor == null) {
					logInfo("survivor null");
				}
				if (wolfmaster == null) {
					logInfo("wolfmaster null");
				}
				_event.m.Dude.getSkills().add(this.new("scripts/skills/traits/hate_undead_trait"));
				//hate undead or survivor trait
				_event.m.Dude.getSkills().add(survivor);
				_event.m.Dude.getSkills().add(wolfmaster);
				
				::NorthMod.Utils.guaranteedTalents(_event.m.Dude, this.Const.Attributes.MeleeSkill, 1);
	
				
				_event.m.Dude.getSkills().update();
				
				
				local items = _event.m.Dude.getItems();
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				
				items.equip(this.new("scripts/items/accessory/direwolf_item"));
				items.equip(this.new("scripts/items/armor/ragged_dark_surcoat"));
				local helmet = this.new("scripts/items/helmets/nasal_helmet");
				helmet.setVariant(91);
				items.equip(helmet);
				
				local sword = this.new("scripts/items/weapons/named/longclaw");
				items.equip(sword);
				
				
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Aftermath",
			Text = "%terrainImage%{The battle is over and the man in black approaches you, the wolf keeping at his heel.%SPEECH_ON%I\'m %jonsnow%.%SPEECH_OFF% He pauses, perhaps waiting to see if you\'ll recognize the name or just to catch his breath. After no reaction from you, he continues.%SPEECH_ON%Thank you for helping me out. I owe you a debt of gratitude and my honor bounds me to help you back, if you\'ll have me, ofcourse.%SPEECH_OFF%%randombrother% whispers in your ear.%SPEECH_ON%He\'s got some skill with the sword, but I don\'t trust that beast of his%SPEECH_OFF%}", 
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Welcome, we could use a man like you."
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
					Text = "We have no need for you, nor your wolf.",
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
				this.Characters.push(_event.m.Dude.getImagePath());
			}
		});
	}

	function onUpdateScore()
	{		
		local multiplier = 1;
		if (!this.Const.DLC.Wildmen)
		{
			return;
		}
		
		if (!this.World.Flags.get("NorthExpansionCivilActive") )
		{
			return;
		}
		if (this.World.getPlayerRoster().getSize() >= this.World.Assets.getBrothersMax())
		{
			return;
		}
		
		if (this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.roster_of_12")
		{
			multiplier = 4;
		}
		
		if(this.World.Flags.get("NorthExpansionCivilLevel") == 2) {
			multiplier = multiplier * 2;
		}
		
		this.m.Score = 5 * multiplier;

	}
	
	function onPrepareVariables( _vars )
	{
		_vars.push([
			"jonsnow",
			this.m.Dude.getName()
		]);
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

