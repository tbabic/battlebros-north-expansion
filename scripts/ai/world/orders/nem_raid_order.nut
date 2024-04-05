this.nem_raid_order <- this.inherit("scripts/ai/world/world_behavior", {
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
		if (this.m.TargetLocation != null && _entity.getTile().ID != this.m.TargetLocation.getTile().ID)
		{
			local move = this.new("scripts/ai/world/orders/move_order");
			move.setDestination(this.m.TargetLocation.getTile());
			this.getController().addOrderInFront(move);
			return true;
		}

		_entity.setOrders("Raiding");

		if (this.m.Start == 0.0)
		{
			this.m.Start = this.Time.getVirtualTimeF();
		}
		else if (this.Time.getVirtualTimeF() - this.m.Start >= this.m.Time)
		{

			if (this.m.TargetLocation != null && !this.m.TargetLocation.isNull() && this.m.TargetLocation.isAlive())
			{
				local situation;
				local f = this.World.FactionManager.getFaction(_entity.getFaction());

				if (f != null && (f.getType() == this.Const.FactionType.Undead || f.getType() == this.Const.FactionType.Zombies))
				{
					situation = this.new("scripts/entity/world/settlements/situations/terrified_villagers_situation");
				}
				else
				{
					situation = this.new("scripts/entity/world/settlements/situations/raided_situation");
				}

				situation.setValidForDays(2);
				this.m.TargetLocation.addSituation(situation);
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

