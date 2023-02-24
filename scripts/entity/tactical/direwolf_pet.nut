this.direwolf_pet <- this.inherit("scripts/entity/tactical/actor", {
	m = {
		Item = null,
		Name = "Direwolf"
	},
	function setItem( _i )
	{
		if (typeof _i == "instance")
		{
			this.m.Item = _i;
		}
		else
		{
			this.m.Item = this.WeakTableRef(_i);
		}
		
		//TODO: bonuses from level ups
	}

	function setName( _n )
	{
		this.m.Name = _n;
	}

	function getName()
	{
		return this.m.Name;
	}

	function create()
	{
		this.m.Type = this.Const.EntityType.Direwolf;
		this.m.BloodType = this.Const.BloodType.Red;
		this.m.XP = this.Const.Tactical.Actor.Direwolf.XP;
		this.m.IsActingImmediately = true;
		this.m.BloodSplatterOffset = this.createVec(0, 0);
		this.m.DecapitateSplatterOffset = this.createVec(-4, -25);
		this.m.DecapitateBloodAmount = 0.5;
		this.actor.create();
		this.m.Sound[this.Const.Sound.ActorEvent.DamageReceived] = [
			"sounds/enemies/werewolf_hurt_01.wav",
			"sounds/enemies/werewolf_hurt_02.wav",
			"sounds/enemies/werewolf_hurt_03.wav",
			"sounds/enemies/werewolf_hurt_04.wav"
		];
		this.m.Sound[this.Const.Sound.ActorEvent.Death] = [
			"sounds/enemies/werewolf_death_01.wav",
			"sounds/enemies/werewolf_death_02.wav",
			"sounds/enemies/werewolf_death_03.wav",
			"sounds/enemies/werewolf_death_04.wav",
			"sounds/enemies/werewolf_death_05.wav"
		];
		this.m.Sound[this.Const.Sound.ActorEvent.Flee] = [
			"sounds/enemies/werewolf_flee_01.wav",
			"sounds/enemies/werewolf_flee_02.wav",
			"sounds/enemies/werewolf_flee_03.wav",
			"sounds/enemies/werewolf_flee_04.wav",
			"sounds/enemies/werewolf_flee_05.wav",
			"sounds/enemies/werewolf_flee_06.wav"
		];
		this.m.Sound[this.Const.Sound.ActorEvent.Idle] = [
			"sounds/enemies/werewolf_idle_01.wav",
			"sounds/enemies/werewolf_idle_02.wav",
			"sounds/enemies/werewolf_idle_03.wav",
			"sounds/enemies/werewolf_idle_04.wav",
			"sounds/enemies/werewolf_idle_05.wav",
			"sounds/enemies/werewolf_idle_06.wav",
			"sounds/enemies/werewolf_idle_07.wav",
			"sounds/enemies/werewolf_idle_08.wav",
			"sounds/enemies/werewolf_idle_09.wav",
			"sounds/enemies/werewolf_idle_10.wav",
			"sounds/enemies/werewolf_idle_11.wav",
			"sounds/enemies/werewolf_idle_12.wav",
			"sounds/enemies/werewolf_idle_13.wav",
			"sounds/enemies/werewolf_idle_14.wav",
			"sounds/enemies/werewolf_idle_15.wav",
			"sounds/enemies/werewolf_idle_16.wav",
			"sounds/enemies/werewolf_idle_17.wav",
			"sounds/enemies/werewolf_idle_18.wav",
			"sounds/enemies/werewolf_idle_19.wav",
			"sounds/enemies/werewolf_idle_20.wav",
			"sounds/enemies/werewolf_idle_21.wav"
		];
		this.m.Sound[this.Const.Sound.ActorEvent.Attack] = [
			"sounds/enemies/werewolf_idle_01.wav",
			"sounds/enemies/werewolf_idle_02.wav",
			"sounds/enemies/werewolf_idle_03.wav",
			"sounds/enemies/werewolf_idle_05.wav",
			"sounds/enemies/werewolf_idle_06.wav",
			"sounds/enemies/werewolf_idle_07.wav",
			"sounds/enemies/werewolf_idle_08.wav"
		];
		this.m.Sound[this.Const.Sound.ActorEvent.Move] = [
			"sounds/enemies/werewolf_fatigue_01.wav",
			"sounds/enemies/werewolf_fatigue_02.wav",
			"sounds/enemies/werewolf_fatigue_03.wav",
			"sounds/enemies/werewolf_fatigue_04.wav",
			"sounds/enemies/werewolf_fatigue_05.wav",
			"sounds/enemies/werewolf_fatigue_06.wav",
			"sounds/enemies/werewolf_fatigue_07.wav"
		];
		this.m.SoundVolume[this.Const.Sound.ActorEvent.Attack] = 0.8;
		this.m.SoundVolume[this.Const.Sound.ActorEvent.Move] = 0.7;
		this.m.SoundPitch = this.Math.rand(95, 105) * 0.01;
		this.m.AIAgent = this.new("scripts/ai/tactical/agents/wardog_agent");
		this.m.AIAgent.setActor(this);
	}

	function setVariant( _v )
	{
		this.m.Items.getAppearance().Body = "bust_direwolf_01";
		this.getSprite("body").setBrush("bust_direwolf_01" );
		this.getSprite("head").setBrush("bust_direwolf_01_head");
		this.setDirty(true);
		/* 
		this.getSprite("body").setHorizontalFlipping(true);
		this.getSprite("head").setHorizontalFlipping(true);
		this.getSprite("injury").setHorizontalFlipping(true);
		 */
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if (_tile != null)
		{
			local flip = this.Math.rand(0, 100) < 50;
			local decal;
			this.m.IsCorpseFlipped = flip;
			local body = this.getSprite("body");
			local head = this.getSprite("head");
			local head_frenzy = this.getSprite("head_frenzy");
			decal = _tile.spawnDetail("bust_direwolf_01_body_dead", this.Const.Tactical.DetailFlag.Corpse, flip);
			decal.Color = body.Color;
			decal.Saturation = body.Saturation;
			decal.Scale = 0.95;

			if (_fatalityType != this.Const.FatalityType.Decapitated)
			{
				decal = _tile.spawnDetail(head.getBrush().Name + "_dead", this.Const.Tactical.DetailFlag.Corpse, flip);
				decal.Color = head.Color;
				decal.Saturation = head.Saturation;
				decal.Scale = 0.95;

				if (head_frenzy.HasBrush)
				{
					decal = _tile.spawnDetail(head_frenzy.getBrush().Name + "_dead", this.Const.Tactical.DetailFlag.Corpse, flip);
					decal.Scale = 0.95;
				}
			}
			else if (_fatalityType == this.Const.FatalityType.Decapitated)
			{
				local layers = [
					head.getBrush().Name + "_dead"
				];

				if (head_frenzy.HasBrush)
				{
					layers.push(head_frenzy.getBrush().Name + "_dead");
				}

				local decap = this.Tactical.spawnHeadEffect(this.getTile(), layers, this.createVec(0, 0), 0.0, "bust_direwolf_head_bloodpool");
				decap[0].Color = head.Color;
				decap[0].Saturation = head.Saturation;
				decap[0].Scale = 0.95;

				if (head_frenzy.HasBrush)
				{
					decap[1].Scale = 0.95;
				}
			}

			if (_skill && _skill.getProjectileType() == this.Const.ProjectileType.Arrow)
			{
				decal = _tile.spawnDetail("bust_direwolf_01_body_dead_arrows", this.Const.Tactical.DetailFlag.Corpse, flip);
				decal.Scale = 0.95;
			}
			else if (_skill && _skill.getProjectileType() == this.Const.ProjectileType.Javelin)
			{
				decal = _tile.spawnDetail("bust_direwolf_01_body_dead_javelin", this.Const.Tactical.DetailFlag.Corpse, flip);
				decal.Scale = 0.95;
			}

			this.spawnTerrainDropdownEffect(_tile);
			this.spawnFlies(_tile);
			local corpse = clone this.Const.Corpse;
			corpse.CorpseName = "A Direwolf";
			corpse.IsHeadAttached = _fatalityType != this.Const.FatalityType.Decapitated;
			_tile.Properties.set("Corpse", corpse);
			this.Tactical.Entities.addCorpse(_tile);

			if (_killer == null || _killer.getFaction() == this.Const.Faction.Player || _killer.getFaction() == this.Const.Faction.PlayerAnimals)
			{
				local n = 1 + (!this.Tactical.State.isScenarioMode() && this.Math.rand(1, 100) <= this.World.Assets.getExtraLootChance() ? 1 : 0);
			}
		}

		if (this.m.Item != null && !this.m.Item.isNull())
		{
			this.m.Item.setEntity(null);

			if (this.m.Item.getContainer() != null)
			{
				if (this.m.Item.getCurrentSlotType() == this.Const.ItemSlot.Bag)
				{
					this.m.Item.getContainer().removeFromBag(this.m.Item.get());
				}
				else
				{
					this.m.Item.getContainer().unequip(this.m.Item.get());
				}
			}

			this.m.Item = null;
		}

		this.actor.onDeath(_killer, _skill, _tile, _fatalityType);
	}

	function onFactionChanged()
	{
		this.actor.onFactionChanged();
		local flip = this.isAlliedWithPlayer();
		this.getSprite("body").setHorizontalFlipping(flip);
		this.getSprite("head").setHorizontalFlipping(flip);
		this.getSprite("injury").setHorizontalFlipping(flip);

		if (!this.Tactical.State.isScenarioMode())
		{
			local f = this.World.FactionManager.getFaction(this.getFaction());

			if (f != null)
			{
				this.getSprite("socket").setBrush(f.getTacticalBase());
			}
		}
		else
		{
			this.getSprite("socket").setBrush(this.Const.FactionBase[this.getFaction()]);
		}
	}

	function onActorKilled( _actor, _tile, _skill )
	{
		this.actor.onActorKilled(_actor, _tile, _skill);

		if (this.getFaction() == this.Const.Faction.Player || this.getFaction() == this.Const.Faction.PlayerAnimals)
		{
			local XPgroup = _actor.getXPValue();
			if ("XP" in this.m.Item.m)
			{
				this.m.Item.m.XP += XPgroup;
				return;
			}
			
			
			local brothers = this.Tactical.Entities.getInstancesOfFaction(this.Const.Faction.Player);

			foreach( bro in brothers )
			{
				if (bro.getCurrentProperties().IsAllyXPBlocked)
				{
					return;
				}

				bro.addXP(this.Math.max(1, this.Math.floor(XPgroup / brothers.len())));
			}
		}
	}

	function onInit()
	{
		this.actor.onInit();
		local b = this.m.BaseProperties;
		b.setValues(this.Const.Tactical.Actor.Direwolf);
		b.IsAffectedByNight = false;
		b.TargetAttractionMult = 0.1;
		b.IsAffectedByInjuries = false;
		b.IsImmuneToDisarm = true;
		this.m.ActionPoints = b.ActionPoints;
		this.m.Hitpoints = b.Hitpoints;
		this.m.CurrentProperties = clone b;
		this.m.ActionPointCosts = this.Const.DefaultMovementAPCost;
		this.m.FatigueCosts = this.Const.DefaultMovementFatigueCost;
		
		//appearance??
		this.m.Items.getAppearance().Body = "bust_direwolf_0" + this.Math.rand(1, 3) + "_body";
		this.addSprite("socket").setBrush("bust_base_player");
		local body = this.addSprite("body");
		body.setBrush("bust_direwolf_0" + this.Math.rand(1, 3));

		/* if (this.Math.rand(0, 100) < 90)
		{
			body.varySaturation(0.2);
		}

		if (this.Math.rand(0, 100) < 90)
		{
			body.varyColor(0.05, 0.05, 0.05);
		}
		*/
		local head = this.addSprite("head");
		head.setBrush("bust_direwolf_0" + this.Math.rand(1, 3) + "_head");
		head.Color = body.Color;
		head.Saturation = body.Saturation;
		local head_frenzy = this.addSprite("head_frenzy");
		local injury = this.addSprite("injury");
		injury.Visible = false;
		injury.setBrush("bust_direwolf_injured");
		local body_blood = this.addSprite("body_blood");
		body_blood.Visible = false;
		this.addDefaultStatusSprites();
		this.getSprite("status_rooted").Scale = 0.54;
		this.setSpriteOffset("status_rooted", this.createVec(0, 0));
		this.setSpriteOffset("status_stunned", this.createVec(0, -10));
		this.setSpriteOffset("arrow", this.createVec(0, -10));
		
		
		
		this.m.Skills.add(this.new("scripts/skills/actives/werewolf_bite"));
		this.m.Skills.add(this.new("scripts/skills/perks/perk_coup_de_grace"));
		this.m.Skills.add(this.new("scripts/skills/perks/perk_berserk"));
		this.m.Skills.add(this.new("scripts/skills/perks/perk_pathfinder"));

	}

});

