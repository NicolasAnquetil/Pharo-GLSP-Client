"
I display a Workflow task (task:manual or task:automated): a rounded box, colored by the kind of task.
"
Class {
	#name : 'GLSPWorkflowTaskView',
	#superclass : 'GLSPBlocNodeView',
	#category : 'GLSP-Client-Workflow',
	#package : 'GLSP-Client-Workflow'
}

{ #category : 'updating' }
GLSPWorkflowTaskView >> isManual [

	^ gmodel type = 'task:manual'
]

{ #category : 'updating' }
GLSPWorkflowTaskView >> styleForGModel [

	| radius |
	radius := (gmodel args ifNil: [ Dictionary new ]) at: 'radiusTopLeft' ifAbsent: [ 5 ].
	self
		background: (self isManual
				 ifTrue: [ Color r: 1.0 g: 0.93 b: 0.82 ]
				 ifFalse: [ Color r: 0.86 g: 0.92 b: 1.0 ]);
		border: (BlBorder
				 paint: (self isManual
						  ifTrue: [ Color r: 0.85 g: 0.55 b: 0.2 ]
						  ifFalse: [ Color r: 0.3 g: 0.5 b: 0.85 ])
				 width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: radius);
		zIndex: 0
]
