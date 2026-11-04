"
I register the Bloc views of the Workflow example language of Eclipse GLSP (tasks, icons, decision, merge, fork and join nodes) on a view registry:

	GLSPWorkflowViews registerOn: aDiagramElement registry
"
Class {
	#name : 'GLSPWorkflowViews',
	#superclass : 'Object',
	#category : 'GLSP-Client-Workflow',
	#package : 'GLSP-Client-Workflow'
}

{ #category : 'registering' }
GLSPWorkflowViews class >> registerOn: aViewRegistry [
	"Register the views of the Workflow types on aViewRegistry"

	#( 'task:manual' 'task:automated' ) do: [ :each | aViewRegistry register: GLSPWorkflowTaskView forType: each ].
	aViewRegistry register: GLSPWorkflowIconView forType: 'icon'.
	#( 'activityNode:decision' 'activityNode:merge' ) do: [ :each | aViewRegistry register: GLSPWorkflowDiamondView forType: each ].
	#( 'activityNode:fork' 'activityNode:join' ) do: [ :each | aViewRegistry register: GLSPWorkflowBarView forType: each ]
]
