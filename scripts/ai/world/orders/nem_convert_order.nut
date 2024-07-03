this.nem_convert_order <- this.inherit("scripts/ai/world/world_behavior", {
	m = {
		IsBurning = false,
		TargetLocation = null,
		Time = 0.0,
		Start = 0.0
	},
	function setTargetLocation( _t )
	{
		if (typeof _t == "instance")
		{
			this.m.TargetLocation = _t;
		}
		else
		{
			this.m.TargetLocation = this.WeakTableRef(_t);
		}
	}

	function setTime( _t )
	{
		this.m.Time = _t;
	}

	function create()
	{
		this.world_behavior.create();
		this.m.ID = this.Const.World.AI.Behavior.ID.Raid;
	}

	function onSerialize( _out )
	{
		this.world_behavior.onSerialize(_out);
		_out.writeU32(this.m.TargetLocation.getID())
		_out.writeF32(this.m.Time);
		_out.writeF32(this.m.Start);
	}

	function onDeserialize( _in )
	{
		this.world_behavior.onDeserialize(_in);
		local target = _in.readU32();
		this.setTargetLocation(this.World.getEntityByID(target));
		this.m.Time = _in.readF32();
		this.m.Start = _in.readF32();
	}

	function onExecute( _entity, _hasChanged )
	{
		this.logInfo("nem converting");
		if (!this.World.FactionManager.isGreaterEvil())
		{
			this.getController().popOrder();
			return true;
		}
		
		if (this.m.TargetLocation == null || this.m.TargetLocation.isNull() || !this.m.TargetLocation.isAlive())
		{
			this.getController().popOrder();
			return true;
		}
		
		if (_entity.getTile().ID != this.m.TargetLocation.getTile().ID)
		{
			local move = this.new("scripts/ai/world/orders/move_order");
			move.setDestination(this.m.TargetLocation.getTile());
			this.getController().addOrderInFront(move);
			return true;
		}

		_entity.setOrders("Converting");

		if (this.m.Start == 0.0)
		{
			this.m.Start = this.Time.getVirtualTimeF();
		}
		else if (this.Time.getVirtualTimeF() - this.m.Start >= this.m.Time)
		{

			if (this.m.TargetLocation != null && !this.m.TargetLocation.isNull() && this.m.TargetLocation.isAlive())
			{
				this.World.FactionManager.addGreaterEvilStrength(this.Const.Factions.GreaterEvilStrengthOnTownDestroyed);
				
				local tile = this.m.TargetLocation.getTile();
				local name = this.m.TargetLocation.getName();
				local sprite = null;
				if ("Sprite" in this.m.TargetLocation.m)
				{
					sprite = this.m.TargetLocation.m.Sprite;
				}
				
				this.m.TargetLocation.fadeOutAndDie();
				local n = this.World.spawnLocation("scripts/entity/world/locations/undead_necropolis_location", tile.Coords);
				n.setName(name);
				if(sprite != null)
				{
					n.setSprite(sprite);
				}
				else
				{
					local body = n.addSprite("body");
					body.setBrush("world_necromancers_lair_01");
					this.getSprite("lighting").setBrush("townhall_01_undead_lights");
				}
				
				n.onSpawned();
				n.setBanner(_entity.getBanner());
				this.World.FactionManager.getFaction(_entity.getFaction()).addSettlement(n, false);
			}

			this.getController().popOrder();
		}

		if (!this.m.IsBurning)
		{
			this.m.IsBurning = true;
			this.m.TargetLocation.spawnFireAndSmoke();
		}

		return true;
	}

});

