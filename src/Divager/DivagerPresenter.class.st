Class {
	#name : #DivagerPresenter,
	#superclass : #DynamicComposablePresenter,
	#instVars : [
		'panes',
		'firstPane',
		'maxPanesToShow'
	],
	#category : #Divager
}

{ #category : #specs }
DivagerPresenter class >> defaultSpec [
	<spec: #default>
	
	^ SpecLayout composed
]

{ #category : #adding }
DivagerPresenter >> addPane: aSpecPresenter [

	| newPaneId |
	newPaneId := ('pane' , (panes size + 1) asString) asSymbol.
	panes add: (DivagerPane new
		presenter: aSpecPresenter;
		id: newPaneId;
		yourself).
	widgets at: newPaneId put: aSpecPresenter.	
	firstPane := (panes size - maxPanesToShow + 1) max: 1.

	aSpecPresenter whenSelectionChanged: [ 
		self addPane: (self instantiate: DivagerRawInspector on: aSpecPresenter selection) ].

	self valueChanged.
	self refresh
]

{ #category : #adding }
DivagerPresenter >> addTabPresenter [

	self addPane: (self newTabManager
		addTab: (self newTab 
			label: 'Info';
			icon: (self iconNamed: #smallQuestion);
			closeable: false;
			contents: 'Hello worldy1' asMorph
			yourself);
		addTab: (self newTab 
			label: 'Info';
			icon: (self iconNamed: #smallQuestion);
			closeable: false;
			contents: 'Hello worldy2' asMorph
			yourself);
		addTab: (self newTab 
			label: 'Info';
			icon: (self iconNamed: #smallQuestion);
			closeable: false;
			contents: 'Hello worldy3' asMorph
			yourself)).
]

{ #category : #accessing }
DivagerPresenter >> addWidgetsTo: aRow [
	(panes copyFrom: firstPane to: (firstPane + maxPanesToShow - 1 min: panes size))
		do: [ :each | aRow newColumn: each id ]
]

{ #category : #adding }
DivagerPresenter >> firstPage [
	
	^ firstPane
]

{ #category : #adding }
DivagerPresenter >> firstPage: aPageNumber [

	firstPane := aPageNumber.
	self valueChanged.
	self refresh
]

{ #category : #adding }
DivagerPresenter >> initialize [

	maxPanesToShow := 3.
	firstPane := 1.
	panes := OrderedCollection new.
	super initialize.
]

{ #category : #adding }
DivagerPresenter >> maxPanesToShow [

	^ maxPanesToShow
]

{ #category : #adding }
DivagerPresenter >> maxPanesToShow: aPageCount [

	maxPanesToShow := aPageCount.
	firstPane := ((panes size - maxPanesToShow) min: firstPane) max: 1.
	
	self valueChanged.
	self refresh
]

{ #category : #accessing }
DivagerPresenter >> newLayout [
	^ SpecLayout composed 
]

{ #category : #accessing }
DivagerPresenter >> pageCount [
	
	^ panes size
]

{ #category : #accessing }
DivagerPresenter >> refresh [
	self layout: self newLayout.
	self layout newRow: [ :row | self addWidgetsTo: row ].
	self needFullRebuild: false.
	self buildWithSpecLayout: self layout
]