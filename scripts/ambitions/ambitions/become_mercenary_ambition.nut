this.become_mercenary_ambition <- this.inherit("scripts/ambitions/ambition", {
	m = {
		ContractsToComplete = 0
	},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.become_mercenary";
		this.m.Duration = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "We will become a mercenary company and abandon old ways."
		this.m.UIText = "Complete more contracts";
		this.m.TooltipText = "Complete 8 more contracts of any kind to prove yourselves as a mercenary company.";
		this.m.SuccessText = "[img]gfx/ui/events/event_62.png[/img]When starting out, the world saw you for what you were: ambition armed with a weapon. Everyone has a dream, and about half those men have weapons on them. You were not unique, not outstanding, not even particularly dangerous if you\'re giving your old self a good look in the eye. But you made it. The doors shut in your face. The attempts at haggling that lost you good deals. The spitting. So much spitting. It\'s a cold world and you dared to warm your own damn self. And you succeeded.\n\n Contracts under your belt, contracts on the horizon, they\'re blurring together. A culture of victory has started to wash over the %companyname% and you\'ve good reason to be proud of your command of it.";
		this.m.SuccessButtonText = "We\'re no longer barbarians.";
	}

	function getUIText()
	{
		local d = 8 - (this.m.ContractsToComplete - this.World.Contracts.getContractsFinished());
		return this.m.UIText + " (" + this.Math.min(8, d) + "/8)";
	}

	function onUpdateScore()
	{
		if (!this.Const.DLC.Desert)
		{
			return;
		}

		if (this.World.Ambitions.getDone() < 1)
		{
			return;
		}

		if (this.World.Assets.getOrigin().getID() != "scenario.barbarian_raiders")
		{
			return;
		}
		if (this.World.Flags.get("NorthExpansionCivilLevel") != 2) {
			return;
		}
		if (this.World.Ambitions.getAmbition("ambition.king").isDone())
		{
			return;
		}

		this.m.ContractsToComplete = this.World.Contracts.getContractsFinished() + 8;
		this.m.Score = 1 + this.Math.rand(0, 5);
	}
	
	function onReward()
	{
		this.World.Ambitions.getAmbition("ambition.battle_standard").setDone(false);
		this.World.Ambitions.getAmbition("ambition.seargeant").setDone(false);
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/icons/special.png",
			text = "You are now considered mercenaries and not barbarians."
		});
		this.World.Ambitions.getAmbition("ambition.contracts").setDone(true);
		this.World.Flags.set("NorthExpansionCivilLevel", 3);
		
		for (local i = 0; i < this.World.FactionManager.m.Factions ; i++) {
			local f = this.World.FactionManager.m.Factions[i];
			if (f.getFlags().get("isBarbarianFaction"))
			{
				this.World.FactionManager.m.Factions.remove(i);
				foreach (s in f.getSettlements())
				{
					s.fadeOutAndDie();
				}
				
			}
			
			break;
		}
		
		this.World.Assets.m.BrothersMax = 20;
		
		
		local brothers = this.World.getPlayerRoster().getAll();
		foreach( bro in brothers )
		{
			local items = bro.getItems();
			
			foreach (item in items.getAllItems())
			{
				if (item.getID() == "accessory.skaldhorn")
				{
					item.removeSelf();
					return;
				}
			}
			
		}
		local stash = this.World.Assets.getStash();
		local item = stash.removeByID("accessory.skaldhorn");
	}

	function onCheckSuccess()
	{
		if (this.World.Contracts.getContractsFinished() >= this.m.ContractsToComplete)
		{
			return true;
		}

		return false;
	}

	function onSerialize( _out )
	{
		this.ambition.onSerialize(_out);
		_out.writeU16(this.m.ContractsToComplete);
	}

	function onDeserialize( _in )
	{
		this.ambition.onDeserialize(_in);
		this.m.ContractsToComplete = _in.readU16();
	}

});

