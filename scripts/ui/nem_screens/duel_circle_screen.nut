this.duel_circle_screen <- ::inherit("scripts/mods/msu/ui_screen", {
    m = {
        ID = "DuelCircleScreen"
		DuelingCircle = null,
        IsStartingCombat = false
    },
    
    function setDuelingCircle( _duelingCircle)
	{
        if (typeof _duelingCircle == "instance")
		{
			this.m.DuelingCircle = _duelingCircle;
		}
		else
		{
			this.m.DuelingCircle = this.WeakTableRef(_duelingCircle);
		}
	}
    
    function startCombat(_entityID)
    {
        local championBro = this.Tactical.getEntityByID(_entityID);
        local duelSkill = this.new("scripts/skills/special/duel_effect")
		
        championBro.getSkills().add(duelSkill);
		local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
		properties.CombatID = "NEM_DuelingCircle";
		properties.Music = this.Const.Music.BarbarianTracks;
		properties.Entities = [];
		local champion = this.m.DuelingCircle.getChampion();
		local name = this.m.DuelingCircle.m.ChampionName;
        if (name == null)
        {
            name = "";
        }
		properties.Entities.push({
			ID = champion.ID,
			Variant = champion.Variant,
            Name = name,
			Row = 0,
			Script = champion.Script,
			Faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID()
			function Callback( _entity, _tag )
			{
				if(name != "")
				{
					_entity.setName(name);
				}
				
			}

		});
		properties.EnemyBanners.push(this.m.DuelingCircle.getSettlement().getBanner());
		properties.Players.push(championBro);
		properties.IsUsingSetPlayers = true;
		properties.IsFleeingProhibited = true;
		properties.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Custom;
		properties.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
		properties.TemporaryEnemies = [
			this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID()
		];
		properties.PlayerDeploymentCallback = function ()
		{
			::NorthMod.Utils.duelDeployment(properties);
		}
		properties.BeforeDeploymentCallback = ::NorthMod.Utils.duelCleanMap.bindenv(this);
		properties.AfterDeploymentCallback = ::NorthMod.Utils.duelPlaceActors.bindenv(this);
		
        local event = this.World.Events.getEvent("event.barbarian_dueling_circle");
        this.World.Events.m.ActiveEvent = event;
        event.setHome(this.m.DuelingCircle.getSettlement());
        event.onPrepare();
        event.m.ChampionBro = championBro;
        event.registerToShowAfterCombat("TheDuel2","TheDuel3");
        this.World.State.m.MenuStack.popAll();
        
        
        
        this.m.IsStartingCombat = false;
		this.World.State.startScriptedCombat(properties, false, false, false);
    }
    
    function show( _data )
	{
		
		local assets = this.UIDataHelper.convertAssetsInformationToUIData();
		_data.Assets <- assets;
		
        this.logInfo("starting show");
        this.m.IsStartingCombat = false;
		if (this.m.JSHandle == null)
		{
            this.logInfo("not connected");
			throw ::MSU.Exception.NotConnected("Dueling circle");
		}
		else if (this.isVisible())
		{
            this.logInfo("already shown");
			throw ::MSU.Exception.AlreadyInState("Dueling circle");
		}
        
        this.Tooltip.hide();
        this.World.State.m.WorldTownScreen.hideAllDialogs();
        this.World.State.m.MenuStack.push(function ()
        {
            this.logInfo("hiding duel circle - screen state: " + ::NorthMod.Screens.DuelCircleScreen.m.IsStartingCombat);
            
            ::NorthMod.Screens.DuelCircleScreen.hide();
            if(!::NorthMod.Screens.DuelCircleScreen.m.IsStartingCombat)
            {
                this.m.WorldTownScreen.getMainDialogModule().reload();
                this.m.WorldTownScreen.showLastActiveDialog();
            }
            
        });
        this.logInfo("showing circle");
		this.m.JSHandle.asyncCall("show", _data);
	}
    
    function onLeaveButtonPressed()
	{
        this.logInfo("leave button pressed");
		this.World.State.m.MenuStack.pop();
	}
	
	function onBrothersButtonPressed()
	{
		this.World.State.showCharacterScreenFromTown();
	}
        
})






