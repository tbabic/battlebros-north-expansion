this.direwolf_item <- this.inherit("scripts/items/accessory/accessory", {
	m = {
		Skill = null,
		Entity = null,
		Script = "scripts/entity/tactical/direwolf_pet",
		UnleashSounds = [
			"sounds/combat/unleash_wardog_01.wav",
			"sounds/combat/unleash_wardog_02.wav",
			"sounds/combat/unleash_wardog_03.wav",
			"sounds/combat/unleash_wardog_04.wav"
		],
		Friend = null,
		Level = 1
	},
	function isAllowedInBag()
	{
		return false;
	}

	function getScript()
	{
		return this.m.Script;
	}

	function isUnleashed()
	{
		return this.m.Entity != null;
	}

	function getName()
	{
		if (this.m.Entity == null)
		{
			return this.item.getName();
		}
		else
		{
			return "Direwolf Collar";
		}
	}

	function setName( _n )
	{
		this.m.Name = _n;
	}

	function getDescription()
	{
		if (this.m.Entity == null)
		{
			return this.item.getDescription();
		}
		else
		{
			return "The collar of a direwolf that has been unleashed onto the battlefield.";
		}
	}

	function create()
	{
		this.accessory.create();
		this.m.Variant = 1;
		this.updateVariant();
		this.m.ID = "accessory.direwolf";
		this.m.Name = "Ghost"
		this.m.Friend = "Jon The Crow";
		//TODO: description
		this.m.Description = "This large direwolf is loyal to his human friend " + this.m.Friend + ", but will not listen to anyone else";
		this.m.SlotType = this.Const.ItemSlot.Accessory;
		this.m.IsDroppedAsLoot = true;
		this.m.ShowOnCharacter = false;
		this.m.IsChangeableInBattle = false;
		this.m.Value = 0;
		
	}

	function playInventorySound( _eventType )
	{
		this.Sound.play("sounds/inventory/wardog_inventory_0" + this.Math.rand(1, 3) + ".wav", this.Const.Sound.Volume.Inventory);
	}

	function updateVariant()
	{	
		this.setEntity(this.m.Entity);
		if(this.m.Level == 2)
		{
			this.m.Description = "This large and ferocious direwolf is loyal to his human friend " + this.m.Friend + ", but will not listen to anyone else";
		}
	}

	function setEntity( _e )
	{
		this.m.Entity = _e;

		if (this.m.Entity != null)
		{
			this.m.Icon = "tools/hound_01_leash_70x70.png";
		}
		else
		{
			this.m.Icon = "tools/direwolf_70x70.png";
		}
		
	}

	function onEquip()
	{
		this.accessory.onEquip();
		local unleash = this.new("scripts/skills/actives/unleash_direwolf");
		unleash.setItem(this);
		this.m.Skill = this.WeakTableRef(unleash);
		this.addSkill(unleash);
		
		local actor = this.getContainer().getActor();
						
		
		if (!actor.getFlags().get("NorthExpansionWolfmaster"))
		{
			this.getContainer().unequip(this);
			this.World.Assets.getStash().add(this);
		}
	}

	function onCombatFinished()
	{
		this.setEntity(null);
	}

	function onActorDied( _onTile )
	{
		if (!this.isUnleashed() && _onTile != null)
		{
			local entity = this.Tactical.spawnEntity(this.getScript(), _onTile.Coords.X, _onTile.Coords.Y);
			entity.setItem(this);
			entity.setName(this.getName());
			entity.setVariant(this.getVariant());
			this.setEntity(entity);
			entity.setFaction(this.Const.Faction.PlayerAnimals);

			this.Sound.play(this.m.UnleashSounds[this.Math.rand(0, this.m.UnleashSounds.len() - 1)], this.Const.Sound.Volume.Skill, _onTile.Pos);
		}
	}

	function onSerialize( _out )
	{
		this.accessory.onSerialize(_out);
		_out.writeString(this.m.Name);
		_out.writeU16(this.m.Level);
	}

	function onDeserialize( _in )
	{
		this.accessory.onDeserialize(_in);
		this.m.Name = _in.readString();
		this.m.Level = _in.readU16();
		this.updateVariant();
	}
	
	

});

