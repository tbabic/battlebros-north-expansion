this.nem_have_all_provisions_ambition <- this.inherit("scripts/ambitions/ambitions/have_all_provisions_ambition", {
	m = {},
	function create()
	{
		this.have_all_provisions_ambition.create();
		this.m.ID = "ambition.nem_have_all_provisions";
	}

	function onUpdateScore()
	{
		
		if (!this.World.Flags.get("NorthExpansionActive"))
		{
			return;
		}
		if (this.World.Flags.get("NorthExpansionCivilLevel") >= 3) {
			return;
		}
		
		if (this.World.Assets.getAverageMoodState() > this.Const.MoodState.Concerned)
		{
			return;
		}

		if (this.hasAllProvisions())
		{
			return;
		}

		this.m.Score = 1 + this.Math.rand(0, 5);
	}
	

	function onReward()
	{
		this.World.Ambitions.getAmbition("ambition.win_against_x").setDone(true);
		this.have_all_provisions_ambition.onReward();
	}

});

