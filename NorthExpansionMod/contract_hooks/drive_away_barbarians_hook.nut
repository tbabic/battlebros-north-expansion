::mods_hookExactClass("contracts/contracts/drive_away_barbarians_contract", function(o) {
	
	local createScreens = ::mods_getMember(o, "createScreens");
	::mods_override(o, "createScreens", function() {
		::NorthMod.ContractUtils.addScreen(this, {
			ID = "TheDuel1",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_139.png[/img]{Just as it seems the %companyname% is ready to clash with the savages, a lone figure steps out and stands between the battle lines. He\'s got a parted long beard knotted around tortoise shells and his head is sheltered beneath a sloping snout of a wolf\'s skull. The elder stands unarmed save for a long staff which clatters with tethered deer horns. Shockingly, he speaks in your tongue.%SPEECH_ON%Outsiders. Welcome to the North. We are not so inhospitable as you may think. As is our tradition, we believe that battle between two men is just as honorable and of value as that between two armies. So it is, I offer my strongest champion, %barbarianname%.%SPEECH_OFF%A burly man steps forward. He unhooks the pelts and tosses them aside to reveal a body of pure muscle, tendon, and scars. The elder nods.%SPEECH_ON%Put forth your champion, Outsiders, and we shall share a day that all our ancestors will smile upon.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "I\'d rather burn down this whole camp. Attack!",
					function getResult()
					{
						this.Flags.set("IsDuel", false);
						this.Flags.set("IsAttackDialogTriggered", true);
						this.Contract.getActiveState().onDestinationAttacked(this.Contract.m.Destination);
						return 0;
					}

				}
			],
			function start()
			{
				local raw_roster = this.World.getPlayerRoster().getAll();
				local roster = [];

				foreach( bro in raw_roster )
				{
					if (bro.getPlaceInFormation() <= 17)
					{
						roster.push(bro);
					}
				}

				roster.sort(function ( _a, _b )
				{
					if (_a.getXP() > _b.getXP())
					{
						return -1;
					}
					else if (_a.getXP() < _b.getXP())
					{
						return 1;
					}

					return 0;
				});
				local name = this.Flags.get("ChampionName");
				local difficulty = this.Contract.getDifficultyMult();
				local e = this.Math.min(3, roster.len());
				
				local champion;
				local avatar;
				foreach( bro in raw_roster )
				{
					if (bro.getSkills().getSkillByID("trait.champion"))
					{
						champion = bro;
					}
					
					if (bro.getFlags().get("IsPlayerCharacter") || bro.getFlags().get("IsPlayerCharacterAvatar"))
					{
						avatar = bro;
					}
				}
				local championText = champion.getName() + " is my champion and he will win!";
				if (champion == avatar)
				{
					 championText = "I, " + champion.getName() + ", will fight your champion and win!"
				}
				this.Options.push({
					Text = championText,
					function getResult() {
						this.Flags.set("ChampionBrotherName", champion.getName());
						this.Flags.set("ChampionBrother", champion.getID());
						return "TheDuel2";
					}
				});
				
				foreach(bro in roster)
				{
					
					if (this.Options.len() > e)
					{
						break;
					}
					if (bro == champion)
					{
						continue;
					}
					local text = bro.getName() + " will fight your champion!";
					if (bro == avatar)
					{
						text = "I, " + text;
					}
					this.Options.push({
						Text = roster[i].getName() + " will fight your champion!",
						function getResult()
						{
							this.Flags.set("ChampionBrotherName", bro.getName());
							this.Flags.set("ChampionBrother", bro.getID());
							local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
							properties.CombatID = "Duel";
							properties.Music = this.Const.Music.BarbarianTracks;
							properties.Entities = [];
							properties.Entities.push({
								ID = this.Const.EntityType.BarbarianChampion,
								Name = name,
								Variant = difficulty >= 1.15 ? 1 : 0,
								Row = 0,
								Script = "scripts/entity/tactical/humans/barbarian_champion",
								Faction = this.Contract.m.Destination.getFaction(),
								function Callback( _entity, _tag )
								{
									_entity.setName(name);
								}

							});
							properties.EnemyBanners.push(this.Contract.m.Destination.getBanner());
							properties.Players.push(bro);
							properties.IsUsingSetPlayers = true;
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
							this.World.Contracts.startScriptedCombat(properties, false, true, false);
							return 0;
						}

					});
					  // [062]  OP_CLOSE          0      7    0    0
				}
			}

		});
	});
	
	
});
