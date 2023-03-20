::NorthMod.ContractUtils <- {

	function importSettlementIntro(_contract)
	{
		local relation = this.World.FactionManager.getFaction(_contract.getFaction()).getPlayerRelation();

		if (relation <= 35)
		{
			this.addScreen(_contract,::NorthMod.Const.Contracts.IntroSettlementCold);
		}
		else if (relation > 70)
		{
			this.addScreen(_contract,::NorthMod.Const.Contracts.IntroSettlementFriendly);
		}
		else
		{
			this.addScreen(_contract,::NorthMod.Const.Contracts.IntroSettlementNeutral);
		}
	}
	
	function addScreen(_contract, _screen)
	{
		local idx = -1;
		for( local i = 0; i < _contract.m.Screens.len(); i++ )
		{
			local s = _contract.m.Screens[i];
			if (s.ID == _screen.ID)
			{
				idx = i;
				break;
			}
		}
		if (idx > 0)
		{
			_contract.m.Screens[idx] = _screen;
		}
		else {
			_contract.m.Screens.push(_screen)
		}
	}
	
	function setScreenText(_contract, _screenID, _newText)
	{
		foreach(s in _contract.m.Screens[i])
		{
			if (s.ID == _screenID)
			{
				s.Text = _newText;
			}
		}
	}
	
};

