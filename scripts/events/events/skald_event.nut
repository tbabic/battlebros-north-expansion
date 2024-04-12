this.skald_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null
	},
	function create()
	{
		this.m.ID = "event.skald";
		this.m.Title = "Along the way...";
		this.m.Cooldown = 999999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_33.png[/img]As night falls upon the rugged mountain pass, you prepare to prepare the camp for the night. Yet, before settling in, %randombrother% returns from scouting, bearing troubling news.%SPEECH_ON%Chief, some mercenaries have made camp nearby. They seem well armed and ready for a fight. Might be they are looking for us, might be not. I doubt we could surprise them, though.%SPEECH_OFF%You pause to gather your thoughts. Mercenaries won't be an easy fight. But leaving them, they might present a bigger threat later.",
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
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Mercenaries, 0.8* this.Math.rand(90, 110) * _event.getReputationToDifficultyLightMult(), this.Const.Faction.Enemy);
						
						
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
						return "";
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
				
				_event.m.Dude.getBackground().m.RawDescription = "{%name% has spent his life in mountains and hills and raiding so called 'civilized' lands from there. He keeps talking about the moon and it's blessings, while you are not sure he makes much sense, you do notice he is a ruthless and vicious fighter during night.";
				_event.m.Dude.getBackground().buildDescription(true);
				
				foreach( trait in this.Const.CharacterTraits ) {
					_event.m.Dude.getSkills().removeByID(trait[0]);
				}
				
				_event.m.Dude.setName("Krumr");
				_event.m.Dude.setTitle("Beloved O' Moon");
				
				
				local b = _event.m.Dude.getBaseProperties();


				_event.m.Dude.getSkills().add(this.new("scripts/skills/traits/skald_trait"));
	
				
				//::NorthMod.Utils.guaranteedTalents(_event.m.Dude, this.Const.Attributes.MeleeSkill, 1);
	
				
				_event.m.Dude.getSkills().update();
				
				
				local items = _event.m.Dude.getItems();

				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				local hammer = this.new("scripts/items/weapons/barbarians/skull_hammer");
				items.equip(hammer);

				
				
				
				
				
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
		this.m.Screens.push({
			ID = "Victory",
			Text = "[img]gfx/ui/events/event_33.png[/img]{You look upon the scene of carnage, blood soaking ground, bodies slashed and crushed. Out of the darkness a man steps forward, he's carrying a heavy hammer.%SPEECH_ON%A good job you boys did. A very good job indeed!%SPEECH_OFF%The man speaks to you in a jovial manner, as if he knows you your whole life. You ask him what's he doing here and he replies that he came to deal with the mercenaries. He explains that nobles send men from time to time looking for him.%SPEECH_ON%But the men they send, they never return, because they are not favoured by the Moon. Not like you, boys.%SPEECH_OFF%You start to suspect the man might be touched in the head but then he continues. %SPEECH_ON%Seeing as you boys my job for me, now I have nothing to do. Indeed it seems that I'm in a need of a work. Might be you boys would let me come along? The Moon will bless us double if we are together. I'm %skald% by the way.%SPEECH_OFF%}", 
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
				this.Characters.push(_event.m.Dude.getImagePath());
			}
		});
	}

	function onUpdateScore()
	{		

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
		
		local currentTile = this.World.State.getPlayer().getTile();

		if (currentTile.Type != this.Const.World.TerrainType.Mountains)
		{
			return;
		}
		local multiplier = 1;
		if (this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.roster_of_12")
		{
			multiplier = 4;
		}
		this.m.Score = 20 * multiplier;

	}
	
	function onPrepareVariables( _vars )
	{
		_vars.push([
			"skald",
			this.m.Dude.getNameOnly()
		]);
	}

	function onClear()
	{
		this.m.Dude = null;
	}

});

