"
I display a Workflow fork or join node: a dark bar.
"
Class {
	#name : 'GLSPWorkflowBarView',
	#superclass : 'GLSPBlocNodeView',
	#category : 'GLSP-Client-Workflow',
	#package : 'GLSP-Client-Workflow'
}

{ #category : 'updating' }
GLSPWorkflowBarView >> defaultSize [

	^ 10 @ 50
]

{ #category : 'updating' }
GLSPWorkflowBarView >> styleForGModel [

	self
		extent: (gmodel size ifNil: [ self defaultSize ]);
		background: (Color gray: 0.15);
		border: BlBorder empty;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 2);
		zIndex: 0
]
