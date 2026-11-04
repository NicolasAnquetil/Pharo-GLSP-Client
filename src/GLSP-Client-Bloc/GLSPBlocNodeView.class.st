"
I display a GModel node (or compartment): a box at the position and with the size of the node, laid out as the node says (hbox, vbox), containing the views of its children.
"
Class {
	#name : 'GLSPBlocNodeView',
	#superclass : 'BlElement',
	#instVars : [
		'gmodel'
	],
	#category : 'GLSP-Client-Bloc-Views',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Views'
}

{ #category : 'updating' }
GLSPBlocNodeView >> gmodel [

	^ gmodel
]

{ #category : 'updating' }
GLSPBlocNodeView >> isEdgeView [

	^ false
]

{ #category : 'updating' }
GLSPBlocNodeView >> layoutForGModel [

	gmodel layout = 'hbox' ifTrue: [ ^ BlLinearLayout horizontal alignCenter ].
	gmodel layout = 'vbox' ifTrue: [ ^ BlLinearLayout vertical alignCenter ].
	^ BlFrameLayout new
]

{ #category : 'updating' }
GLSPBlocNodeView >> styleForGModel [
	"Override in custom views to change the look of the node"

	self
		padding: (BlInsets all: 6);
		background: Color white;
		border: (BlBorder paint: Color gray width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 5);
		zIndex: 0
]

{ #category : 'updating' }
GLSPBlocNodeView >> updateFrom: aGModelElement in: aDiagramElement [

	gmodel := aGModelElement.
	self position: (aGModelElement position ifNil: [ 0 @ 0 ]).
	aGModelElement size
		ifNil: [
				self constraintsDo: [ :c |
						c horizontal fitContent.
						c vertical fitContent ] ]
		ifNotNil: [ :size | self extent: size ].
	self layout: self layoutForGModel.
	self styleForGModel
]
