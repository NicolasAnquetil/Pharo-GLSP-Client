"
I display the tool palette of a GLSPClientDiagram: a header for each group (e.g. Nodes, Edges) followed by its items (e.g. Task, Transition). I follow the palette items the server sends.
"
Class {
	#name : 'GLSPBlocPaletteElement',
	#superclass : 'BlElement',
	#traits : 'GLSPTBlocUIProcess',
	#classTraits : 'GLSPTBlocUIProcess classTrait',
	#instVars : [
		'diagram',
		'itemViews',
		'groupViews'
	],
	#category : 'GLSP-Client-Bloc-Editor',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Editor'
}

{ #category : 'building' }
GLSPBlocPaletteElement >> addItemView: aPaletteItem [

	| view |
	view := self addText: (aPaletteItem at: 'label') asRopedText.
	view padding: (BlInsets
			 top: 2
			 left: 10
			 bottom: 2
			 right: 4).
	view userData at: #glspPaletteItem put: aPaletteItem.
	^ view
]

{ #category : 'building' }
GLSPBlocPaletteElement >> addText: aRopedText [

	| view |
	view := BlTextElement new text: (aRopedText
			         fontSize: 12;
			         yourself).
	self addChild: view.
	^ view
]

{ #category : 'accessing' }
GLSPBlocPaletteElement >> diagram [

	^ diagram
]

{ #category : 'accessing' }
GLSPBlocPaletteElement >> diagram: aClientDiagramOrNil [

	diagram ifNotNil: [ :previous | previous announcer unsubscribe: self ].
	diagram := aClientDiagramOrNil.
	diagram ifNotNil: [ diagram announcer when: GLSPClientDiagramChanged send: #diagramChanged: to: self ].
	self refresh
]

{ #category : 'accessing' }
GLSPBlocPaletteElement >> diagramChanged: aClientDiagramChanged [

	aClientDiagramChanged action kind = 'setContextActions' ifTrue: [ self applyInUIProcess: [ self refresh ] ]
]

{ #category : 'accessing' }
GLSPBlocPaletteElement >> groupLabels [
	^ groupViews collect: [ :each | each text asString ] as: Array
]

{ #category : 'initialization' }
GLSPBlocPaletteElement >> initialize [

	super initialize.
	groupViews := OrderedCollection new.
	itemViews := OrderedCollection new.
	self
		layout: (BlLinearLayout vertical cellSpacing: 4);
		padding: (BlInsets all: 8);
		background: (Color gray: 0.94);
		constraintsDo: [ :c |
				c horizontal exact: 140.
				c vertical matchParent ]
]

{ #category : 'accessing' }
GLSPBlocPaletteElement >> itemLabels [
	^ itemViews collect: [ :each | each text asString ] as: Array
]

{ #category : 'building' }
GLSPBlocPaletteElement >> refresh [
	self removeChildren.
	groupViews removeAll.
	itemViews removeAll.
	diagram ifNil: [ ^ self ].
	(self sorted: diagram paletteItems) do: [ :group |
		groupViews add: (self addText: (group at: 'label') asRopedText bold).
		itemViews addAll: ((self sorted: (group at: 'children' ifAbsent: [ #() ])) collect: [ :item | self addItemView: item ]) ]
]

{ #category : 'accessing' }
GLSPBlocPaletteElement >> sorted: paletteItems [

	^ paletteItems asSortedCollection: [ :a :b | (a at: 'sortString' ifAbsent: [ '' ]) <= (b at: 'sortString' ifAbsent: [ '' ]) ]
]
