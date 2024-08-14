this.moonkissed_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.moonkissed";
		this.m.Title = "Along the way...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_33.png[/img]Night falls, casting shadows over the land as the moon slowly emerges, illuminating the landscape with its soft, silvery light. As you prepare to prepare to camp for the night, %randombrother% returns from scouting. Looking at his expression you can see he does not have good news.%SPEECH_ON%Chief, some mercenaries have made camp nearby. They seem well armed and ready for a fight. Might be they are looking for us, might be not. I doubt we could surprise them, though.%SPEECH_OFF%You pause to gather your thoughts. Mercenaries won't be an easy fight. But leaving them unchecked, they might present a bigger threat later.",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Mercenaries are a threat, we should deal with them.", 
					function getResult( _event )
					{
						
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
						p.CombatID = "KrumSkald";
						p.Music = this.Const.Music.UndeadTracks;
						
						p.Entities = [];
						local faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Bandits).getID();
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Mercenaries, 0.8* this.Math.rand(90, 110) * _event.getReputationToDifficultyLightMult(), faction);
						
						
						_event.registerToShowAfterCombat("Victory", null);
						this.World.State.startScriptedCombat(p, false, false, true);
						
						return 0;
					}

				},
				{
					Text = "Better not to fight them now.",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						_event.m.Dude = null;
						return "Avoid";
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
				
				_event.m.Dude.getBackground().m.RawDescription = "{%name% has spent his life in mountains and hills, raiding so called 'civilized' lands from there. He keeps talking about the moon and it's blessings, while you are not sure he makes much sense, you do notice he is a ruthless and vicious fighter during night.";
				_event.m.Dude.getBackground().buildDescription(true);
				
				foreach( trait in this.Const.CharacterTraits ) {
					_event.m.Dude.getSkills().removeByID(trait[0]);
				}
				
				_event.m.Dude.setName("Krumr");
				_event.m.Dude.setTitle("Beloved O' Moon");
				
				
				local b = _event.m.Dude.getBaseProperties();

				local trait = this.new("scripts/skills/traits/night_owl_trait");
				if (trait == null)
				{
					this.logInfo("trait null");
				}
				_event.m.Dude.getSkills().add(trait);
				_event.m.Dude.getSkills().add(this.new("scripts/skills/traits/moonkissed_trait"));
	
				
				//::NorthMod.Utils.guaranteedTalents(_event.m.Dude, this.Const.Attributes.Bravery, 2);
	
				
				_event.m.Dude.getSkills().update();
				
				
				local items = _event.m.Dude.getItems();

				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				local hammer = this.new("scripts/items/weapons/barbarians/skull_hammer");
				items.equip(hammer);

				
				
				
				
				
				//this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Victory",
			Text = "[img]gfx/ui/events/event_33.png[/img]{You look upon the scene of carnage: blood-soaked ground, bodies slashed and crushed. Out of the darkness, a man steps forward, carrying a heavy hammer.%SPEECH_ON%A good job you boys did. A very good job indeed!%SPEECH_OFF%He speaks to you in a jovial manner, as if he\'s known you your whole life. You ask him what he\'s doing here, and he replies that he came to deal with the mercenaries. He explains that nobles send men from time to time looking for him.%SPEECH_ON%But the men they send never return, because they are not favored by the Moon. Not like you, boys.%SPEECH_OFF%You start to suspect the man might be touched in the head, but then he continues.%SPEECH_ON%Seeing as you did my job for me, now I have nothing to do. Indeed, it seems that I\'m in need of work. Might be you would let me come along? The Moon will bless us double, if we are together. I\'m %skald%, by the way.%SPEECH_OFF%}", 
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Sure, we could use a crazy man."
					function getResult( _event )
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						if(_event.m.Dude.getSkills().hasSkill("trait.skald"))
						{
							this.logInfo("is skald");
						}
						else
						{
							this.logInfo("no skald");
						}
						if(_event.m.Dude.getSkills().hasSkill("trait.moonkissed"))
						{
							this.logInfo("is moonkissed");
						}
						else
						{
							this.logInfo("no moonkissed");
						}
						_event.m.Dude = null;
						return 0;
					}

				},
				{
					Text = "We have no need for you.",
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
		this.m.Screens.push({
			ID = "Avoid",
			Text = "[img]gfx/ui/events/event_33.png[/img]{You decide to evade the mercenaries, but order your men to remain vigilant. Soon after, %randombrother% seeks you out.%SPEECH_ON%The mercenaries are add dead. Every single one.%SPEECH_OFF%You ask how and he describes a gruesome scene: crushed skulls, shattered ribcages, and limbs strewn about. Blood soaks the ground. You ask if there was any sign of attackers. He shakes his head.%SPEECH_ON%Not much, it just... I think there was someone singing in the distance. Something about the moon.%SPEECH_OFF%}", 
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Strange happenings.",
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

	function onUpdateScore()
	{		
		logInfo("update score: " + this.m.ID);
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
		
		if(this.World.Flags.get("NorthExpansionCivilLevel") != 1) {
			return;
		}
		
		if(this.World.getTime().IsDaytime)
		{
			return;
		}
		if(this.World.getTime().Days < 20)
		{
			return;
		}
		
		
		local currentTile = this.World.State.getPlayer().getTile();
		local multiplier = 1;
		if (currentTile.Type == this.Const.World.TerrainType.Mountains)
		{
			multiplier = multiplier*2;
		}
		
		if (this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.roster_of_12")
		{
			multiplier = multiplier*4;
		}
		this.m.Score = 20 * multiplier;
		logInfo("updated score: " + this.m.ID + " - " + this.m.Score);

	}
	
	function onPrepareVariables( _vars )
	{
		if (this.m.Dude != null)
		{
			_vars.push([
				"skald",
				this.m.Dude.getNameOnly()
			]);
		}
		
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

