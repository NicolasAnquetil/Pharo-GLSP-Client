"
I display a GModel with Bloc. I have a view (a BlElement made by my view registry) for each element of the GModel, positioned in diagram coordinates. When I follow a GLSPClientDiagram, I update my views each time the server sends a new model.
"
Class {
	#name : 'GLSPBlocDiagramElement',
	#superclass : 'BlElement',
	#traits : 'GLSPTBlocUIProcess',
	#classTraits : 'GLSPTBlocUIProcess classTrait',
	#instVars : [
		'root',
		'registry',
		'views',
		'diagram'
	],
	#category : 'GLSP-Client-Bloc-Core',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Core'
}

{ #category : 'building' }
GLSPBlocDiagramElement >> boundsOf: anId [
	"The bounds in diagram coordinates of the shape anId, from the GModel (from its view when the GModel has no size)"

	| element origin extent |
	element := root elementAt: anId.
	(element isKindOf: GLSPGShapeElement) ifFalse: [ ^ nil ].
	origin := 0 @ 0.
	element withAllParentsDo: [ :each |
		(each isKindOf: GLSPGShapeElement) ifTrue: [ origin := origin + (each position ifNil: [ 0 @ 0 ]) ] ].
	extent := element size ifNil: [ (self viewAt: anId) ifNil: [ 0 @ 0 ] ifNotNil: [ :view | view extent ] ].
	^ origin extent: extent
]

{ #category : 'client' }
GLSPBlocDiagramElement >> diagram [

	^ diagram
]

{ #category : 'client' }
GLSPBlocDiagramElement >> diagram: aClientDiagramOrNil [
	"Follow a GLSPClientDiagram: show its model and each new model the server sends"

	diagram ifNotNil: [ :previous | previous announcer unsubscribe: self ].
	diagram := aClientDiagramOrNil.
	diagram ifNil: [ ^ self ].
	diagram announcer when: GLSPClientDiagramChanged send: #diagramChanged: to: self.
	diagram root ifNotNil: [ :aRoot | self root: aRoot ]
]

{ #category : 'client' }
GLSPBlocDiagramElement >> diagramChanged: aClientDiagramChanged [

	(#( 'setModel' 'updateModel' ) includes: aClientDiagramChanged action kind) ifFalse: [ ^ self ].
	self inUIProcessDo: [ self root: diagram root ]
]

{ #category : 'accessing' }
GLSPBlocDiagramElement >> initialize [

	super initialize.
	registry := GLSPBlocViewRegistry new.
	views := Dictionary new.
	self background: Color white
]

{ #category : 'building' }
GLSPBlocDiagramElement >> rebuild [
	"Recreate all the views from the GModel"

	self removeChildren.
	views removeAll.
	self synchronize
]

{ #category : 'accessing' }
GLSPBlocDiagramElement >> registry [

	^ registry
]

{ #category : 'accessing' }
GLSPBlocDiagramElement >> root [

	^ root
]

{ #category : 'accessing' }
GLSPBlocDiagramElement >> root: aGModelRoot [

	root := aGModelRoot.
	self synchronize
]

{ #category : 'building' }
GLSPBlocDiagramElement >> synchronize [
	"Make my views match the GModel, keeping the views of the elements that are still there"

	| seen |
	seen := Set new.
	root ifNotNil: [ root children do: [ :each | self synchronizeViewOf: each in: self seen: seen ] ].
	(views keys reject: [ :each | seen includes: each ]) do: [ :each | (views removeKey: each) removeFromParent ].
	self updateEdges
]

{ #category : 'building' }
GLSPBlocDiagramElement >> synchronizeViewOf: aGModelElement in: aParentElement seen: aSet [
	"Update (or create) the view of aGModelElement and of its children. Edges are always my direct children: their points are in diagram coordinates"

	| viewClass view container |
	viewClass := (registry viewClassFor: aGModelElement) ifNil: [ ^ self ].
	aSet add: aGModelElement id.
	view := views at: aGModelElement id ifAbsent: [ nil ].
	(view notNil and: [ view class ~= viewClass ]) ifTrue: [
			view removeFromParent.
			view := nil ].
	view ifNil: [
			view := viewClass new.
			view id: aGModelElement id asSymbol.
			views at: aGModelElement id put: view ].
	view updateFrom: aGModelElement in: self.
	container := view isEdgeView
		             ifTrue: [ self ]
		             ifFalse: [ aParentElement ].
	view parent == container ifFalse: [
			view removeFromParent.
			container addChild: view ].
	aGModelElement children do: [ :each | self synchronizeViewOf: each in: view seen: aSet ]
]

{ #category : 'building' }
GLSPBlocDiagramElement >> updateEdges [

	views do: [ :each | each isEdgeView ifTrue: [ each updateGeometryIn: self ] ]
]

{ #category : 'accessing' }
GLSPBlocDiagramElement >> viewAt: anId [
	"The view of the GModel element anId, or nil"

	^ views at: anId ifAbsent: [ nil ]
]

{ #category : 'accessing' }
GLSPBlocDiagramElement >> views [

	^ views values
]
