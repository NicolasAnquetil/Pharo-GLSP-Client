"
I display a GModel edge: a line from the border of its source to the border of its target (points in diagram coordinates, computed from the GModel bounds of the source and target).
"
Class {
	#name : 'GLSPBlocEdgeView',
	#superclass : 'BlElement',
	#instVars : [
		'gmodel',
		'fromPoint',
		'toPoint',
		'route',
		'arrowheadVertices'
	],
	#category : 'GLSP-Client-Bloc-Views',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Views'
}

{ #category : 'geometry' }
GLSPBlocEdgeView class >> clip: aRectangle towards: aPoint [
	"The point where the segment from the center of aRectangle to aPoint leaves aRectangle"

	| center delta scales |
	center := aRectangle center.
	delta := aPoint - center.
	(delta x = 0 and: [ delta y = 0 ]) ifTrue: [ ^ center ].
	scales := OrderedCollection new.
	delta x = 0 ifFalse: [ scales add: aRectangle width / 2 / delta x abs ].
	delta y = 0 ifFalse: [ scales add: aRectangle height / 2 / delta y abs ].
	^ center + (delta * (scales min min: 1))
]

{ #category : 'updating' }
GLSPBlocEdgeView >> arrowhead [

	^ self childWithId: #glspArrowhead ifFound: [ :each | each ] ifNone: [
			  | arrowhead |
			  arrowhead := BlElement new.
			  arrowhead id: #glspArrowhead.
			  arrowhead background: Color darkGray.
			  self addChild: arrowhead.
			  arrowhead ]
]

{ #category : 'updating' }
GLSPBlocEdgeView >> arrowheadFrom: aPoint to: aTipPoint [
	"The vertices of an arrowhead with its tip at aTipPoint, pointing from aPoint. nil when the two points are the same"

	| direction base side |
	aPoint = aTipPoint ifTrue: [ ^ nil ].
	direction := (aTipPoint - aPoint) normalized.
	base := aTipPoint - (direction * self arrowheadLength).
	side := direction y negated @ direction x * self arrowheadHalfWidth.
	^ {
		  aTipPoint.
		  (base + side).
		  (base - side) }
]

{ #category : 'updating' }
GLSPBlocEdgeView >> arrowheadHalfWidth [

	^ 4
]

{ #category : 'updating' }
GLSPBlocEdgeView >> arrowheadLength [

	^ 10
]

{ #category : 'updating' }
GLSPBlocEdgeView >> arrowheadVertices [
	"The tip, then the two base points of my arrowhead, in diagram coordinates. nil without arrowhead"

	^ arrowheadVertices
]

{ #category : 'updating' }
GLSPBlocEdgeView >> fromPoint [

	^ fromPoint
]

{ #category : 'updating' }
GLSPBlocEdgeView >> gmodel [

	^ gmodel
]

{ #category : 'updating' }
GLSPBlocEdgeView >> hasArrowhead [
	"Override to draw edges without arrowhead"

	^ true
]

{ #category : 'updating' }
GLSPBlocEdgeView >> isEdgeView [

	^ true
]

{ #category : 'updating' }
GLSPBlocEdgeView >> route [
	"My points in diagram coordinates: from the outline of my source, through my routing points, to the outline of my target"

	^ route
]

{ #category : 'updating' }
GLSPBlocEdgeView >> routeIn: aDiagramElement [

	| routingPoints source target first last |
	source := (aDiagramElement boundsOf: gmodel sourceId) ifNil: [ ^ nil ].
	target := (aDiagramElement boundsOf: gmodel targetId) ifNil: [ ^ nil ].
	routingPoints := (gmodel routingPoints ifNil: [ #(  ) ]) asArray.
	first := routingPoints ifEmpty: [ target center ] ifNotEmpty: [ routingPoints first ].
	last := routingPoints ifEmpty: [ source center ] ifNotEmpty: [ routingPoints last ].
	^ { (aDiagramElement anchorOf: gmodel sourceId towards: first) } , routingPoints
	  , { (aDiagramElement anchorOf: gmodel targetId towards: last) }
]

{ #category : 'updating' }
GLSPBlocEdgeView >> toPoint [

	^ toPoint
]

{ #category : 'updating' }
GLSPBlocEdgeView >> updateArrowheadIn: aBox [

	| triangle |
	arrowheadVertices ifNil: [ ^ self arrowhead visibility: BlVisibility gone ].
	triangle := Rectangle encompassing: arrowheadVertices.
	self arrowhead
		visibility: BlVisibility visible;
		position: triangle origin - aBox origin;
		extent: (triangle extent max: 1 @ 1);
		geometry: (BlPolygonGeometry vertices: (arrowheadVertices collect: [ :each | each - triangle origin ]))
]

{ #category : 'updating' }
GLSPBlocEdgeView >> updateFrom: aGModelElement in: aDiagramElement [

	gmodel := aGModelElement.
	"Bloc clips the children to the geometry, and my polyline has no area: my arrowhead would not be drawn"
	self clipChildren: false.
	self zIndex: 10
]

{ #category : 'updating' }
GLSPBlocEdgeView >> updateGeometryIn: aDiagramElement [
	"Compute my route from the bounds of my source and target, then my polyline and my arrowhead"

	| box |
	route := self routeIn: aDiagramElement.
	route ifNil: [ ^ self visibility: BlVisibility hidden ].
	fromPoint := route first.
	toPoint := route last.
	arrowheadVertices := self hasArrowhead ifTrue: [ self arrowheadFrom: (route at: route size - 1) to: toPoint ].
	box := Rectangle encompassing: route , (arrowheadVertices ifNil: [ #(  ) ]).
	self
		visibility: BlVisibility visible;
		position: box origin;
		extent: (box extent max: 1 @ 1);
		geometry: (BlPolylineGeometry vertices: (route collect: [ :each | each - box origin ]));
		border: (BlBorder paint: Color darkGray width: 1.5);
		outskirts: BlOutskirts centered.
	self updateArrowheadIn: box
]
