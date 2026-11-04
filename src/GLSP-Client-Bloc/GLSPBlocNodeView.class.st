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

{ #category : 'geometry' }
GLSPBlocNodeView >> anchorIn: aRectangle towards: aPoint [
	"The point where an edge going to aPoint leaves my outline, my bounds being aRectangle (diagram coordinates). Override for shapes that are not rectangles"

	^ GLSPBlocEdgeView clip: aRectangle towards: aPoint
]

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
	"As the Sprotty layouts of the Eclipse GLSP clients: hbox and vbox stack the children with a gap; without layout, the children are at their GModel position"

	gmodel layout = 'hbox' ifTrue: [
			^ BlLinearLayout horizontal
				  interspace: (self layoutOption: 'hGap' default: 1);
				  alignCenterLeft;
				  yourself ].
	gmodel layout = 'vbox' ifTrue: [
			^ BlLinearLayout vertical
				  interspace: (self layoutOption: 'vGap' default: 1);
				  alignTopCenter;
				  yourself ].
	^ GLSPBlocAbsoluteLayout new
]

{ #category : 'updating' }
GLSPBlocNodeView >> layoutOption: aName default: aNumber [

	^ (gmodel layoutOptions ifNil: [ Dictionary new ]) at: aName ifAbsent: [ aNumber ]
]

{ #category : 'updating' }
GLSPBlocNodeView >> paddingForGModel [
	"Sprotty layout paddings: 5 by default"

	gmodel layout ifNil: [ ^ BlInsets empty ].
	^ BlInsets
		  top: (self layoutOption: 'paddingTop' default: 5)
		  left: (self layoutOption: 'paddingLeft' default: 5)
		  bottom: (self layoutOption: 'paddingBottom' default: 5)
		  right: (self layoutOption: 'paddingRight' default: 5)
]

{ #category : 'updating' }
GLSPBlocNodeView >> styleForGModel [
	"Override in custom views to change the look of the node"

	self
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
	self padding: self paddingForGModel.
	self styleForGModel
]
