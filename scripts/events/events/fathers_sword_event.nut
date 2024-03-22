this.fathers_sword_event <- this.inherit("scripts/events/event", {
	m = {
		playerCharacter = null,
		fathersSword = null,
		selectedOption = null,
		multiplier = 50
		
	},
	function create()
	{
		this.m.ID = "event.fathers.sword";
		this.m.Title = "During camp...";
		this.m.Cooldown = this.m.multiplier * this.World.getTime().SecondsPerDay;
		
		local options = [];
		
		
		
		
		this.m.Screens.push({
			ID = "A",
			Text = "%terrainImage%{You sit at the campfire fiddling with your father\'s sword. You always took pride in your skill rather than weapon used, but now you think it might do with improvement.\n\nYou could sharpen it's edge so it does more damage.\n\nOr you could make it heavier to pierce armor better.\n\nPerhaps making it better balanced so it\'s easier to hit vulnerable body part.\n\nFinally, it occurs to you that you could improve the hilt and pommel which would make it easier to wield.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			function start( _event )
			{
				if (_event.m.playerCharacter.getFlags().getAsInt("ImprovedFathersSwordDamage")<5) {
					this.Options.push({
						Text = "I\'ll make it sharper.",
						function getResult( _event )
						{
							_event.m.selectedOption="damage";
							return "B";
						}

					});
				}
				
				if (_event.m.playerCharacter.getFlags().getAsInt("ImprovedFathersSwordArmorPierce")<3) {
					this.Options.push({
						Text = "Best weapons need to be able to cut through armor.",
						function getResult( _event )
						{
							_event.m.selectedOption="armorPierce";
							return "B";
						}

					});
				}
				
				if (_event.m.playerCharacter.getFlags().getAsInt("ImprovedFathersSwordHeadHit")<2) {
					this.Options.push({
						Text = "Perfect balance is necessary for perfect swing.",
						function getResult( _event )
						{
							_event.m.selectedOption="headHit";
							return "B";
						}

					});
				}
				
				if (_event.m.playerCharacter.getFlags().getAsInt("ImprovedFathersSwordFatigueMinus")<3) {
					this.Options.push({
						Text = "It will fit my hands like gloves. Really big gloves.",
						function getResult( _event )
						{
							_event.m.selectedOption="fatigueMinus";
							return "B";
						}
					});
				}
				
				this.Options.push({
					Text = "I should work on my skill, instead.",
					function getResult( _event )
					{
						return "C";
					}

				})
			}

		});
		this.m.Screens.push({
			ID = "B",
			Text = "%terrainImage%{You work on your sword for a few hours and are quite pleased with the results.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "It\'s perfect!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local _text = "";
			
				_event.m.playerCharacter.getFlags().increment("ImprovedFathersSword", 1);
				if (_event.m.selectedOption == "damage") {
					_event.m.playerCharacter.getFlags().increment("ImprovedFathersSwordDamage", 1);
					_event.m.fathersSword.m.RegularDamage+=8;
					_event.m.fathersSword.m.RegularDamageMax+=8;
					_text = _event.m.fathersSword.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+8[/color] Damage"
				}
				
				if (_event.m.selectedOption == "armorPierce") {
					_event.m.playerCharacter.getFlags().increment("ImprovedFathersSwordArmorPierce", 1);
					_event.m.fathersSword.m.DirectDamageAdd+=0.050001;
					_event.m.fathersSword.m.ArmorDamageMult+=0.050001;
					_text = _event.m.fathersSword.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+5%[/color] Ignore Armor and Armor Damage"
				}
				
				if (_event.m.selectedOption == "headHit") {
					_event.m.playerCharacter.getFlags().increment("ImprovedFathersSwordHeadHit", 1);
					_event.m.fathersSword.m.ChanceToHitHead+=10;
					_text = _event.m.fathersSword.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+10%[/color] Chance to hit head"
				}
				
				if (_event.m.selectedOption == "fatigueMinus") {
					_event.m.playerCharacter.getFlags().increment("ImprovedFathersSwordFatigueMinus", 1);
					_event.m.fathersSword.m.StaminaModifier+=2;
					_event.m.fathersSword.m.FatigueOnSkillUse+=-1;
					_text = _event.m.fathersSword.getName() + " reduces by [color=" + this.Const.UI.Color.PositiveEventValue + "]2[/color] maximum fatigue penalty\n\n" +
						_event.m.fathersSword.getName() + " reduces by [color=" + this.Const.UI.Color.PositiveEventValue + "]1[/color] fatigue cost for skill use";
				}
				
				this.List = [
					{
						id = 10,
						icon = "ui/items/" + _event.m.fathersSword.getIcon(),
						text = _text
					}
				];
				
			}

		});
		this.m.Screens.push({
			ID = "C",
			Text = "%terrainImage%{You work on your self for a few hours and are quite pleased with the results.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "I\'m perfect!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				_event.m.playerCharacter.getFlags().increment("ImprovedFathersSword", 1);
				
				_event.m.playerCharacter.getBaseProperties().MeleeSkill += 1;
				_event.m.playerCharacter.getSkills().update();
				this.List.push({
					id = 16,
					icon = "ui/icons/melee_skill.png",
					text = _event.m.playerCharacter.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+1[/color] Melee Skill"
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

		foreach( bro in brothers )
		{
			if (bro.getFlags().get("IsPlayerCharacter"))
			{
				this.m.playerCharacter = bro;
				break;
			}
		}
		
		local items = this.m.playerCharacter.getItems();
		local weapon = items.getItemAtSlot(this.Const.ItemSlot.Mainhand);
		if (weapon.m.ID == "weapon.fathers_sword") {
			this.m.fathersSword = weapon;
		} else {
			return;
		}
		
		local stats = this.m.playerCharacter.m.LifetimeStats;
		local counter = this.m.playerCharacter.getFlags().getAsInt("ImprovedFathersSword");

		
		if (counter >= 5) {
			return;
		}
		
		if (stats.Kills < (counter+1)*this.m.multiplier) {
			return;
		}

		this.m.Score = 10000;
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
		
	}

	function onClear()
	{
		this.m.playerCharacter = null;
		this.m.fathersSword = null;
		this.m.selectedOption = null;
	}

});

