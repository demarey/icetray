"
I'm a dialog that has different options. 
I'm a abstract class, I need to be used  through my children.

I'm kind of a ""tabbed"" dialog, but my options are ""mac style"": lateral and not top.
This is useful to keep a variable number of options.

Subclasses should override:
 - allTypes, returning a collection of composable presenters
 - doAccept with what to do on acceptance.
"
Class {
	#name : #ITOptionDialog,
	#superclass : #ITDialog,
	#instVars : [
		'title',
		'typeList',
		'type',
		'contentPanel',
		'panels',
		'acceptCallback',
		'cancelCallback'
	],
	#category : #'Icetray-Dialog'
}

{ #category : #specs }
ITOptionDialog class >> defaultSpec [
	<spec>
	
	^ SpecLayout composed
		newRow: [ :row | 
			row
				newColumn: #typeList width: 180;
				newColumn: #contentPanel ]
]

{ #category : #testing }
ITOptionDialog class >> isAbstract [

	^ ITOptionDialog == self
]

{ #category : #actions }
ITOptionDialog >> accept [
	^ [ self doAccept ]
		on: Error
		do: [ :e | (ITErrorDialog on: e) openWithSpec ]
]

{ #category : #private }
ITOptionDialog >> basicSelectionChanged: aType [
	type := aType.
	aType 
		ifNotNil: [ 	
			self title: type title.
			self replacePanelWith: type ]
		ifNil: [ 
			self removeAllPanels.
			self title: self class title ]
]

{ #category : #'accessing ui' }
ITOptionDialog >> contentPanel [
	^ contentPanel
]

{ #category : #'accessing ui' }
ITOptionDialog >> contentPanel: anObject [
	contentPanel := anObject
]

{ #category : #accessing }
ITOptionDialog >> contextSelection [
	^ type
]

{ #category : #actions }
ITOptionDialog >> doAccept [

	acceptCallback cull: self selectedType
]

{ #category : #private }
ITOptionDialog >> emptyPanel [
	^ PanelMorph new
		changeProportionalLayout;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		yourself	
]

{ #category : #initialization }
ITOptionDialog >> giveFocusToNextFrom: aModel [

	super giveFocusToNextFrom: aModel
]

{ #category : #accessing }
ITOptionDialog >> initialExtent [
	^ 600@300
]

{ #category : #initialization }
ITOptionDialog >> initializeTypeList [
	typeList widget 
		addColumn: (ITTableColumn newAction: #title icon: #icon);
		dataSource: self newTypeListDataSource;
		onAnnouncement: FTSelectionChanged send: #selectionChanged: to: self.
]

{ #category : #initialization }
ITOptionDialog >> initializeWidgets [
	contentPanel := self emptyPanel asSpecAdapter.
	typeList := self newFastTable.
	self initializeTypeList.
			
	self whenBuiltDo: [ :ann |
		self selectFirst ].

	self eventKeyStrokesForNextFocus do: [:each |
		typeList widget bindKeyCombination: each toAction: [ self giveFocusToNextFrom: typeList ] ].
	self eventKeyStrokesForPreviousFocus do: [:each |
		typeList widget bindKeyCombination: each toAction: [ self giveFocusToPreviousFrom: typeList ] ].
		
	self refreshFocusOrder.
]

{ #category : #'private factory' }
ITOptionDialog >> newTypeListDataSource [

	^ FTEasyListDataSource new 
		elements: self panels;
		display: [ :each | each title ];
		icon: [ :each | each icon ];
		yourself
]

{ #category : #'accessing ui' }
ITOptionDialog >> okEnabled: aValue [
	
	self window toolbar okButton enabled: aValue
]

{ #category : #opening }
ITOptionDialog >> openDialogOnAccept: anAcceptCallback onCancel: aCancelCallback [
	
	acceptCallback := anAcceptCallback.
	cancelCallback := aCancelCallback.
	self openDialogWithSpec
]

{ #category : #accessing }
ITOptionDialog >> panels [
	^ panels
]

{ #category : #accessing }
ITOptionDialog >> panels: anObject [
	panels := anObject
]

{ #category : #focus }
ITOptionDialog >> refreshFocusOrder [
	
	self focusOrder
		removeAll;
		add: self typeList;
		add: self selectedType;
		add: acceptButton;
		add: cancelButton
]

{ #category : #private }
ITOptionDialog >> removeAllPanels [
	| panelMorph |
	
	panelMorph := self contentPanel morph.
	panelMorph removeAllMorphs
]

{ #category : #private }
ITOptionDialog >> replacePanelWith: aType [
	| panelMorph specPanel |
	
	panelMorph := self contentPanel morph.
	panelMorph removeAllMorphs.
	
	aType ifNil: [ ^ self ].
	specPanel := aType buildWithSpec.
	panelMorph 
		addMorph: specPanel
		fullFrame: LayoutFrame identity.

	self eventKeyStrokesForNextFocus do: [:each |
		aType bindKeyCombination: each toAction: [ self giveFocusToNextFrom: specPanel ] ].
	self eventKeyStrokesForPreviousFocus do: [:each |
		aType bindKeyCombination: each toAction: [ self giveFocusToPreviousFrom: specPanel ] ].

	self refreshFocusOrder
]

{ #category : #private }
ITOptionDialog >> selectFirst [
	typeList widget selectRowIndex: 1.
	self basicSelectionChanged: self panels first 	
]

{ #category : #accessing }
ITOptionDialog >> selectedType [
	^ type
]

{ #category : #private }
ITOptionDialog >> selectionChanged: ann [
	self basicSelectionChanged: (ann newSelectedRowIndexes
		ifNotEmpty: [ :indexes |	self typeList widget dataSource realElementAt: indexes first ]
		ifEmpty: [ nil ])
]

{ #category : #'accessing ui' }
ITOptionDialog >> typeList [
	^ typeList
]

{ #category : #'accessing ui' }
ITOptionDialog >> typeList: anObject [
	typeList := anObject
]
