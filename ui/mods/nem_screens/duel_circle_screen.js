var DuelCircleScreen = function()
{
    MSUUIScreen.call(this);
    //_parent = Screens["WorldTownScreen"];
    
    
    this.mSQHandle = null;

	this.mRoster = null;

    // event listener
    this.mEventListener = null;

	// generic containers
	this.mContainer = null;
    this.mDialogContainer = null;
    this.mListContainer = null;
    this.mListScrollContainer = null;
    
    
    this.mDetailsPanel =
    {
        Container: null,
        CharacterImage: null,
        CharacterName: null,
        CharacterTraitsContainer: null,
        CharacterBackgroundTextContainer: null,
        CharacterBackgroundTextScrollContainer: null,
        CharacterBackgroundImage: null,
        OpponentName: null,
        OpponentImage : null,
        FightButton: null,
    };
    
    this.mDescriptionLabel = null;
    // assets labels
	this.mAssets = new WorldTownScreenAssets(this);
    this.mAssetValues = null;
    // buttons
    this.mLeaveButton = null;

    // generics
    this.mIsVisible = false;

    // selected entry
    this.mSelectedEntry = null;
    
    
}

DuelCircleScreen.prototype = Object.create(MSUUIScreen.prototype);
Object.defineProperty(DuelCircleScreen.prototype, 'constructor', {
    value: DuelCircleScreen,
    enumerable: false,
    writable: true
});


