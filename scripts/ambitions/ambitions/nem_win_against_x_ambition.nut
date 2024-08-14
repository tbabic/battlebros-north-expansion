this.nem_win_against_x_ambition <- this.inherit("scripts/ambitions/ambitions/win_against_x_ambition", {
	m = {
		IsFulfilled = false
	},
	function create()
	{
		this.win_against_x_ambition.create();
		this.m.ID = "ambition.nem_win_against_x";
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
		
		if (this.World.Statistics.getFlags().getAsInt("LastEnemiesDefeatedCount") >= 12)
		{
			return;
		}

		this.m.Score = 1 + this.Math.rand(0, 5);
	}

	

	function onReward()
	{
		this.World.Ambitions.getAmbition("ambition.win_against_x").setDone(true);
		this.win_against_x_ambition.onReward();
	}

});

