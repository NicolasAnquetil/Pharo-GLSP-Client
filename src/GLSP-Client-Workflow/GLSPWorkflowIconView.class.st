"
I display the icon of a Workflow task: 25x20, as in the Eclipse GLSP client, with a mark of the kind of task (M: manual, A: automated). My size does not depend on the GModel, so that the client layout gives the same bounds as the Eclipse client.
"
Class {
	#name : 'GLSPWorkflowIconView',
	#superclass : 'GLSPBlocNodeView',
	#category : 'GLSP-Client-Workflow',
	#package : 'GLSP-Client-Workflow'
}

{ #category : 'updating' }
GLSPWorkflowIconView >> defaultSize [
	"The size of the icons of the Eclipse GLSP Workflow client"

	^ 25 @ 20
]

{ #category : 'updating' }
GLSPWorkflowIconView >> isManual [
	^ gmodel parent isNotNil and: [ gmodel parent type = 'task:manual' ]
]

{ #category : 'updating' }
GLSPWorkflowIconView >> layoutForGModel [

	^ BlFrameLayout new
]

{ #category : 'updating' }
GLSPWorkflowIconView >> mark [

	^ self childWithId: #glspIconMark ifFound: [ :each | each ] ifNone: [
			  | mark |
			  mark := BlTextElement new.
			  mark id: #glspIconMark.
			  mark labelMeasurement.
			  mark constraintsDo: [ :c |
					  c frame horizontal alignCenter.
					  c frame vertical alignCenter ].
			  self addChild: mark.
			  mark ]
]

{ #category : 'updating' }
GLSPWorkflowIconView >> styleForGModel [

	self extent: self defaultSize.
	self mark text: ((self isManual
			  ifTrue: [ 'M' ]
			  ifFalse: [ 'A' ]) asRopedText bold
			 fontSize: 11;
			 yourself).
	self
		background: (Color white alpha: 0.7);
		border: (BlBorder paint: (Color gray: 0.6) width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		zIndex: 0
]

{ #category : 'updating' }
GLSPWorkflowIconView >> text [
	"The mark of the kind of task"

	^ self mark text
]
