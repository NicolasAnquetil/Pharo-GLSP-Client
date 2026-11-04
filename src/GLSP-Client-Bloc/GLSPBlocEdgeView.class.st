"
I display a GModel edge: a line from the border of its source to the border of its target (points in diagram coordinates, computed from the GModel bounds of the source and target).
"
Class {
	#name : 'GLSPBlocEdgeView',
	#superclass : 'BlElement',
	#instVars : [
		'gmodel',
		'fromPoint',
		'toPoint'
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
GLSPBlocEdgeView >> fromPoint [

	^ fromPoint
]

{ #category : 'updating' }
GLSPBlocEdgeView >> gmodel [

	^ gmodel
]

{ #category : 'updating' }
GLSPBlocEdgeView >> isEdgeView [

	^ true
]

{ #category : 'updating' }
GLSPBlocEdgeView >> toPoint [

	^ toPoint
]

{ #category : 'updating' }
GLSPBlocEdgeView >> updateFrom: aGModelElement in: aDiagramElement [

	gmodel := aGModelElement.
	self zIndex: 10
]

{ #category : 'updating' }
GLSPBlocEdgeView >> updateGeometryIn: aDiagramElement [
	"Compute my end points from the bounds of my source and target, then my line"

	| source target box |
	source := aDiagramElement boundsOf: gmodel sourceId.
	target := aDiagramElement boundsOf: gmodel targetId.
	(source isNil or: [ target isNil ]) ifTrue: [ ^ self visibility: BlVisibility hidden ].
	fromPoint := self class clip: source towards: target center.
	toPoint := self class clip: target towards: source center.
	box := Rectangle encompassing: {
			       fromPoint.
			       toPoint }.
	self
		visibility: BlVisibility visible;
		position: box origin;
		extent: (box extent max: 1 @ 1);
		geometry: (BlLineGeometry from: fromPoint - box origin to: toPoint - box origin);
		border: (BlBorder paint: Color darkGray width: 1.5);
		outskirts: BlOutskirts centered
]
