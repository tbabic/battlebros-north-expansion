this.barbarian_crowd_building <- this.inherit("scripts/entity/world/settlements/buildings/building", {
	m = {},
	function getUIImage()
	{
		logInfo("crowd - settlement id:" + this.m.Settlement.getID());
		local roster = this.m.Settlement.getHireRoster();

		if (roster.getSize() == 0 || !this.World.getTime().IsDaytime)
		{
			logInfo("roster size null: " + roster.getSize());
			return null;
		}
		else
		{
			return this.m.UIImage;
		}
	}

	function create()
	{
		this.building.create();
		this.m.ID = "building.crowd";
		this.m.UIImage = "ui/settlements/barbarian_crowd";
		this.m.Tooltip = "world-town-screen.main-dialog-module.Crowd";
		this.m.Name = "Hire";
	}

	function onClicked( _townScreen )
	{
		_townScreen.getHireDialogModule().setRosterID(this.m.Settlement.getID());
		_townScreen.showHireDialog();
		this.pushUIMenuStack();
	}

	function onSettlementEntered()
	{
	}

	function onSerialize( _out )
	{
		this.building.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.building.onDeserialize(_in);
	}
});

