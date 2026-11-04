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
GLSPBlocDiagramElement >> anchorOf: anId towards: aPoint [
	"Where an edge going from the shape anId to aPoint leaves its outline (diagram coordinates), nil if anId is not a shape"

	| box |
	box := (self boundsOf: anId) ifNil: [ ^ nil ].
	^ (self viewAt: anId)
		  ifNil: [ GLSPBlocEdgeView clip: box towards: aPoint ]
		  ifNotNil: [ :view | view anchorIn: box towards: aPoint ]
]

{ #category : 'building' }
GLSPBlocDiagramElement >> boundsOf: anId [
	"The bounds in diagram coordinates of the shape anId, from the GModel (from its view when the GModel has no size)"

	| element origin extent |
	element := root elementAt: anId.
	(element isNotNil and: [ element isShape ]) ifFalse: [ ^ nil ].
	origin := 0 @ 0.
	element withAllParentsDo: [ :each |
		each isShape ifTrue: [ origin := origin + (each position ifNil: [ 0 @ 0 ]) ] ].
	extent := element size ifNil: [ (self viewAt: anId) ifNil: [ 0 @ 0 ] ifNotNil: [ :view | view extent ] ].
	^ origin extent: extent
]

{ #category : 'client' }
GLSPBlocDiagramElement >> diagram [

	^ diagram
]

{ #category : 'client' }
GLSPBlocDiagramElement >> diagram: aClientDiagramOrNil [
	"Follow a GLSPClientDiagram: show its model and each new model the server sends, and measure my views when the server asks for the bounds"

	diagram ifNotNil: [ :previous | previous announcer unsubscribe: self ].
	diagram := aClientDiagramOrNil.
	diagram ifNil: [ ^ self ].
	diagram boundsComputer: (GLSPBlocBoundsComputer registry: registry).
	diagram announcer when: GLSPClientDiagramChanged send: #diagramChanged: to: self.
	diagram root ifNotNil: [ :aRoot | self root: aRoot ]
]

{ #category : 'client' }
GLSPBlocDiagramElement >> diagramChanged: aClientDiagramChanged [

	(#( 'setModel' 'updateModel' ) includes: aClientDiagramChanged action kind) ifFalse: [ ^ self ].
	self applyInUIProcess: [ self root: diagram root ]
]

{ #category : 'initialization' }
GLSPBlocDiagramElement >> initialize [

	super initialize.
	registry := GLSPBlocViewRegistry new.
	views := Dictionary new.
	self background: Color white
]

{ #category : 'building' }
GLSPBlocDiagramElement >> place: aView in: aParentElement [
	"Edges are always my direct children: their points are in diagram coordinates"

	| container |
	container := aView isEdgeView
		             ifTrue: [ self ]
		             ifFalse: [ aParentElement ].
	aView parent == container ifTrue: [ ^ self ].
	aView removeFromParent.
	container addChild: aView
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
GLSPBlocDiagramElement >> registry: aViewRegistry [

	registry := aViewRegistry
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
	views keys do: [ :each | (seen includes: each) ifFalse: [ (views removeKey: each) removeFromParent ] ].
	self updateEdges
]

{ #category : 'building' }
GLSPBlocDiagramElement >> synchronizeViewOf: aGModelElement in: aParentElement seen: aSet [
	"Update (or create) the view of aGModelElement and of its children"

	| view |
	view := (self viewFor: aGModelElement) ifNil: [ ^ self ].
	aSet add: aGModelElement id.
	view updateFrom: aGModelElement in: self.
	self place: view in: aParentElement.
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

{ #category : 'building' }
GLSPBlocDiagramElement >> viewFor: aGModelElement [
	"The view of aGModelElement: the current one if it still has the right class, else a new one. nil if aGModelElement has no view"

	| viewClass view |
	viewClass := (registry viewClassFor: aGModelElement) ifNil: [ ^ nil ].
	view := views at: aGModelElement id ifAbsent: [ nil ].
	view class = viewClass ifTrue: [ ^ view ].
	view ifNotNil: [ view removeFromParent ].
	view := viewClass new.
	view id: aGModelElement id asSymbol.
	^ views at: aGModelElement id put: view
]

{ #category : 'accessing' }
GLSPBlocDiagramElement >> views [

	^ views values
]
