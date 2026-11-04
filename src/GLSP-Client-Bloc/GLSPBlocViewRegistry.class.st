"
I choose the Bloc view class of a GModel element: the class registered for its type (e.g. 'task'), else the default view of its GModel class (node, label, edge, compartment, port).
"
Class {
	#name : 'GLSPBlocViewRegistry',
	#superclass : 'Object',
	#instVars : [
		'viewClassesByType'
	],
	#category : 'GLSP-Client-Bloc-Core',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Core'
}

{ #category : 'accessing' }
GLSPBlocViewRegistry >> defaultViewClassFor: aGModelElement [

	(aGModelElement isKindOf: GLSPGLabel) ifTrue: [ ^ GLSPBlocLabelView ].
	(aGModelElement isKindOf: GLSPGEdge) ifTrue: [ ^ GLSPBlocEdgeView ].
	(aGModelElement isKindOf: GLSPGShapeElement) ifTrue: [ ^ GLSPBlocNodeView ].
	^ nil
]

{ #category : 'accessing' }
GLSPBlocViewRegistry >> initialize [

	super initialize.
	viewClassesByType := Dictionary new
]

{ #category : 'accessing' }
GLSPBlocViewRegistry >> register: aViewClass forType: aTypeString [

	viewClassesByType at: aTypeString put: aViewClass
]

{ #category : 'accessing' }
GLSPBlocViewRegistry >> viewClassFor: aGModelElement [
	"The view class of aGModelElement, nil if it has no view"

	^ viewClassesByType at: aGModelElement type ifAbsent: [ self defaultViewClassFor: aGModelElement ]
]
