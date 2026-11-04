"
I display a Workflow decision or merge node: a diamond.
"
Class {
	#name : 'GLSPWorkflowDiamondView',
	#superclass : 'GLSPBlocNodeView',
	#category : 'GLSP-Client-Workflow',
	#package : 'GLSP-Client-Workflow'
}

{ #category : 'geometry' }
GLSPWorkflowDiamondView >> anchorIn: aRectangle towards: aPoint [
	"On the diamond: the point of the segment from my center to aPoint where |dx| / (width / 2) + |dy| / (height / 2) = 1"

	| center delta scale |
	center := aRectangle center.
	delta := aPoint - center.
	(delta x = 0 and: [ delta y = 0 ]) ifTrue: [ ^ center ].
	scale := 1 / (delta x abs / (aRectangle width / 2) + (delta y abs / (aRectangle height / 2))).
	^ center + (delta * (scale min: 1))
]

{ #category : 'updating' }
GLSPWorkflowDiamondView >> defaultSize [

	^ 32 @ 32
]

{ #category : 'updating' }
GLSPWorkflowDiamondView >> styleForGModel [

	| size |
	size := gmodel size ifNil: [ self defaultSize ].
	self
		extent: size;
		background: (Color r: 0.93 g: 0.96 b: 0.86);
		border: (BlBorder paint: (Color r: 0.45 g: 0.6 b: 0.3) width: 1);
		geometry: (BlPolygonGeometry vertices: {
						 (size x / 2 @ 0).
						 (size x @ (size y / 2)).
						 (size x / 2 @ size y).
						 (0 @ (size y / 2)) });
		zIndex: 0
]