DuelCircleScreen.prototype.createDIV = function(_parentDiv)
{
    var self = this;

	// create: containers (init hidden!)
     this.mContainer = $('<div class="world-town-screen display-none opacity-none"/>');
     _parentDiv.append(this.mContainer);

    // create: containers (init hidden!)
    var dialogLayout = $('<div class="l-hire-dialog-container"/>');
    this.mContainer.append(dialogLayout);
    this.mDialogContainer = dialogLayout.createDialog('Dueling Circle', '', '', true, 'dialog-1024-768');

    
    this.mIsVisible = false;
    
    // create tabs
    var tabButtonsContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(tabButtonsContainer);

	// create assets
    this.mAssets.createDIV(tabButtonsContainer);

	// create content
    var content = this.mDialogContainer.findDialogContentContainer();

	// left column
    var column = $('<div class="column is-left"/>');
    content.append(column);
    var listContainerLayout = $('<div class="l-list-container"/>');
    column.append(listContainerLayout);
    this.mListContainer = listContainerLayout.createList(8.85);
    this.mListScrollContainer = this.mListContainer.findListScrollContainer();
    
    

	// right column
    column = $('<div class="column is-right"/>');
    content.append(column);

	var detailsFrame = $('<div class="l-details-frame"/>');
    column.append(detailsFrame);
    this.mDetailsPanel.Container = $('<div class="details-container display-none"/>');
    detailsFrame.append(this.mDetailsPanel.Container);

    // details: character container
    var detailsRow = $('<div class="row is-character-container"/>');
    this.mDetailsPanel.Container.append(detailsRow);
    var detailsColumn = $('<div class="column is-character-portrait-container"/>');
    detailsRow.append(detailsColumn);
    this.mDetailsPanel.CharacterImage = detailsColumn.createImage(null, function (_image)
	{
        var offsetX = 0;
        var offsetY = 0;

        if(self.mSelectedEntry !== null)
        {
            var data = self.mSelectedEntry.data('entry');
            if('ImageOffsetX' in data && data['ImageOffsetX'] !== null &&
                'ImageOffsetY' in data && data['ImageOffsetY'] !== null)
            {
                offsetX = data['ImageOffsetX'];
                offsetY = data['ImageOffsetY'];
            }
        }

        _image.centerImageWithinParent(offsetX, offsetY, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');
    detailsColumn = $('<div class="column is-character-background-container"/>');
    detailsRow.append(detailsColumn);
    
    // details: background
    var backgroundRow = $('<div class="row is-top"/>');
    detailsColumn.append(backgroundRow);
	var backgroundRowBorder = $('<div class="row is-top border"/>');
	backgroundRow.append(backgroundRowBorder);

    this.mDetailsPanel.CharacterBackgroundImage = $('<img />');
    detailsColumn.append(this.mDetailsPanel.CharacterBackgroundImage);
    this.mDetailsPanel.CharacterName = $('<div class="name title-font-normal font-bold font-color-brother-name"/>');
    backgroundRow.append(this.mDetailsPanel.CharacterName);

    this.mDetailsPanel.CharacterTraitsContainer = $('<div class="traits-container"/>');
    backgroundRow.append(this.mDetailsPanel.CharacterTraitsContainer);
    
    
    //Conflict
    var opponentRow = $('<div class="conflict-container"/>');
    this.mDetailsPanel.Container.append(opponentRow);
    
    
    
    this.mDetailsPanel.OpponentName = $('<div class="title-font-very-big font-bold font-color-brother-name">VS</div>');
    opponentRow.append(this.mDetailsPanel.OpponentName);
    
    //Opponent
    
    var opponentRow = $('<div class="opponent-container"/>');
    this.mDetailsPanel.Container.append(opponentRow);
    
    
    
    this.mDetailsPanel.OpponentName = $('<div class="opponent-name title-font-normal font-bold font-color-brother-name"/>');
    opponentRow.append(this.mDetailsPanel.OpponentName);
    
    
    this.mDetailsPanel.OpponentImage = $('<div class="opponent-portrait"/>');
    opponentRow.append(this.mDetailsPanel.OpponentImage);
    
    
    detailsRow = $('<div class="row is-button-container"/>');
    this.mDetailsPanel.Container.append(detailsRow);
    var FightButtonLayout = $('<div class="l-hire-button" style="left:0"/>');
    
    detailsRow.append(FightButtonLayout);
    this.mDetailsPanel.FightButton = FightButtonLayout.createTextButton("Fight", function()
	{
        if(self.mSelectedEntry !== null)
        {
            var data = self.mSelectedEntry.data('entry');
            if('ID' in data && data['ID'] !== null)
            {
                self.notifyBackendFightButtonPressed(data['ID']);
            }
        }
    }, '', 1);
    
    
    var descriptionContainer = $('<div class="nem-description-container"/>');
    detailsFrame.append(descriptionContainer);
    this.mDescriptionLabel = $('<div class="text-font-medium font-bottom-shadow font-color-description display-block empty-duel"></div>');
    descriptionContainer.append(this.mDescriptionLabel);
    
	// create footer button bar
    var footerButtonBar = $('<div class="l-button-bar"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerButtonBar);

	// create: buttons
    var layout = $('<div class="l-leave-button"/>');
    footerButtonBar.append(layout);
    this.mLeaveButton = layout.createTextButton("Leave", function ()
    {
    	self.notifyBackendLeaveButtonPressed();
    }, '', 1);

    this.mIsVisible = false;
    
}

DuelCircleScreen.prototype.show = function (_data)
{
    this.mAssets.loadFromData(_data.Assets);
    
    this.mListScrollContainer.empty(); 
    for(var i = 0; i < _data.Bros.length; ++i)
    {
        this.addListEntry(_data.Bros[i]);
    }
    MSUUIScreen.prototype.show.call(this, true, false);
    this.selectListEntry(this.mListContainer.findListEntryByIndex(0), true);
    
    if(_data.Text != null && _data.Text != "")
    {
        this.mDescriptionLabel.text(_data.Text);
        
    }
    
    
    if(_data.Opponent == null)
    {
        this.mDescriptionLabel.removeClass("description-duel").addClass("empty-duel");
        this.mDetailsPanel.FightButton.enableButton(false);
    }
    else
    {
        this.mDetailsPanel.FightButton.enableButton(true);
        this.mDescriptionLabel.removeClass("empty-duel").addClass("description-duel");
        this.mDetailsPanel.OpponentImage.empty();
        
        var image = $('<img/>');
        image.attr('src', Path.PROCEDURAL + _data.OpponentImage);
        
        this.mDetailsPanel.OpponentImage.append(image);
        //this.mDetailsPanel.OpponentImage.centerImageWithinParent(0, 0, 1.0);
        this.mDetailsPanel.OpponentName.html(_data.Opponent);
    }
    
}

DuelCircleScreen.prototype.addListEntry = function(_entity)
{
    var result = $('<div class="l-row"/>');
    this.mListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry"/>');
    result.append(entry);
    entry.data('entry', _entity);
    entry.click(this, function(_event)
	{
        var self = _event.data;
        self.selectListEntry($(this));
    });

    // left column
    var column = $('<div class="column is-left"/>');
    entry.append(column);

    var imageOffsetX = ('ImageOffsetX' in _entity ? _entity['ImageOffsetX'] : 0);
    var imageOffsetY = ('ImageOffsetY' in _entity ? _entity['ImageOffsetY'] : 0);
    column.createImage(Path.PROCEDURAL + _entity['ImagePath'], function (_image)
	{
        _image.centerImageWithinParent(imageOffsetX, imageOffsetY, 0.64, false);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    // right column
    column = $('<div class="column is-right"/>');
    entry.append(column);

    // top row
    var row = $('<div class="row is-top"/>');
    column.append(row);

    var image = $('<img/>');
    image.attr('src', Path.GFX + _entity['BackgroundImagePath']);
    row.append(image);

    // bind tooltip
	image.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.CharacterBackgrounds.Generic, elementOwner: TooltipIdentifier.ElementOwner.HireScreen, entityId: _entity.ID });

    var name = $('<div class="name title-font-normal font-bold font-color-title">' + _entity.Name + '</div>');
    row.append(name);
    
    var levelContainer = $('<div class="l-level-container"/>');
	row.append(levelContainer);
    var level = $('<div class="level text-font-normal font-bold font-color-subtitle">' + _entity.Level + '</div>');
	levelContainer.append(level);

    // bottom row
    row = $('<div class="row is-bottom"/>');
    column.append(row);

    var traitsContainer = $('<div class="is-traits-container"/>');
    row.append(traitsContainer);
    
    for(var i = 0; i < _entity.Traits.length; ++i)
    {
        var icon = $('<img src="' + Path.GFX + _entity.Traits[i].icon + '"/>');
        icon.bindTooltip({ contentType: 'status-effect', entityId: _entity.ID, statusEffectId: _entity.Traits[i].id });
        traitsContainer.append(icon);
    }

    
}

DuelCircleScreen.prototype.selectListEntry = function(_element, _scrollToEntry)
{
    if (_element !== null && _element.length > 0)
    {
        this.mListContainer.deselectListEntries();
        _element.addClass('is-selected');

        // give the renderer some time to layout his shit...
        if (_scrollToEntry !== undefined && _scrollToEntry === true)
        {
            this.mListContainer.scrollListToElement(_element);
        }

        this.mSelectedEntry = _element;
        this.updateDetailsPanel(this.mSelectedEntry);
    }
    else
    {
        this.mSelectedEntry = null;
        this.updateDetailsPanel(this.mSelectedEntry);
    }
};

DuelCircleScreen.prototype.updateDetailsPanel = function(_element)
{
	if (_element !== null && _element.length > 0)
    {
        var _entity = _element.data('entry');
        this.mDetailsPanel.CharacterImage.attr('src', Path.PROCEDURAL + _entity['ImagePath']);     
       
        // retarded JS calls load callback after a significant delay only - so we call this here manually to position/resize an image that is completely loaded already anyway
        this.mDetailsPanel.CharacterImage.centerImageWithinParent(0, 0, 1.0); 
       
        this.mDetailsPanel.CharacterName.html(_entity['Name']);
        this.mDetailsPanel.CharacterBackgroundImage.attr('src', Path.GFX + _entity['BackgroundImagePath']);

        this.mDetailsPanel.CharacterTraitsContainer.empty();

        for(var i = 0; i < _entity.Traits.length; ++i)
        {
            var icon = $('<img src="' + Path.GFX + _entity.Traits[i].icon + '"/>');
            icon.bindTooltip({ contentType: 'status-effect', entityId: _entity.ID, statusEffectId: _entity.Traits[i].id });
            this.mDetailsPanel.CharacterTraitsContainer.append(icon);
        }

        // bind tooltips
        this.mDetailsPanel.CharacterBackgroundImage.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.CharacterBackgrounds.Generic, elementOwner: TooltipIdentifier.ElementOwner.HireScreen, entityId: _entity.ID });
        this.mDetailsPanel.Container.removeClass('display-none').addClass('display-block');
    }
    else
    {
        this.mDetailsPanel.Container.removeClass('display-block').addClass('display-none');
    }
};

DuelCircleScreen.prototype.hide = function ()
{
    MSUUIScreen.prototype.hide.call(this, true, false);
};

DuelCircleScreen.prototype.bindTooltips = function ()
{

};

DuelCircleScreen.prototype.unbindTooltips = function ()
{
    this.mLeaveButton.unbindTooltip();
};

DuelCircleScreen.prototype.notifyBackendLeaveButtonPressed = function ()
{
    SQ.call(this.mSQHandle, 'onLeaveButtonPressed');
};

DuelCircleScreen.prototype.notifyBackendFightButtonPressed = function (_entityID)
{
    SQ.call(this.mSQHandle, 'startCombat', _entityID);
};

DuelCircleScreen.prototype.notifyBackendBrothersButtonPressed = function()
{
    if(this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onBrothersButtonPressed');
    }
}



registerScreen("DuelCircleScreen", new DuelCircleScreen());