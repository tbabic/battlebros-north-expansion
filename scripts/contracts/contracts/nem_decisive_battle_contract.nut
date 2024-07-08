this.nem_decisive_battle_contract <- this.inherit("scripts/contracts/barbarian_contract", {
	m = {
		Destination = null,
		Warcamp = null,
		WarcampTile = null,
		Dude = null,
		IsPlayerAttacking = false
	},
	function create()
	{
		this.contract.create();
		local r = this.Math.rand(1, 100);

		if (r <= 70)
		{
			this.m.DifficultyMult = this.Math.rand(95, 105) * 0.01;
		}
		else
		{
			this.m.DifficultyMult = this.Math.rand(115, 135) * 0.01;
		}

		this.m.Type = "contract.nem_decisive_battle";
		this.m.Name = "The Battle";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 7.0;
	}

	function start()
	{
		this.World.FactionManager.breakNobleHouseAlliances();
		//this.World.FactionManager.breakNorthSouthAlliances();
		if (this.m.Home == null)
		{
			this.setHome(this.World.State.getCurrentTown());
		}
		local settlements = this.World.EntityManager.getSettlements();
		
		local nobleHouses = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local closestSettlement = this.getNearestLocationTo(this.m.Home, settlements);
		local enemySettlements = [];
		foreach (s in settlements)
		{
			if (s == closestSettlement|| this.World.FactionManager.isAllied(closestSettlement.getOwner().getID(), s.getFaction()))
			{
				continue;
			}
			enemySettlements.push(s);
		}
		local closestEnemy = this.getNearestLocationTo(closestSettlement, enemySettlements);
		
		local inbetween = closestSettlement.getTile().getTileBetweenThisAnd(closestEnemy.getTile());
		this.m.WarcampTile = inbetween.getTileBetweenThisAnd(this.m.Home.getTile());
		this.m.Flags.set("enemy1", closestSettlement.getOwner().getID());
		this.m.Flags.set("enemy2", closestEnemy.getOwner().getID());

		this.m.Flags.set("CommanderName", ::NorthMod.Utils.barbarianNameAndTitle());
		this.m.Payment.Pool = 1600 * this.getPaymentMult() * this.Math.pow(this.getDifficultyMult(), this.Const.World.Assets.ContractRewardPOW) * this.getReputationToPaymentMult();
		local r = this.Math.rand(1, 2);

		if (r == 1)
		{
			this.m.Payment.Completion = 0.75;
			this.m.Payment.Advance = 0.25;
		}
		else if (r == 2)
		{
			this.m.Payment.Completion = 1.0;
		}

		this.m.Flags.set("RaidCost", this.beautifyNumber(this.m.Payment.Pool * 0.25));
		this.m.Flags.set("Bribe", this.beautifyNumber(this.m.Payment.Pool * 0.35));
		this.contract.start();
	}

	function createStates()
	{
		this.m.States.push({
			ID = "Offer",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Move to the war camp and report to %commander%",
					"Assist the army in their battle against %enemy1% and %enemy2%"
				];

				if (this.Math.rand(1, 100) <= this.Const.Contracts.Settings.IntroChance)
				{
					this.Contract.setScreen("Intro");
				}
				else
				{
					this.Contract.setScreen("Task");
				}
			}

			function end()
			{
				this.World.Assets.addMoney(this.Contract.m.Payment.getInAdvance());
				this.World.FactionManager.getFaction(this.Flags.get("enemy1")).addPlayerRelation(-99.0, "Took sides in the war");
				this.World.FactionManager.getFaction(this.Flags.get("enemy2")).addPlayerRelation(-99.0, "Took sides in the war");

				if (this.Contract.m.WarcampTile == null)
				{
					local settlements = this.World.EntityManager.getSettlements();
					local lowest_distance = 99999;
					local best_settlement;
					local myTile = this.Contract.m.Home.getTile();

					foreach( s in settlements )
					{
						if (this.World.FactionManager.isAllied(this.Contract.getFaction(), s.getFaction()))
						{
							continue;
						}

						local d = s.getTile().getDistanceTo(myTile);

						if (d < lowest_distance)
						{
							lowest_distance = d;
							best_settlement = s;
						}
					}

					this.Contract.m.WarcampTile = myTile.getTileBetweenThisAnd(best_settlement.getTile());
				}

				local tile = this.Contract.getTileToSpawnLocation(this.Contract.m.WarcampTile, 1, 12, [
					this.Const.World.TerrainType.Shore,
					this.Const.World.TerrainType.Ocean,
					this.Const.World.TerrainType.Mountains,
					this.Const.World.TerrainType.Forest,
					this.Const.World.TerrainType.LeaveForest,
					this.Const.World.TerrainType.SnowyForest,
					this.Const.World.TerrainType.AutumnForest,
					this.Const.World.TerrainType.Swamp
				], false, false, true);
				tile.clear();
				this.Contract.m.WarcampTile = tile;
				this.Contract.m.Warcamp = this.WeakTableRef(this.World.spawnLocation("scripts/entity/world/locations/noble_camp_location", tile.Coords));
				this.Contract.m.Warcamp.onSpawned();
				this.Contract.m.Warcamp.getSprite("banner").setBrush(this.World.FactionManager.getFaction(this.Contract.getFaction()).getBannerSmall());
				this.Contract.m.Warcamp.setFaction(this.Contract.getFaction());
				this.Contract.m.Warcamp.setDiscovered(true);
				this.World.uncoverFogOfWar(this.Contract.m.Warcamp.getTile().Pos, 500.0);
				local r = this.Math.rand(1, 100);

				if (r <= 40)
				{
					this.Flags.set("IsScoutsSighted", true);
				}
				else
				{
					this.Flags.set("IsRaidSupplies", true);
					r = this.Math.rand(1, 100);

					if (r <= 33)
					{
						this.Flags.set("IsAmbush", true);
					}
					else if (r <= 66)
					{
						this.Flags.set("IsUnrulyFarmers", true);
					}
					else
					{
						this.Flags.set("IsCooperativeFarmers", true);
					}
				}
				
				if (!this.Flags.get("IsRaidSupplies"))
				{
					if (this.World.FactionManager.getFaction(this.Flags.get("enemy1")).getSettlements().len() >= 2)
					{
						this.Flags.set("IsInterceptSupplies", true);
						local myTile = this.Contract.m.Warcamp.getTile();
						local settlements = this.World.FactionManager.getFaction(this.Flags.get("enemy1")).getSettlements();
						local lowest_distance = 99999;
						local highest_distance = 0;
						local best_start;
						local best_dest;

						foreach( s in settlements )
						{
							if (s.isIsolated())
							{
								continue;
							}

							local d = s.getTile().getDistanceTo(myTile);

							if (d < lowest_distance)
							{
								lowest_distance = d;
								best_dest = s;
							}

							if (d > highest_distance)
							{
								highest_distance = d;
								best_start = s;
							}
						}

						this.Flags.set("InterceptSuppliesStart", best_start.getID());
						this.Flags.set("InterceptSuppliesDest", best_dest.getID());
					}
				}
				else
				{
					this.Flags.set("IsBarbarians", true);
					r = this.Math.rand(1, 100);
					if (r <= 50)
					{
						this.Flags.set("IsBarbarianHonor", true);
					}
				}

				this.Contract.setScreen("Overview");
				this.World.Contracts.setActiveContract(this.Contract);
			}

		});
		this.m.States.push({
			ID = "Running",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Move to the war camp and talk with %commander%"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp) && !this.Flags.get("IsWarcampDay1Shown"))
				{
					this.Flags.set("IsWarcampDay1Shown", true);
					this.Contract.setScreen("WarcampDay1");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Running_WaitForNextDay",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Wait in the war camp until your are needed"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp))
				{
					if (this.World.getTime().Days > this.Flags.get("LastDay"))
					{
						if (this.Flags.get("NextDay") == 2)
						{
							this.Contract.setScreen("WarcampDay2");
							this.World.Contracts.showActiveContract();
						}
						else
						{
							this.preBattle();
						}

						
					}
				}
			}
			
			function preBattle()
			{
				local enemy1Strength = 150;
				local enemy2Strength = 150;
				local allyStrength = 120;
				
				local difficulty = this.Contract.getDifficultySkulls();
				local oddsShift = (difficulty -2)*20;
				
				local r = this.Math.rand(1, 100) + oddsShift;
				if (this.Flags.get("IsScoutsFailed"))
				{
					
					if (r > 50 && this.World.FactionManager.getFaction(this.m.Flags.get("enemy1")).getType() == this.World.FactionManager.getFaction(this.m.Flags.get("enemy2")).getType())
					{
						enemy1Strength = 90;
						enemy2Strength = 90;
						this.Flags.set("IsJoinedEnemies", true);
						this.Flags.set("enemy1Strength", enemy1Strength);
						this.Flags.set("enemy2Strength", enemy2Strength);
						this.Flags.set("allyStrength", allyStrength);
						this.Contract.setScreen("JoinedEnemies");
						this.World.Contracts.showActiveContract();
						return;
					}
					else
					{
						enemy1Strength += 25;
					}
				}
				
				if (this.Flags.get("IsBarbariansFailed"))
				{
					enemy2Strength += 25;
				}
				if (this.Flags.get("IsRaidRetreat") || this.Flags.get("IsInterceptSuppliesFailure"))
				{
					allyStrength -= 20;
				}
				if (this.Flags.get("IsBarbarianSwitch"))
				{
					allyStrength += 30;
				}
				
				this.Flags.set("enemy1Strength", enemy1Strength);
				this.Flags.set("enemy2Strength", enemy2Strength);
				this.Flags.set("allyStrength", allyStrength);
				if (allyStrength > 120 || r > 50)
				{
					this.Flags.set("IsUnexpectedCharge", true);
					this.Contract.setScreen("UnexpectedCharge");
					this.World.Contracts.showActiveContract();
					return;
				}
				
				
				local winnerStrength = 0;
				if(enemy1Strength > enemy2Strength)
				{
					this.Flags.set("winner", this.Flags.get("enemy1"));
					this.Flags.set("loser", this.Flags.get("enemy2"));
					winnerStrength = enemy1Strength;
				}
				else if (enemy2Strength > enemy1Strength || this.Math.rand(1, 100) > 50)
				{
					this.Flags.set("winner", this.Flags.get("enemy2"));
					this.Flags.set("loser", this.Flags.get("enemy1"));
					winnerStrength = enemy2Strength;
				}
				else
				{
					this.Flags.set("winner", this.Flags.get("enemy1"));
					this.Flags.set("loser", this.Flags.get("enemy2"));
					winnerStrength = enemy1Strength;
				}
				this.Flags.set("winnerStrength", winnerStrength);
				
				if(winnerStrength > 150 || r > 50)
				{
					this.Flags.set("IsReinforcements", true);
					this.Contract.setScreen("BatteredEnemyReinforcements");
					this.World.Contracts.showActiveContract();
					return;
				}
				
				
				this.Contract.setScreen("BatteredEnemy");
				this.World.Contracts.showActiveContract();
				
				
				
				
			}

		});
		this.m.States.push({
			ID = "Running_Scouts",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Intercept scouts of %enemy1% last seen %direction% of the warcamp",
					"Let no one escape alive"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onCombatWithScouts.bindenv(this));
				}
			}

			function update()
			{
				if (this.Contract.m.Destination == null || this.Contract.m.Destination.isNull())
				{
					if (this.Flags.get("IsScoutsFailed"))
					{
						this.Contract.setScreen("ScoutsEscaped");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("ScoutsCaught");
						this.World.Contracts.showActiveContract();
					}
				}
				else if (this.Flags.get("IsScoutsRetreat"))
				{
					this.Flags.set("IsScoutsRetreat", false);
					this.Contract.m.Destination.die();
					this.Contract.m.Destination = null;
					this.Contract.setScreen("ScoutsEscaped");
					this.World.Contracts.showActiveContract();
				}
			}

			function onCombatWithScouts( _dest, _isPlayerAttacking = true )
			{
				local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
				properties.CombatID = "Scouts";
				properties.Music = this.Const.Music.NobleTracks;
				properties.EnemyBanners = [
					this.World.FactionManager.getFaction(this.Flags.get("enemy1")).getBannerSmall()
				];
				this.World.Contracts.startScriptedCombat(properties, _isPlayerAttacking, true, true);
			}

			function onActorRetreated( _actor, _combatID )
			{
				if (_combatID == "Scouts")
				{
					this.Flags.set("IsScoutsFailed", true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Scouts")
				{
					this.Flags.set("IsScoutsRetreat", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_ReturnAfterScouts",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Return to the war camp"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp) && !this.Flags.get("IsReportAfterScoutsShown"))
				{
					this.Flags.set("IsReportAfterScoutsShown", true);
					this.Contract.setScreen("WarcampDay1End");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Running_Raid",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Raid %objective% to the %direction% of the warcamp"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Destination) && !this.TempFlags.get("IsReportAfterRaidShown"))
				{
					this.TempFlags.set("IsReportAfterRaidShown", true);
					this.Contract.setScreen("RaidSupplies2");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsRaidRetreat") && !this.Flags.get("IsRaidCombatDone"))
				{
					this.Flags.set("IsRaidCombatDone", true);
					this.Contract.setScreen("BeatenByFarmers");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsRaidVictory") && !this.Flags.get("IsRaidCombatDone"))
				{
					this.Flags.set("IsRaidCombatDone", true);
					this.Contract.setScreen("PoorFarmers");
					this.World.Contracts.showActiveContract();
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Ambush" || _combatID == "TakeItByForce")
				{
					this.Flags.set("IsRaidRetreat", true);
				}
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "Ambush" || _combatID == "TakeItByForce")
				{
					this.Flags.set("IsRaidVictory", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_ReturnAfterRaid",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Return to the war camp"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp))
				{
					if (this.Flags.get("IsInterceptSupplies") || this.Flags.get("IsBarbarians"))
					{
						this.Contract.setScreen("WarcampDay1End");
						this.World.Contracts.showActiveContract();
					}
					else
					{
						this.Contract.setScreen("WarcampDay2End");
						this.World.Contracts.showActiveContract();
					}
				}
			}

		});
		this.m.States.push({
			ID = "Running_InterceptSupplies",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Intercept supplies enroute from %supply_start% to %supply_dest%"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setVisibleInFogOfWar(true);
				}
			}

			function update()
			{
				if (this.Flags.get("IsInterceptSuppliesSuccess"))
				{
					this.Contract.setScreen("SuppliesIntercepted");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Contract.m.Destination == null || this.Contract.m.Destination != null && this.Contract.m.Destination.isNull())
				{
					this.Flags.set("IsInterceptSuppliesFailure", true);
					this.Contract.setScreen("SuppliesReachedEnemy");
					this.World.Contracts.showActiveContract();
				}
			}

			function onPartyDestroyed( _party )
			{
				if (_party.getFlags().has("ContractSupplies"))
				{
					this.Flags.set("IsInterceptSuppliesSuccess", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_ReturnAfterIntercept",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Return to the war camp"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = true;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = false;
				}
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Warcamp))
				{
					this.Contract.setScreen("WarcampDay2End");
					this.World.Contracts.showActiveContract();
				}
			}

		});
		this.m.States.push({
			ID = "Running_Barbarians",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Follow the footprints and approach the barbarians",
					"Either convince them to switch sides, leave or kill them"
				];

				if (this.Contract.m.Warcamp != null && !this.Contract.m.Warcamp.isNull())
				{
					this.Contract.m.Warcamp.getSprite("selection").Visible = false;
				}

				if (this.Contract.m.Destination != null && !this.Contract.m.Destination.isNull())
				{
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnCombatWithPlayerCallback(this.onCombatWithBarbarians.bindenv(this));
				}
			}

			function update()
			{
				if (this.Flags.get("IsBarbariansFailed"))
				{
					if (this.Contract.m.Destination != null)
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
					}

					this.Contract.setState("Running_ReturnAfterIntercept");
				}
				else if (this.Contract.m.Destination == null || this.Contract.m.Destination != null && this.Contract.m.Destination.isNull())
				{
					this.Contract.setScreen("BarbariansAftermath");
					this.World.Contracts.showActiveContract();
				}
				
				if (this.Flags.get("IsDuelVictory"))
				{
					this.Contract.setScreen("BarbariansDuelWin");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsDuelDefeat"))
				{
					this.Contract.setScreen("BarbariansDuelLost");
					this.World.Contracts.showActiveContract();
				}
			}
			
			function onCombatWithBarbarians( _dest, _isPlayerAttacking = true)
			{
				this.Contract.m.IsPlayerAttacking = _isPlayerAttacking;
				if(!this.TempFlags.get("IsBarbarianApproachShown"))
				{
					this.TempFlags.set("IsBarbarianApproachShown", true);
					if (this.Flags.get("IsBarbarianHonor"))
					{
						this.Contract.setScreen("Barbarians2Honor");
					}
					else
					{
						this.Contract.setScreen("Barbarians2Bribe");
					}
					
					this.World.Contracts.showActiveContract();
				}
				else
				{
					_dest.getController().getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(true);
					local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
					properties.Music = this.Const.Music.BarbarianTracks;
					this.World.Contracts.startScriptedCombat(properties, this.Contract.m.IsPlayerAttacking, true, true);
				}
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "Barbarians")
				{
					this.Flags.set("IsBarbariansFailed", true);
				}
				
				if (_combatID == "Duel")
				{
					this.Flags.set("IsDuelDefeat", true);
				}
			}
			
			function onCombatVictory( _combatID )
			{
				if (_combatID == "Duel")
				{
					this.Flags.set("IsDuelVictory", true);
				}
			}

		});
		this.m.States.push({
			ID = "Running_FinalBattle",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Win the great battle"
				];
			}

			function update()
			{
				if (this.Flags.get("IsFinalBattleLost") && !this.Flags.get("IsFinalBattleLostShown"))
				{
					this.Flags.set("IsFinalBattleLostShown", true);
					this.Contract.m.Warcamp.die();
					this.Contract.m.Warcamp = null;
					this.Contract.setScreen("BattleLost");
					this.World.Contracts.showActiveContract();
				}
				else if (this.Flags.get("IsFinalBattleWon") && !this.Flags.get("IsFinalBattleWonShown"))
				{
					this.Flags.set("IsFinalBattleWonShown", true);
					this.Contract.m.Warcamp.die();
					this.Contract.m.Warcamp = null;
					this.Contract.setScreen("BattleWon");
					this.World.Contracts.showActiveContract();
				}
				else if (!this.TempFlags.get("IsFinalBattleStarted"))
				{
					this.TempFlags.set("IsFinalBattleStarted", true);
					this.prepareBattle();
				}
			}
			
			function prepareBattle()
			{
				local tile = this.Contract.getTileToSpawnLocation(this.Contract.m.Warcamp.getTile(), 3, 12, [
					this.Const.World.TerrainType.Shore,
					this.Const.World.TerrainType.Ocean,
					this.Const.World.TerrainType.Mountains,
					this.Const.World.TerrainType.Forest,
					this.Const.World.TerrainType.LeaveForest,
					this.Const.World.TerrainType.SnowyForest,
					this.Const.World.TerrainType.AutumnForest,
					this.Const.World.TerrainType.Swamp,
					this.Const.World.TerrainType.Hills
				], false);
				this.World.State.getPlayer().setPos(tile.Pos);
				this.World.getCamera().moveToPos(this.World.State.getPlayer().getPos());
				
				local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
				properties.CombatID = "FinalBattle";
				properties.Music = this.Const.Music.NobleTracks;
				properties.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
				properties.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
				properties.Entities = [];
				this.prepareAllies(properties);
				
				if (this.Flags.get("IsJoinedEnemies"))
				{
					this.prepareJoinedEnemies(properties);
				}
				else if(this.Flags.get("IsUnexpectedCharge"))
				{
					this.prepareUnexpectedCharge(properties);
				}
				else
				{
					this.prepareWinner(properties);
				}
				
				this.World.Contracts.startScriptedCombat(properties, false, true, true);
			}
			
			function prepareAllies(properties)
			{
				this.logInfo("barb banner: " + this.Contract.m.Home.getBanner());
				properties.AllyBanners = [
						this.World.Assets.getBanner(),
						this.Contract.m.Home.getBanner()
					];
				
				local allyStrength = this.Flags.get("allyStrength");

				
				//::NorthMod.Const.Spawn.BarbarianNoThralls
				//this.Const.World.Spawn.Barbarians
				this.Const.World.Common.addUnitsToCombat(properties.Entities, ::NorthMod.Const.Spawn.BarbarianNoThralls, allyStrength * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Contract.getFaction());
				properties.Entities.push({
					ID = this.Const.EntityType.BarbarianChampion,
					Variant = 0,
					Row = 2,
					Script = "scripts/entity/tactical/humans/barbarian_champion",
					Faction = this.Contract.getFaction(),
					Callback = this.Contract.onCommanderPlaced.bindenv(this.Contract)
				});
				if(this.Flags.get("IsBarbarianSwitch") && !this.Flags.get("IsDuelVictory"))
				{
					properties.Entities.push({
						ID = this.Const.EntityType.BarbarianChampion,
						Variant = 0,
						Row = 2,
						Script = "scripts/entity/tactical/humans/barbarian_champion",
						Faction = this.Contract.getFaction()
					});
				}
				
			}
			
			function prepareJoinedEnemies(properties)
			{
				local f1 = this.World.FactionManager.getFaction(this.Flags.get("enemy1"));
				local f2 = this.World.FactionManager.getFaction(this.Flags.get("enemy2"));
				properties.EnemyBanners = [
					f1.getBannerSmall(),
					f2.getBannerSmall()
				];
				
				this.addAlliance();
				
				this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Noble, this.Flags.get("enemy1Strength") * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("enemy1"));
				properties.Entities.push({
					ID = this.Const.EntityType.Knight,
					Variant = this.Const.DLC.Wildmen && this.Contract.getDifficultyMult() >= 1.15 ? 1 : 0,
					Name = this.Const.Strings.KnightNames[this.Math.rand(0, this.Const.Strings.KnightNames.len() - 1)],
					Row = 2,
					Script = "scripts/entity/tactical/humans/knight",
					Faction = this.Flags.get("enemy1")
				});
				
				this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Noble, this.Flags.get("enemy2Strength") * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("enemy2"));
				properties.Entities.push({
					ID = this.Const.EntityType.Knight,
					Variant = this.Const.DLC.Wildmen && this.Contract.getDifficultyMult() >= 1.15 ? 1 : 0,
					Name = this.Const.Strings.KnightNames[this.Math.rand(0, this.Const.Strings.KnightNames.len() - 1)],
					Row = 2,
					Script = "scripts/entity/tactical/humans/knight",
					Faction = this.Flags.get("enemy2")
				});
				
				
			}
			
			function prepareUnexpectedCharge(properties)
			{
				local f1 = this.World.FactionManager.getFaction(this.Flags.get("enemy1"));
				local f2 = this.World.FactionManager.getFaction(this.Flags.get("enemy2"));
				properties.EnemyBanners = [
					f1.getBannerSmall(),
					f2.getBannerSmall()
				];
				properties.EnemyDeploymentType = this.Const.Tactical.DeploymentType.LineBack;
				properties.PlayerDeploymentType = this.Const.Tactical.DeploymentType.LineBack;
				
				// prepare enemy 1 (always noble)
				this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Noble, this.Flags.get("enemy1Strength") * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("enemy1"));
				this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Mercenaries, 60 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("enemy1"));
				properties.Entities.push({
					ID = this.Const.EntityType.Knight,
					Variant = this.Const.DLC.Wildmen && this.Contract.getDifficultyMult() >= 1.15 ? 1 : 0,
					Name = this.Const.Strings.KnightNames[this.Math.rand(0, this.Const.Strings.KnightNames.len() - 1)],
					Row = 2,
					Script = "scripts/entity/tactical/humans/knight",
					Faction = this.Flags.get("enemy1")
				});
				
				// prepare enemy2 southern
				if(f2.getType() == this.Const.FactionType.OrientalCityState)
				{
					this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Southern, this.Flags.get("enemy2Strength") * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("enemy2"));
					if(this.Flags.get("IsBarbariansFailed"))
					{
						this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Barbarians, 80 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("enemy2"));
						properties.Entities.push({
							ID = this.Const.EntityType.BarbarianChampion,
							Variant = 0,
							Script = "scripts/entity/tactical/humans/barbarian_champion",
							Faction = this.Flags.get("enemy2"),
							Callback = null
						});
					}
					else
					{
						this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Mercenaries, 60 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("enemy2"));
					}
					
					
					properties.Entities.push({
						ID = this.Const.EntityType.Officer,
						Variant = this.Const.DLC.Wildmen && this.Contract.getDifficultyMult() >= 1.15 ? 1 : 0,
						Row = 2,
						Script = "scripts/entity/tactical/humans/officer",
						Faction = this.Flags.get("enemy2")
					});
				}
				// prepare enemy2 noble
				else
				{
					this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Noble, this.Flags.get("enemy2Strength") * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("enemy2"));
					this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Mercenaries, 60 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("enemy2"));
					properties.Entities.push({
						ID = this.Const.EntityType.Knight,
						Variant = this.Const.DLC.Wildmen && this.Contract.getDifficultyMult() >= 1.15 ? 1 : 0,
						Name = this.Const.Strings.KnightNames[this.Math.rand(0, this.Const.Strings.KnightNames.len() - 1)],
						Row = 2,
						Script = "scripts/entity/tactical/humans/knight",
						Faction = this.Flags.get("enemy2")
					});
				}
				
				
				
				
				
				
			}
			
			function prepareWinner(properties)
			{
				
				properties.EnemyBanners = [
					this.World.FactionManager.getFaction(this.Flags.get("winner")).getBannerSmall()
				];
					
				local winnerStrength = this.Flags.get("winnerStrength");
				this.logInfo("winner strength:" + winnerStrength);
				
				if(this.World.FactionManager.getFaction(this.Flags.get("winner")).getType() == this.Const.FactionType.OrientalCityState)
				{
					this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Southern, winnerStrength * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("winner"));
				}
				else
				{
					this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Noble, winnerStrength * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("winner"));
				}
				
				
				if(this.Flags.get("IsReinforcements") && this.Flags.get("IsBarbariansFailed") && this.Flags.get("winner") == this.Flags.get("enemy2"))
				{
					this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Barbarians, 80 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("winner"));
					properties.Entities.push({
						ID = this.Const.EntityType.BarbarianChampion,
						Variant = 0,
						Row = 2,
						Script = "scripts/entity/tactical/humans/barbarian_champion",
						Faction = this.Flags.get("winner"),
						Callback = null
					});
				}
				else if(this.Flags.get("IsReinforcements"))
				{
					this.Const.World.Common.addUnitsToCombat(properties.Entities, this.Const.World.Spawn.Mercenaries, 60 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Flags.get("winner"));
				}
				
				if(this.World.FactionManager.getFaction(this.Flags.get("winner")).getType() == this.Const.FactionType.OrientalCityState)
				{
					properties.Entities.push({
						ID = this.Const.EntityType.Officer,
						Variant = this.Const.DLC.Wildmen && this.Contract.getDifficultyMult() >= 1.15 ? 1 : 0,
						Row = 2,
						Script = "scripts/entity/tactical/humans/Officer",
						Faction = this.Flags.get("winner"),
						Callback = null
					});
				}
				else
				{
					properties.Entities.push({
						ID = this.Const.EntityType.Knight,
						Variant = this.Const.DLC.Wildmen && this.Contract.getDifficultyMult() >= 1.15 ? 1 : 0,
						Name = this.Const.Strings.KnightNames[this.Math.rand(0, this.Const.Strings.KnightNames.len() - 1)],
						Row = 2,
						Script = "scripts/entity/tactical/humans/knight",
						Faction = this.Flags.get("winner"),
						Callback = null
					});
				}
				
				
					
			}
			
			function addAlliance()
			{
				local f1 = this.World.FactionManager.getFaction(this.Flags.get("enemy1"));
				local f2 = this.World.FactionManager.getFaction(this.Flags.get("enemy2"));
				f1.addAlly(this.Flags.get("enemy2"));
				f2.addAlly(this.Flags.get("enemy1"));
			}
			
			function removeAlliance()
			{
				local f1 = this.World.FactionManager.getFaction(this.Flags.get("enemy1"));
				local f2 = this.World.FactionManager.getFaction(this.Flags.get("enemy2"));
				f1.removeAlly(this.Flags.get("enemy2"));
				f2.removeAlly(this.Flags.get("enemy1"));
			}

			function onRetreatedFromCombat( _combatID )
			{
				if (_combatID == "FinalBattle")
				{
					this.Flags.set("IsFinalBattleLost", true);
				}
				this.removeAlliance();
			}

			function onCombatVictory( _combatID )
			{
				if (_combatID == "FinalBattle")
				{
					this.Flags.set("IsFinalBattleWon", true);
				}
				this.removeAlliance();
			}

		});
		this.m.States.push({
			ID = "Return",
			function start()
			{
				this.Contract.m.BulletpointsObjectives = [
					"Return to " + this.Contract.m.Home.getName() + " to claim your payment"
				];
				this.Contract.m.Home.getSprite("selection").Visible = true;
			}

			function update()
			{
				if (this.Contract.isPlayerAt(this.Contract.m.Home))
				{
					this.Contract.setScreen("Success1");
					this.World.Contracts.showActiveContract();
				}
			}

		});
	}

	function createScreens()
	{
		this.importScreens(this.Const.Contracts.NegotiationDefault);
		this.importScreens(this.Const.Contracts.Overview);
		this.m.Screens.push({
			ID = "Task",
			Title = "Negotiations",
			Text = "[img]gfx/ui/events/event_45.png[/img]{You find %employer% in his room, surrounded by clan warriors. They are looking at a worn and tattered map spread out on a wooden table. One of the warriors, a particularly large man, turns to you.%SPEECH_ON%I\'m %commander%, but you need not introduce yourself, warrior. I\'ve heard about you. Me and %employer% have a proposition for you. %enemy1% and %enemy2% are at war and they will have a great battle between them. After they kill each other we will come and sweep the battered survivors. Then we go and pillage their lands. If you are willing to join the battle, there will be gold to share.%SPEECH_OFF% | %employer% welcomes you inside. He shows you a particularly weathered map and points to a specific location.%SPEECH_ON%Here, a great battle between %enemy2% and %enemy1% will unfold. I\'ve dispatched %commander% to strike once they are done killing each other. They\'ll be weak and weary, ensuring a swift victory for us. Their lands will then be ripe for plundering. Should you choose, you and your crew can join this historic triumph, one that will echo through the ages.%SPEECH_OFF% | You meet %employer% in the chieftain\'s hall. He gestures towards an old, weathered map hanging on a wall.%SPEECH_ON%Right here, on this spot, %enemy2% and %enemy1% will clash. I\'ve already sent %commander% to assemble all the men he can get and attack them when they are done with each other. Afterwards, their lands can be raided freely. It would be good if you were to join. It would ensure victory and you would get your share of the spoils.%SPEECH_OFF%}",
			Image = "",
			List = [],
			ShowEmployer = true,
			ShowDifficulty = true,
			Options = [
				{
					Text = "A great battle, you say?",
					function getResult()
					{
						return "Negotiation";
					}

				},
				{
					Text = "{I have to decline. | We\'re needed elsewhere.}",
					function getResult()
					{
						this.World.Contracts.removeContract(this.Contract);
						return 0;
					}

				}
			],
			function start()
			{
			}

		});
		this.m.Screens.push({
			ID = "WarcampDay1",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{You arrive at the barbarian camp, which is nothing more than a chaotic sprawl of bedrolls and makeshift shelters scattered among the trees. %commander% welcomes you into his tent, which is more akin to a wolf den, a tangle of weapons and armor.%SPEECH_ON%Welcome, warrior, you\'ve arrived just in time.%SPEECH_OFF% | %commander%\'s war camp is filled with bored men. They\'re stirring stews or playing dice games. The most exciting thing available is a battle between a beetle and a worm, a fight neither side seems particularly interested in. %commander% himself welcomes you and takes you inside his tent, han a cluttered den of furs and trophies from past battles. | You come into %commander%\'s camp to find the men partaking in a beetle race. They cheer on the beetles which, halfway down a track made of haystraw, turn on one another and start fighting. The warriors\' cheers get ever louder. %commander% finds you through the crowds and takes you to his tent.%SPEECH_ON%I am glad you are here, sellsword. I have something for you to do right now.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "What do you need the %companyname% to do?",
					function getResult()
					{
						if (this.Flags.get("IsScoutsSighted"))
						{
							return "ScoutsSighted";
						}
						else
						{
							return "RaidSupplies1";
						}
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WarcampDay1End",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{You return to the war camp and order your men to get some rest. Who knows what awaits you tomorrow. | The war camp is just as you left it. You\'re not sure if that\'s good or bad. Tomorrow will bring more shite to take care of so you order the %companyname% to get some rest.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Rest well, we\'ll soon be called upon again.",
					function getResult()
					{
						this.Flags.set("LastDay", this.World.getTime().Days);
						this.Flags.set("NextDay", 2);
						this.Contract.setState("Running_WaitForNextDay");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ScoutsSighted",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_54.png[/img]%commander% explains the situation.%SPEECH_ON%{%enemy1%\'s scouts have been spotted %direction% from here. I need you to go and kill them all before they find us or report whatever they\'ve learned in the past days. | In war, knowing things is always good. Better yet, to know things your enemies don't. I happen to know that %enemy1%'s scouts are on the prowl just north of here. It would be good if they did not know about us. | A few of my pathfinders have located some of %enemy1%\'s scouts just %direction% of here. They\'re rummaging around looking for whatever, but they won\'t find anything because you\'ll be going out there to kill them all. Right?}%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We will head out immediately.",
					function getResult()
					{
						this.Contract.setState("Running_Scouts");
						return 0;
					}

				}
			],
			function start()
			{
				local playerTile = this.Contract.m.Warcamp.getTile();
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 5, 8);
				local party = this.World.FactionManager.getFaction(this.Flags.get("enemy1")).spawnEntity(tile, "Scouts", false, this.Const.World.Spawn.Noble, 60 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				party.getSprite("banner").setBrush(this.World.FactionManager.getFaction(this.Flags.get("enemy1")).getBannerSmall());
				party.setDescription("Professional soldiers in service to local lords.");
				party.setFootprintType(this.Const.World.FootprintsType.Nobles);
				this.Contract.m.UnitsSpawned.push(party);
				party.getLoot().Money = this.Math.rand(50, 100);
				party.getLoot().ArmorParts = this.Math.rand(0, 10);
				party.getLoot().Medicine = this.Math.rand(0, 2);
				party.getLoot().Ammo = this.Math.rand(0, 20);
				local r = this.Math.rand(1, 6);

				if (r == 1)
				{
					party.addToInventory("supplies/bread_item");
				}
				else if (r == 2)
				{
					party.addToInventory("supplies/roots_and_berries_item");
				}
				else if (r == 3)
				{
					party.addToInventory("supplies/dried_fruits_item");
				}
				else if (r == 4)
				{
					party.addToInventory("supplies/ground_grains_item");
				}
				else if (r == 5)
				{
					party.addToInventory("supplies/pickled_mushrooms_item");
				}

				this.Contract.m.Destination = this.WeakTableRef(party);
				party.setAttackableByAI(false);
				party.setFootprintSizeOverride(0.75);
				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local roam = this.new("scripts/ai/world/orders/roam_order");
				roam.setPivot(this.Contract.m.Warcamp);
				roam.setMinRange(4);
				roam.setMaxRange(9);
				roam.setAllTerrainAvailable();
				roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
				roam.setTerrain(this.Const.World.TerrainType.Shore, false);
				roam.setTerrain(this.Const.World.TerrainType.Mountains, false);
				c.addOrder(roam);
			}

		});
		this.m.Screens.push({
			ID = "ScoutsEscaped",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_22.png[/img]{Unfortunately, one or more of the scouts managed to slip out of the battle. Whatever information they had collected is now in the hands of %enemy1%. | Damn it all! Some of the scouts managed to escape and no doubt make their way back to %enemy1%.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Damnit!",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterScouts");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "ScoutsCaught",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_22.png[/img]{All of the scouts have been slain. Whatever information they had died with them. This will be a great boon for the upcoming battle. | The scouts are dead and whatever they had learned is dead with them.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Victory!",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterScouts");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "RaidSupplies1",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{%commander% sighs and begins to talk.%SPEECH_ON%You see all these men in the camp and know how many brought food with them?%SPEECH_OFF%You shake your head. But the man doesn\'t care for your answer.%SPEECH_ON%Not enough! And these southerners are taking their time to fight each other. So we are running low on food and we need to organize a quick raid for supplies and I know just the place.%SPEECH_OFF% | %commander% starts explaining the situation.%SPEECH_ON%Every man here knows how to hunt and survive in wilderness for weeks, but put a great number of men like that together and they\'ll clean the region of all food. That is where we are now. So I need someone to visit the farmers nearby and take their food. Can you do it?%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "The company will move out within the hour.",
					function getResult()
					{
						this.Contract.setState("Running_Raid");
						return 0;
					}

				}
			],
			function start()
			{
				local settlements = this.World.EntityManager.getSettlements();
				local lowest_distance = 99999;
				local best_location;
				local myTile = this.Contract.m.Warcamp.getTile();

				foreach( s in settlements )
				{
					foreach( l in s.getAttachedLocations() )
					{
						if (l.getTypeID() == "attached_location.wheat_fields" || l.getTypeID() == "attached_location.pig_farm")
						{
							local d = myTile.getDistanceTo(l.getTile());

							if (d < lowest_distance)
							{
								lowest_distance = d;
								best_location = l;
							}
						}
					}
				}

				best_location.setActive(true);
				this.Contract.m.Destination = this.WeakTableRef(best_location);
			}

		});
		this.m.Screens.push({
			ID = "RaidSupplies2",
			Title = "At the farm...",
			Text = "[img]gfx/ui/events/event_72.png[/img]{The farmhouses draw near. A sea of crops stretches before you, the fields gliding wavelike as the winds soar through. %randombrother% runs his hand through a field of wheat. %randombrother2% slugs him in the shoulder.%SPEECH_ON%You wanna bring sawflies home with us? Get yer hand out of there.%SPEECH_OFF%The warrior rubs his shoulder before slugging back.%SPEECH_ON%Fark you. My hand goes where it please, just ask yer mother.%SPEECH_OFF%The punches rapidly increase in volume and the idyllic scene breaks. | The farmhouses are in the distance. Fields of crops seesaw to a crisp wind, rustling like calm ocean waves. Farmhands chop through the fields with scythes, a crew of followers heaving the remains with pitchforks. Donkeys bring up the rear, drawing carts through the roughshod terrain.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Let\'s get what we\'re here for.",
					function getResult()
					{
						if (this.Flags.get("IsAmbush"))
						{
							return "Ambush";
						}
						else if (this.Flags.get("IsUnrulyFarmers"))
						{
							return "UnrulyFarmers";
						}
						else
						{
							return "CooperativeFarmers";
						}
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Ambush",
			Title = "At the farm...",
			Text = "[img]gfx/ui/events/event_10.png[/img]{As you near the farmers, a shout comes from your sides and out jumps a group of well-armed men. This is an ambush! | Closing in on the farmhouses, the food-filled carts begin to trundle backwards. As they shuffle away, they slowly reveal a troop of well-armed men. The farmers quickly clear out. %randombrother% draws his weapon.%SPEECH_ON%This is an ambush!%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "Ambush";
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Center;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Circle;
						local n = 0;

						do
						{
							n = this.Math.rand(1, this.Const.PlayerBanners.len());
						}
						while (n == this.World.Assets.getBannerID());

						p.Entities = [];
						p.EnemyBanners = [
							this.Const.PlayerBanners[n - 1],
							"banner_noble_11"
						];
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Mercenaries, 100 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Const.Faction.Enemy);
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.PeasantsArmed, 40 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Const.Faction.Enemy);
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "UnrulyFarmers",
			Title = "At the farm...",
			Text = "[img]gfx/ui/events/event_43.png[/img]You get up to the farmers only find them armed with pitchforks and scythes. Tools, not weapons, but they seem ready for a fight. Their leader steps forward and starts speaking.%SPEECH_ON%{We don\'t want a fight with you, but we will defend our homes. However, if you want food we can give it to you. For a fair price, ofcourse. | Barbarians at our doorstep, did not hope to see your kind here. I know, you come to plunder, but I\'d rather we trade than fight. Give us some of your gold and we\'ll share our food and supplies. And we\'ll say nothing of you being here to our lords.}%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We'll pay with blood. Your blood.",
					function getResult()
					{
						return "TakeItByForce";
					}

				},
				{
					Text = "I understand. You shall have your %cost% crowns and we the supplies.",
					function getResult()
					{
						return "PayCompensation";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BeatenByFarmers",
			Title = "At the farm...",
			Text = "[img]gfx/ui/events/event_22.png[/img]The ambush is too strong! You take what men are still standing and beat a retreat. %commander%\'s men will have to ration even more now and news of the %companyname%\'s defeat here will no doubt spread.",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Damn this!",
					function getResult()
					{
						this.Flags.set("IsRaidFailure", true);
						this.Contract.setState("Running_ReturnAfterRaid");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "PoorFarmers",
			Title = "At the farm...",
			Text = "[img]gfx/ui/events/event_60.png[/img]{The farmers and their hired swords are put down. One of the farmhands, kicking backward with his guts hanging out, begs for mercy as you close in for the kill. You shake your head.%SPEECH_ON%You\'re all turned out, kid. This right here is mercy.%SPEECH_OFF%The blade slides easily through his throat. He gargles, but it\'s over very quickly. You order the men to collect the foodstuffs and prepare to return to %commander%. | The farmers and their hired ambush have been slain to a man. You order the men to gather the foodstuffs. %commander% and his men should be happy to see your return. | There\'s blood on some of the food, but a little water will rub that right out. %commander%\'s men will appreciate your work here. | %randombrother% picks up a farmer that was playing dead and slashes him across the throat. The man gargles and wriggles free of the warrior\'s grip. He jaunts over to one of the wagons, spewing blood all over the food. You call out.%SPEECH_ON%Goddammit, get him off there!%SPEECH_OFF%The farmer is quickly disposed of, but that shipment is no doubt ruined. You shake your head.%SPEECH_ON%Put a blanket on those ones. Maybe no one will notice.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "You live by the pitchfork, you die by the sword.",
					function getResult()
					{
						this.Flags.set("RaidSuccess", true);
						this.Contract.setState("Running_ReturnAfterRaid");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "CooperativeFarmers",
			Title = "At the farm...",
			Text = "[img]gfx/ui/events/event_55.png[/img]{You get up to the farmhouse, but all the doors are closed, windows shut. In the center of the village there are a few carts and a man.%SPEECH_ON%We want no trouble with your kind. Take what you want and leave. If you leave in peace, no one needs to know you were ever here.%SPEECH_OFF% | When they notice you, all the farmers scatter and hide. Only one man, presumably their leader comes out to meet you.%SPEECH_ON%Greetings, warriors from the %direction%. Your kind, often comes with blade and fire to loot and pillage. But if spoils of war is what you are after, how about we skip the warring part. Let us live and we\'ll give you what you want.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "If all raids were this easy.",
					function getResult()
					{
						this.Flags.set("RaidSuccess", true);
						this.Contract.setState("Running_ReturnAfterRaid");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "TakeItByForce",
			Title = "At the farm...",
			Text = "[img]gfx/ui/events/event_43.png[/img]{You draw out your sword. The farmers step back and a clatter of pitchforks being grabbed rattles through their lines. Their leader spits and runs a sleeve across his mouth.%SPEECH_ON%Hell, you wanna take it there? Then we\'ll go there.%SPEECH_OFF% | You shake your head.%SPEECH_ON%No deal. Give up the foodstuffs or face our wrath.%SPEECH_OFF%The farmer swings a pitchfork from side to side. His men slowly begin picking up arms. He nods.%SPEECH_ON%We\'re farmers, asshole. Wrath chose us a long, long time ago.%SPEECH_OFF% | You did not come here to broker deals.%SPEECH_ON%There will be no compensation. We are here..%SPEECH_OFF%The farmer laughs and interrupts.%SPEECH_ON%You are nothing but dog. Well I\'ll tell you what little doggie, let\'s see if your men are more bark than bite.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Let\'s make this quick.",
					function getResult()
					{
						local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						p.CombatID = "TakeItByForce";
						p.Music = this.Const.Music.CivilianTracks;
						p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						p.Entities = [];
						p.EnemyBanners = [
							"banner_noble_11"
						];
						this.Const.World.Common.addUnitsToCombat(p.Entities, this.Const.World.Spawn.Peasants, 80 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult(), this.Const.Faction.Enemy);
						this.World.Contracts.startScriptedCombat(p, false, true, true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "PayCompensation",
			Title = "At the farm...",
			Text = "[img]gfx/ui/events/event_55.png[/img]{You see no reason to shed the blood of some poor farmers just trying to live their lives. Handing over the crowns, you warn the farmer to be careful trying to cut deals like this.%SPEECH_ON%Not everyone is so kind as to try and broker with you.%SPEECH_OFF%The farmer turns his head, revealing a long scar the runs from scalp to shoulder.%SPEECH_ON%I know well enough. Thank you for your consideration, barbarian.%SPEECH_OFF% | Slaughtering farmers who can barely put up a fight is not something you find enjoyable. You agree to the man\'s terms. He thanks you for not coming out all this way to slaughter some poor farmers. %randombrother%, however, quietly states that he did not come all this way to... You loudly tell him to shut his mouth and start loading the carts.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Let\'s hurry up and get back to the war camp.",
					function getResult()
					{
						this.Flags.set("RaidSuccess", true);
						this.Contract.setState("Running_ReturnAfterRaid");
						return 0;
					}

				}
			],
			function start()
			{
				this.World.Assets.addMoney(-this.Flags.get("RaidCost"));
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You spend [color=" + this.Const.UI.Color.NegativeEventValue + "]" + this.Flags.get("RaidCost") + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "WarcampDay2",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{The morning sun leaks into your tent, running a beam right across your eyes to really rub it in that you\'ve a new day to put up with. | You get up and put your boots on, slapping out some spiders that thought it the place to rest overnight. | Outside your tent, a rooster loudly lets everyone know what a real asshole of an animal it is. You begrudgingly get up. | You wake to yet another day. Great. | You slept like a dead man and wake like one, too. The sunlight slipping into the tent is too blinding to go back to bed and the flaps are too far to shut. To hell with it, you\'ll get up. | Morning. That inevitable hour where a thousand regrets arrive on the glowy limelight of a new day.}\n\nA young man stands outside your and upon seeing you come out, he calls out%SPEECH_ON%%commander% sent me to fetch you. He wants to see you.%SPEECH_OFF%",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Time to pay a visit to the commander...",
					function getResult()
					{
						if (this.Flags.get("IsInterceptSupplies"))
						{
							return "InterceptSupplies";
						}
						else
						{
							return "Barbarians1";
						}
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "InterceptSupplies",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{%commander% sighs and begins to talk.%SPEECH_ON%You see all these men in the camp and know how many brought food with them?%SPEECH_OFF%You shake your head. But the man doesn\'t care for your answer.%SPEECH_ON%Not enough! And these southerners are taking their time to fight each other. So we are running low on food and we need to organize a quick raid for supplies and I know about a %enemy1% caravan that we can hit.%SPEECH_OFF% | %commander% begins to explain the situation.%SPEECH_ON%Every man here knows how to hunt and survive in the wilderness for weeks. But when you gather a large group like this, they\'ll strip the region of all its food. That\'s where we find ourselves now. Luckily, there\'s a caravan from %enemy1% that we can raid. Could you take care of it?%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "The company will head out immediately.",
					function getResult()
					{
						this.Contract.setState("Running_InterceptSupplies");
						return 0;
					}

				}
			],
			function start()
			{
				local startTile = this.World.getEntityByID(this.Flags.get("InterceptSuppliesStart")).getTile();
				local destTile = this.World.getEntityByID(this.Flags.get("InterceptSuppliesDest")).getTile();
				local enemyFaction = this.World.FactionManager.getFaction(this.Flags.get("enemy1"));
				local party = enemyFaction.spawnEntity(startTile, "Supply Caravan", false, this.Const.World.Spawn.NobleCaravan, 110 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				party.getSprite("base").Visible = false;
				party.getSprite("banner").setBrush(this.World.FactionManager.getFaction(this.Flags.get("enemy1")).getBannerSmall());
				party.setMirrored(true);
				party.setVisibleInFogOfWar(true);
				party.setImportant(true);
				party.setDiscovered(true);
				party.setDescription("A caravan with armed escorts transporting provisions, supplies and equipment between settlements.");
				party.setFootprintType(this.Const.World.FootprintsType.Caravan);
				party.getFlags().set("IsCaravan", true);
				party.setAttackableByAI(false);
				party.getFlags().add("ContractSupplies");
				this.Contract.m.Destination = this.WeakTableRef(party);
				this.Contract.m.UnitsSpawned.push(party);
				party.getLoot().Money = this.Math.rand(50, 100);
				party.getLoot().ArmorParts = this.Math.rand(0, 10);
				party.getLoot().Medicine = this.Math.rand(0, 2);
				party.getLoot().Ammo = this.Math.rand(0, 20);
				local r = this.Math.rand(1, 6);

				if (r == 1)
				{
					party.addToInventory("supplies/bread_item");
				}
				else if (r == 2)
				{
					party.addToInventory("supplies/roots_and_berries_item");
				}
				else if (r == 3)
				{
					party.addToInventory("supplies/dried_fruits_item");
				}
				else if (r == 4)
				{
					party.addToInventory("supplies/ground_grains_item");
				}
				else if (r == 5)
				{
					party.addToInventory("supplies/pickled_mushrooms_item");
				}

				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local move = this.new("scripts/ai/world/orders/move_order");
				move.setDestination(destTile);
				move.setRoadsOnly(true);
				local despawn = this.new("scripts/ai/world/orders/despawn_order");
				c.addOrder(move);
				c.addOrder(despawn);
			}

		});
		this.m.Screens.push({
			ID = "SuppliesReachedEnemy",
			Title = "Along the way...",
			Text = "[img]gfx/ui/events/event_55.png[/img]{You failed to destroy the caravan. Obviously, all its goods have reached %enemy1%\'s army and to make matters worse %commander%\'s men are low on supplies. That will make the fighting much harder in the coming days. | The caravan was not raided. You can be most assured that %enemy1%\'s army will be near full-strength for the big battle ahead and %commander%\'s men will be fewer and starved. | Well, shite. The caravan was not raided. Now, %enemy1%\'s army is going to be very well prepared for the battle ahead and our forces will be weaker.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We should head back to the camp...",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "SuppliesIntercepted",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_60.png[/img]{The once orderly caravan from %enemy1% is now a mess of overturned wagons and scattered supplies. Your warriors load sacks of grain, crates of weapons, and barrels of provisions onto makeshift sleds. %randombrother% grins and says.%SPEECH_ON%This will keep us strong for the big fight.%SPEECH_OFF%You nod in agreement.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "One less problem to deal with in the coming battle.",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Barbarians1",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{%commander%\'s expression is grim and sullen and his mood is no better. %SPEECH_ON%Fucking northerners! You can\'t even rely on us to all fight on the same side.%SPEECH_OFF%You ask him what happened.%SPEECH_ON%Apparently, there\'s a clan coming to participate in the battle. They\'ll fight under %enemy2% banner. Now, I don\'t know if they know about our plans, but I need them out. Last thing we need is to fight other %direction%erners, so find them and persuade them to switch sides or make them go away. They should be somewhere %direction% of here.%SPEECH_OFF% | You enter %commander%\'s tent just in time to watch a candle go flying by your face. Its wick sizzles into the mud as you watch a table follow after it, flipping over and over with all its trophies going flying. A red-faced %commander% stands at the foot of the carnage, his hands on his hips, breathing heavy as he recollects himself. He explains himself.%SPEECH_ON%Turns out, another clan is joining the battle under %enemy2%\'s banner. They might be aware of our plans, but I need them gone. The last thing we need is fight our kind. Go find them and either convince them to join us or chase them off.%SPEECH_OFF% | Just as you are about to enter %commander%\'s tent, a man comes flying out. %commander% rushes forth from the tent and slams him into the mud. He grabs him by the collars and picks him up like a ragdoll.%SPEECH_ON%Who are they? Where are they coming from? I swear by the old gods I will have you begging for death if you do not answer me honestly!%SPEECH_OFF%The man cries out and points.%SPEECH_ON%I think %direction%! That\'s where they are.%SPEECH_OFF%%commander% drops the man who is quickly dragged away by a pair of guards. The commander stands up straight and runs a hand through his hair.%SPEECH_ON%Warrior, some northerners are coming to battle, but they will join %enemy2%. We can not allow them. Convince them to switch sides or to leave altogether.%SPEECH_OFF%You nod, but ask what if the men refuse. %SPEECH_ON%Slaughter them, of course.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "The company will head out within the hour.",
					function getResult()
					{
						this.Contract.setState("Running_Barbarians");
						return 0;
					}

				}
			],
			function start()
			{
				local playerTile = this.World.State.getPlayer().getTile();
				local tile = this.Contract.getTileToSpawnLocation(playerTile, 5, 8);
				local party = this.World.FactionManager.getFaction(this.Flags.get("enemy2")).spawnEntity(tile, "Barbarians", false, this.Const.World.Spawn.Barbarians, 80 * this.Contract.getDifficultyMult() * this.Contract.getScaledDifficultyMult());
				this.Const.World.Common.addTroop(party, {
					Type = this.Const.World.Spawn.Troops.BarbarianChampion
				}, false);
				party.getSprite("banner").setBrush("banner_wildmen_03");
				party.setFootprintType(this.Const.World.FootprintsType.Barbarians);
				party.setAttackableByAI(false);
				party.getController().getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
				party.setFootprintSizeOverride(0.75);

				this.Contract.m.Destination = this.WeakTableRef(party);
				party.getLoot().Money = this.Math.rand(50, 100);
				party.getLoot().ArmorParts = this.Math.rand(0, 10);
				party.getLoot().Medicine = this.Math.rand(0, 2);
				party.getLoot().Ammo = this.Math.rand(0, 20);
				party.addToInventory("supplies/roots_and_berries_item");

				local c = party.getController();
				c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
				local roam = this.new("scripts/ai/world/orders/roam_order");
				roam.setPivot(this.Contract.m.Warcamp);
				roam.setMinRange(2);
				roam.setMaxRange(8);
				roam.setAllTerrainAvailable();
				roam.setTerrain(this.Const.World.TerrainType.Ocean, false);
				roam.setTerrain(this.Const.World.TerrainType.Shore, false);
				c.addOrder(roam);
				
				
		
			}

		});
		this.m.Screens.push({
			ID = "Barbarians2Bribe",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_139.png[/img]{You arrive at the northerners\' encampment, where their leader, a burly man with a braided beard, listens intently as you speak.%SPEECH_ON%You come to fight for %enemy2%, but I have no intention of letting you do that.  You can go back to your homes or you can die here.%SPEECH_OFF%He strokes his beard thoughtfully. %SPEECH_ON%We’ve come a long way to go home empty handed. We are not afraid of fighting, but rather we\'d be on the same side as our kind. We\'ll fight for you on the battlefield, or we\'ll fight against you here. It depends on the gold.%SPEECH_OFF%He outstretches his hands as if to say the decision is yours. | You find the northerners resting in a forest clearing. Their leader, a grizzled warrior with a scar running down his face, comes out to meet you. After brief introductions you lay out your proposal. You can not allow them to fight for %enemy2%.  After considering you words, their leader grunts.%SPEECH_ON%We fight, but give us gold and we\'ll fight for you or we will fight you now. Choose.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Then we fight here!",
					function getResult()
					{
						this.Contract.barbarianCombat();
					}

				},
				{
					Text = "Here\'s %bribe% crowns if you switch sides.",
					function getResult()
					{
						return "BarbariansAcceptBribe";
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Barbarians2Honor",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_139.png[/img]{You arrive at the northerners\' encampment, where their leader, a burly man with a braided beard, listens intently as you speak.%SPEECH_ON%You come to fight for %enemy2%, but I have no intention of letting you do that.  You can go back to your homes or you can die here.%SPEECH_OFF%He strokes his beard thoughtfully. %SPEECH_ON%We’ve already committed to %enemy2%. To switch sides now would be dishonorable.%SPEECH_OFF% | You find the northerners resting in a forest clearing. Their leader, a grizzled warrior with a scar running down his face, comes out to meet you. After brief introductions you lay out your proposal. You can not allow them to fight for %enemy2%.  After considering you words, their leader grunts.%SPEECH_ON%I gave my word to %enemy2%, to go on that would be... dishonorable. You do what you must do, but we are not going back.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Then we fight here!",
					function getResult()
					{
						this.Contract.barbarianCombat();
					}

				},
				{
					Text = "Challenge their leader to a duel.",
					function getResult()
					{
						return "BarbariansDuel"
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BarbariansAcceptBribe",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_139.png[/img]{The barbarian leader whatches you intently as you take out a bag and start putting gold in it. Once there is about %bribe% worth of gold in it, he nods.%SPEECH_ON%This will do. I would rather fight with you anyway than with those southerners.%SPEECH_OFF% | You produce a heavy pouch of gold.%SPEECH_ON%There is %bribe% crowns in there. I\'m sure you\'ll find ways to acquire more after the battle.%SPEECH_OFF%Their leader looks at you, as if sizing you up. For a moment tension builds up, men on all sides gripping weapons tightly, ready to draw them. Then, as the leader nods and takes the pouch, the tension releases, and everyone starts breathing normally again.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "This should help us in the coming battle.",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						this.Contract.setState("Running_ReturnAfterIntercept");
						this.Flags.set("IsBarbarianSwitch", true);
						return 0;
					}

				}
			],
			function start()
			{
				this.World.Assets.addMoney(-this.Flags.get("Bribe"));
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You spend [color=" + this.Const.UI.Color.NegativeEventValue + "]" + this.Flags.get("Bribe") + "[/color] Crowns"
				});
			}

		});
		this.m.Screens.push({
			ID = "BarbariansDuel",
			Title = "As you approach...",
			Text = "[img]gfx/ui/events/event_139.png[/img]{You can see that the leader of the clansmen is not happy about your challenge, but you can also see that he has no choice.%SPEECH_ON%I\'ve spoken of honor and you use it against me. Yet, it  compels me to accept your challenge. Very well name your champion.%SPEECH_OFF% | You size up the leader of the clansmen. He looks a strong and capable warrior, as he should be to lead a warband, still better to fight one man than all of them.%SPEECH_ON%If it is honor that binds you to %enemy2%, then let\'s settle this the honorable way. The old way.%SPEECH_OFF%The leader\'s face darkens with irritation, and he glances at his men before nodding reluctantly. %SPEECH_ON%I have no desire for this fight, but you are right. Honor leaves me no choice but to accept your challenge. Name your champion.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [	],
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

				::NorthMod.Utils.duelRosterSort(roster);
				
				
				local e = this.Math.min(4, roster.len());
				
				for( local i = 0; i < e; i = ++i )
				{
					local bro = roster[i];
					local text = "";
					if (bro.getFlags().get("IsPlayerCharacter") || bro.getFlags().get("IsPlayerCharacterAvatar"))
					{
						text = "I, "
					}
					this.Options.push({
						Text = text + roster[i].getName() + " will fight you!",
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
								Variant = 0,
								Row = 0,
								Script = "scripts/entity/tactical/humans/barbarian_champion",
								Faction = this.Contract.m.Destination.getFaction()

							});
							properties.EnemyBanners.push(this.Contract.m.Destination.getBanner());
							properties.Players.push(bro);
							properties.IsUsingSetPlayers = true;
							properties.TemporaryEnemies = [
								this.Contract.m.Destination.getFaction()
							];
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
		this.m.Screens.push({
			ID = "BarbariansDuelWin",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Go home!",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}

				},
				{
					Text = "Join our side in the battle.",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						this.Contract.setState("Running_ReturnAfterIntercept");
						this.Flags.set("IsBarbarianSwitch", true);
						return 0;
					}

				}
			],
			function start()
			{
				local bro = this.Tactical.getEntityByID(this.Flags.get("ChampionBrother"));
				if(bro.getFlags().get("IsPlayerCharacter"))
				{
					this.Text = "[img]gfx/ui/events/event_138.png[/img]{Barbarian leader is slain, his beaten body lying before your feet. You turn your face towards his men. One of them}"
				}
				else {
					this.Text = "[img]gfx/ui/events/event_138.png[/img]{%champbrother% sheathes his weapons and stands over the corpse of the slain barbarian leader. Nodding, the victorious warrior stares back at you.%SPEECH_ON%Finished, chief.%SPEECH_OFF%One of his men}"
				}
				this.Text += "asks what happens now?%SPEECH_ON%We came this far to fight, but you\'ve bested the best of us. So we will do as you say.%SPEECH_OFF%"
				
			}
		});
		
		this.m.Screens.push({
			ID = "BarbariansDuelLost",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_145.png[/img]{It was a good fight, a clash between men upon the earth with those in observation silent as though in awe of some timeless and honorable rite. But, %champbrother% lies dead on the ground. Bested and killed. The leader of barbarians steps forward. He does not carry any hint of gloating or grin.%SPEECH_ON%The battle between two men is as such as it were between all of us combined. We have won and we demand that you leave us be until the great battle.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We'll honor the old ways, you can go wherever you want.",
					function getResult()
					{
						this.Contract.m.Destination.die();
						this.Contract.m.Destination = null;
						this.Flags.set("IsBarbariansFailed", true);
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}
				},
				{
					Text = "Everyone, charge!",
					function getResult()
					{
						this.World.Assets.addMoralReputation(-10);
						local barbarians = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians);
						local relation = barbarians.getPlayerRelation();
						if (relation > 30)
						{
							local change = relation - 30;
							this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).addPlayerRelation(-change, "Broke the rules of an honorable duel");
						}
						
						this.Contract.barbarianCombat();
						
					}

				},
			]
		});
		
		
		this.m.Screens.push({
			ID = "BarbariansAftermath",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_22.png[/img]{%randombrother% cleans his blade on the tabard of one of the corpses.%SPEECH_ON%Shame they went out that way. They could have lived. They had a choice.%SPEECH_OFF%You shrug and respond.%SPEECH_ON%Choices don\'t mean much, if they all suck.%SPEECH_OFF% | The barbarians are dead all around you. One is crawling along the ground, trying to put distance between himself and your men. You crouch beside him, dagger in hand to finish the job. He laughs at you.%SPEECH_ON%No need to dirty the dirk, just give me time. That\'s all I g-got, augh.%SPEECH_OFF%A spurt of blood runs down his chin. His eyes narrow, staring straight, and he slowly sinks to the ground. You stand and tell the company to get ready to leave. | The last of the barbarians is found leaning against a rock, his hands limp at his sides. There\'s blood running down his chest and legs and pooling about the ground. He stares at it.%SPEECH_ON%I\'m alright, thanks for asking.%SPEECH_OFF%You tell him you didn\'t say anything. He looks at you, genuinely confused.%SPEECH_ON%You didn\'t? Well then.%SPEECH_OFF%A moment later and he falls to a side, face frozen in that deadened way.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Unfortunate, but it had to be done.",
					function getResult()
					{
						this.Contract.setState("Running_ReturnAfterIntercept");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "WarcampDay2End",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_138.png[/img]{%commander% informs you that tomorrow is the big day. You return to your tent for a good and earned rest. | You return to %commander% and inform him of the news. He is very subdued, his thoughts consumed with what is coming tomorrow: a large and decisive battle. The day over, you decide to turn in and wait for morning. | You report to %commander%, but he hardly even responds. He\'s practically living in his plans.%SPEECH_ON%I\'ll see you tomorrow. Get a good night\'s rest because you\'ll be needing it.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Rest well this night, for tomorrow battle awaits!",
					function getResult()
					{
						this.Flags.set("LastDay", this.World.getTime().Days);
						this.Flags.set("NextDay", 3);
						this.Contract.setState("Running_WaitForNextDay");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "UnexpectedCharge",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_135.png[/img]{You watch armies of %enemy1% and %enemy2% approach each other in perfect order. Footmen in front, pikemen behind them and arbalesters in the rear. Just before they make contact, a roaring scream, just nearby, startles you.%SPEECH_ON%Charge!%SPEECH_OFF%%commander% is standing in front of the clan warriors, screaming at the top of his lungs, as if hoping his voice alone could kill southerners. %randombrother% turns towards you with a look asking how is this a part of the plan. You shrug, meaning it isn\'t. Then %commander% screams more.%SPEECH_ON%Charge! Charge you fuckers! Kill them all! Make their pig-bellies squeal, make their cocks dangle, make their mothers weep and make their sons fear! CHAAARGEEE!%SPEECH_OFF% | You crouch hidden in the treeline of the forest, watching the armies of %enemy1% and %enemy2% march towards each other. Suddenly, out of the corner of your left eye, you notice a few figures racing toward the battlefield. As you take a closer look, you realize it\'s more than just a few. Soon enough, your entire left flank is charging. And the right. And then the center. You notice %commander% standing nearby, his expression revealing a man whose plans have toppled like a wall of ice in summer heat.%SPEECH_ON%Oh, fucking northerners. Can\'t even wait to charge on time.%SPEECH_OFF%Then he draws his weapon and runs toward the battlefield.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "I guess we charge, too.",
					function getResult()
					{
						this.Contract.setState("Running_FinalBattle");
						return 0;
					}

				}
			]
		});
		
		this.m.Screens.push({
			ID = "JoinedEnemies",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_135.png[/img]{You crouch hidden in the treeline of the forest, watching the armies of %enemy1% and %enemy2% march towards each other. Just when they should come to blows, they stand and both sides turn towards your position.%SPEECH_ON%Fuck! They know we are here.%SPEECH_OFF%%randombrother% turns towards you, as if asking what to do? Almost as in reply comes a thundering voice.%SPEECH_ON%Stand firm men, fear them not for they are dogs and we are the wolves! Now howl with me.%SPEECH_OFF%%commander% lets out a shrieking howl and then he charges into the southerners. Everybody else howls and charges with him. | You watch armies of %enemy1% and %enemy2% come together but instead of trading blows, they start shaking hands and laughing.%SPEECH_ON%I don\'t think they are killing each other, chief.%SPEECH_OFF%%randombrother% points out the obvious, just as it is obvious the armies are now moving towards your positions. %commander% approaches you.%SPEECH_ON%They say the best-laid plans don\'t survive contact with the enemy. Mine crumbled even before that.%SPEECH_OFF%He starts laughing, as if the burden of the world has fallen from his shoulders.%SPEECH_ON%But we still fight.%SPEECH_OFF%He says it  matter-of-factly, but his eyes make it a question. You nod.%SPEECH_ON%We still fight.%SPEECH_OFF%}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "More work for us. Now charge!",
					function getResult()
					{
						this.Contract.setState("Running_FinalBattle");
						return 0;
					}

				}
			]
		});
		
		this.m.Screens.push({
			ID = "BatteredEnemy",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_135.png[/img]{It was a great battle between %winner% and %loser%, especially for the vultures, which have already started circling the battlefield. In the end, %winner% emerges victorious, but their ranks are severely decimated. Before the dust settles, %commander% approaches you.%SPEECH_ON%It is time. Let us finish them.%SPEECH_OFF% You agree and order your men to charge just as %commander% leads his warriors. | You watched the battle concealed in the nearby treeline. %winner% charged into the ranks of %loser%, but they stood firm. They fought it out for the better part of the morning, until finally, knights of %winner% broke through and shattered the line of %loser%. With the outcome of the battle clear, %commander% emerges from the treeline. He raises his weapon and calls for charge. %SPEECH_ON%They are weak! They are nothing but dogs and we are the wolves!  We will crush them! Their children and grandchildren will hear of the howling northerners and they will tremble with fear!%SPEECH_OFF%With those words, he charges into battle, and all around you, men follow suit.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Charge, brothers, there\'s a battle to be won!",
					function getResult()
					{
						this.Contract.setState("Running_FinalBattle");
						return 0;
					}

				}
			]
		});
		
		this.m.Screens.push({
			ID = "BatteredEnemyReinforcements",
			Title = "At the war camp...",
			Text = "[img]gfx/ui/events/event_135.png[/img]{It was a great battle between %winner% and %loser%, especially for the vultures, which have already started circling the battlefield. In the end, %winner% emerges victorious, but their ranks are severely decimated. Before the dust settles, %commander% approaches you. %SPEECH_ON%It is time. Let us finish them.%SPEECH_OFF%Just as he finishes speaking, a horn bellows in the distance. You spot more flags of %winner% arriving on the battlefield. Reinforcements, late for original battle, but just in time to face you. %commander% looks at you, his face a mask of stone.%SPEECH_ON%We still charge!%SPEECH_OFF% | You watched the battle concealed in the nearby treeline. %winner% charged into the ranks of %loser%, but they stood firm. They fought it out for the better part of the morning, until finally, knights of %winner% broke through and shattered the line of %loser%. With the outcome of the battle clear, %commander% emerges from the treeline. He raises his weapon and calls for charge. %SPEECH_ON%They are weak! They are nothing but dogs and we are the wolves!  We will crush them! Their children and grandchildren will hear of the howling northerners and they will tremble with fear!%SPEECH_OFF%Just as he finished those words, another banner of %winner% appeared behind a nearby hill.  Reinforcements, late, but unfortunately not too late to face you. %commander% does not seem phased as he leads the charge, with the rest of his men following closely behind him.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Charge, brothers, there\'s a battle to be won!",
					function getResult()
					{
						this.Contract.setState("Running_FinalBattle");
						return 0;
					}

				}
			]
		});
		
		
		this.m.Screens.push({
			ID = "BattleLost",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_86.png[/img]{Dead bodies everywhere. The silhouette of %commander% atop the corpses, his armor glinting, a shiny encasement of a fleshen ruin. %employer% will no doubt be saddened by the loss of the battle here, but there is nothing more that can be done. | The battle is lost! %commander%\'s men have been slain to a scattering of survivors and the he himself has been struck down. Vultures are already cycling overhead and %winner%\'s men steadily work through the mounds of bodies to kill off any man pretending to be dead. You quickly gather the remnants of the %companyname% to retreat. %employer% will no doubt be horrified by the results here, but there\'s nothing that can be done now.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Not every battle can be won...",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractFail);
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractFail, "Lost an important battle");
						this.World.Contracts.finishActiveContract(true);
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "BattleWon",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_87.png[/img]{You\'ve triumphed! Well, you and %commander%\'s men both. The battle has been won, that\'s what is most important. You step over the mounds of bodies to prepare a return to %townname%. | Corpses in piles five deep. Vultures plucking morsels from the mounds. Wounded begging for help. Surely, to a stranger\'s eye, there does not appear to be any winner here. %commander%, however, comes over with a wide grin.%SPEECH_ON%Good work, warrior! You should get on back to %employer% and tell him what\'s happened here.%SPEECH_OFF% | The battle over, you find %commander% roaring and ripping off his armor and undershirt. He shows off his wounds, flexing so they open agape like seeping rinds of freshly cut fruit. He demands his men to do the same, turning each around so that he can see their back.%SPEECH_ON%You see, good warriors like us carry our wounds here, here, and here...%SPEECH_OFF%He points to every spot on the front of his body, and then he points to his back.%SPEECH_ON%But here, no man carries an injury here. Because we die going forward, not one step back! Isn\'t that right?%SPEECH_OFF%The men cheer, though some are woozy on their feet, blood trickling from their injuries. You ignore the theatrics and gather the men of the %companyname%. %employer% will surely be happy to hear of the results here. | %commander% greets you after the battle. He\'s drenched in blood as if he cut someone\'s head off and bathed beneath the spewing trunk. A white stroke of teeth glimmers when he smiles.%SPEECH_ON%Now that is what I call a fight.%SPEECH_OFF%You ask if he\'d say the same had he lost. He laughs.%SPEECH_ON%Oh, the cynic are we? No, I had no intention of losing here and, if I did, I had no intention of being alive to witness my own defeat.%SPEECH_OFF%You nod and respond.%SPEECH_ON%Rare is the man who gets to still be around to see his greatest defeat. It was good fighting with you, %commander%, but I must return to %townname% now.%SPEECH_OFF%The commander nods and then turns around, yelling for someone to fetch him a horn of mead. | You find %commander% punching a dagger into the side of a wounded man\'s chest. The felled enemy seizes to the pain, but he quickly fades thereafter, going limp in mere moments. A gush of blood follows the blade\'s retrieval as the commander wipes it on his pantleg.%SPEECH_ON%Right to the heart, quick and easy. What man could hope for better?%SPEECH_OFF%You nod and tell the commander that you are heading back to %townname%.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "Victory!",
					function getResult()
					{
						this.Contract.setState("Return");
						return 0;
					}

				}
			]
		});
		this.m.Screens.push({
			ID = "Success1",
			Title = "On your return...",
			Text = "[img]gfx/ui/events/event_04.png[/img]{You find %employer% hanging out at a small summer pond. He\'s scooping up frogs with a gentle hand. The slimy critters squirm and jump away.%SPEECH_ON%Victory belongs to us. I\'d say that is a job well done, warrior. It was a great opportunity and you jumped on it. Now we all get to reap the rewards. Here is the part you earned.%SPEECH_OFF% | You meet %employer% in the chieftain\'s hall. His face is that of a well satisfied man.%SPEECH_ON%We won! The glory is yours and %commander%\'s. The countryside of %enemy1% is undefended and the our men are already raiding and pillaging. This is your share of the loot!%SPEECH_OFF% | %employer% meets you in front of his home, his arms outstretched, ready to embrace you, which he does soon after.%SPEECH_ON%Words of our victory travel fast. %enemy1% is completely decimated and %enemy2% isn\'t faring any better. Both are offering tribute to be left alone. We\'ll take the gold they are offering, and then some they aren\'t. Here is your share of the plunder. You\'ve more than earned it.%SPEECH_OFF%}",
			Image = "",
			Characters = [],
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Gold well deserved.",
					function getResult()
					{
						this.World.Assets.addBusinessReputation(this.Const.World.Assets.ReputationOnContractSuccess);
						this.World.Assets.addMoney(this.Contract.m.Payment.getOnCompletion());
						this.World.FactionManager.getFaction(this.Contract.getFaction()).addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Won an important battle");
						this.World.Contracts.finishActiveContract();

						if (this.World.FactionManager.isCivilWar() || this.World.FactionManager.isHolyWar())
						{
							this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnCriticalContract);
						}

						return 0;
					}

				}
			],
			function start()
			{
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_money.png",
					text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + this.Contract.m.Payment.getOnCompletion() + "[/color] Crowns"
				});
			}

		});
	}

	function onCommanderPlaced( _entity, _tag )
	{
		_entity.setName(this.m.Flags.get("CommanderName"));
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"enemy1",
			this.World.FactionManager.getFaction(this.m.Flags.get("enemy1")).getName()
		]);
		_vars.push([
			"enemy2",
			this.World.FactionManager.getFaction(this.m.Flags.get("enemy2")).getName()
		]);
		_vars.push([
			"commander",
			this.m.Flags.get("CommanderName")
		]);
		_vars.push([
			"objective",
			this.m.Destination == null || this.m.Destination.isNull() ? "" : this.m.Destination.getName()
		]);
		_vars.push([
			"cost",
			this.m.Flags.get("RaidCost")
		]);
		_vars.push([
			"bribe",
			this.m.Flags.get("Bribe")
		]);

		if (this.m.Flags.get("IsInterceptSupplies"))
		{
			_vars.push([
				"supply_start",
				this.World.getEntityByID(this.m.Flags.get("InterceptSuppliesStart")).getName()
			]);
			_vars.push([
				"supply_dest",
				this.World.getEntityByID(this.m.Flags.get("InterceptSuppliesDest")).getName()
			]);
		}
		if (this.m.Destination == null)
		{
			_vars.push([
				"direction",
				this.m.WarcampTile == null ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.WarcampTile)]
			]);
		}
		else
		{
			_vars.push([
				"direction",
				this.m.Destination == null || this.m.Destination.isNull() ? "" : this.Const.Strings.Direction8[this.World.State.getPlayer().getTile().getDirection8To(this.m.Destination.getTile())]
			]);
		}
		
		if (this.m.Flags.get("ChampionBrotherName") != null)
		{
			_vars.push([
				"champbrother",
				this.m.Flags.get("ChampionBrotherName")
			]);
		}
		
		if(this.m.Flags.get("winner"))
		{
			_vars.push([
				"winner",
				this.World.FactionManager.getFaction(this.m.Flags.get("winner")).getName()
			]);
		}
		if(this.m.Flags.get("loser"))
		{
			_vars.push([
				"loser",
				this.World.FactionManager.getFaction(this.m.Flags.get("loser")).getName()
			]);
		}		
	}

	function onClear()
	{
		if (this.m.IsActive)
		{
			if (this.m.Destination != null && !this.m.Destination.isNull())
			{
				this.m.Destination.getSprite("selection").Visible = false;
				this.m.Destination.setOnCombatWithPlayerCallback(null);
			}

			if (this.m.Warcamp != null && !this.m.Warcamp.isNull())
			{
				this.m.Warcamp.die();
			}

			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function onIsValid()
	{
		if (!this.World.FactionManager.isCivilWar() && !this.World.FactionManager.isHolyWar() && false)
		{
			return false;
		}

		return true;
	}
	
	
	function barbarianCombat()
	{
		local p = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos(), true);
		p.CombatID = "Barbarians";
		p.Music = this.Const.Music.CivilianTracks;
		p.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
		p.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
		p.TemporaryEnemies = [
			this.m.Flags.get("enemy2")
		];
		p.AllyBanners = [
			this.World.Assets.getBanner()
		];
		p.EnemyBanners = [
			"banner_wildmen_03"
		];
		this.World.Contracts.startScriptedCombat(p, false, true, true);
	}

	function onSerialize( _out )
	{
		if (this.m.Destination != null && !this.m.Destination.isNull())
		{
			_out.writeU32(this.m.Destination.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		if (this.m.Warcamp != null && !this.m.Warcamp.isNull())
		{
			_out.writeU32(this.m.Warcamp.getID());
		}
		else
		{
			_out.writeU32(0);
		}

		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local destination = _in.readU32();

		if (destination != 0)
		{
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(destination));
		}

		local warcamp = _in.readU32();

		if (warcamp != 0)
		{
			this.m.Warcamp = this.WeakTableRef(this.World.getEntityByID(warcamp));
		}

		this.contract.onDeserialize(_in);
	}

});

