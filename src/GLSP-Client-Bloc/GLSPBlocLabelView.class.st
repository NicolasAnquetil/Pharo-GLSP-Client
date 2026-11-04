"
I display a GModel label: its text.
"
Class {
	#name : 'GLSPBlocLabelView',
	#superclass : 'BlTextElement',
	#instVars : [
		'gmodel'
	],
	#category : 'GLSP-Client-Bloc-Views',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Views'
}

{ #category : 'updating' }
GLSPBlocLabelView >> gmodel [

	^ gmodel
]

{ #category : 'updating' }
GLSPBlocLabelView >> isEdgeView [

	^ false
]

{ #category : 'updating' }
GLSPBlocLabelView >> updateFrom: aGModelElement in: aDiagramElement [
	gmodel := aGModelElement.
	self labelMeasurement.
	self text: (aGModelElement text asRopedText fontSize: 12).
	self position: (aGModelElement position ifNil: [ 0 @ 0 ]).
	self constraintsDo: [ :c | c frame horizontal alignCenter. c frame vertical alignCenter ]
]
