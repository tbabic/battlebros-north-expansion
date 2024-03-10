::mods_hookNewObject("factions/barbarian_faction", function(o) {
    ::mods_override(o, "onUpdate", function()
	{
        logInfo("barbarians update: " + this);
        foreach (s in this.getSettlements()) {
            
            if(s.isReadyForContract())
            {
                s.createNewContract();
            }
        }
    });
    
    ::mods_override(o, "addContract", function(_c)
	{
        logInfo("adding contract");
        _c.setFaction(this.getID());
		this.m.Contracts.push(_c);
    });
    
    
});


::mods_hookNewObject("contracts/contract_manager", function(o) {

    
    ::mods_override(o, "addContract", function(_contract, _isNewContract = true)
	{
        logInfo("cm - addingContract " + _contract.getFaction());
        if (!_contract.isValid())
		{
            logInfo("cm - invalid contract " +  _contract.getFaction());
			return;
		}

		if (_isNewContract)
		{
			_contract.m.ID = this.generateContractID();
			_contract.m.TimeOut += this.World.getTime().SecondsPerDay * (this.Math.rand(0, 200) - 100) * 0.01;
		}

		this.logDebug("contract added: " + _contract.getName());

        logInfo("cm - contract faction:" + _contract.getFaction());
		if (_contract.getFaction() != 0)
		{
			this.World.FactionManager.getFaction(_contract.getFaction()).addContract(_contract);

			if (_isNewContract)
			{
				this.World.FactionManager.getFaction(_contract.getFaction()).setLastContractTime(this.Time.getVirtualTimeF());
			}
		}

		this.m.Open.push(_contract);
    });
    
    
});