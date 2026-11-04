"
I run the tests against the Eclipse GLSP Workflow server with a Bloc diagram element following the diagram: the bounds asked by the server are measured on the Bloc views. Skipped when no server listens.
"
Class {
	#name : 'GLSPBlocEclipseWorkflowServerTest',
	#superclass : 'GLSPEclipseWorkflowServerTest',
	#category : 'GLSP-Client-Bloc-Tests',
	#package : 'GLSP-Client-Bloc-Tests'
}

{ #category : 'testing' }
GLSPBlocEclipseWorkflowServerTest class >> shouldInheritSelectors [

	^ true
]

{ #category : 'tests' }
GLSPBlocEclipseWorkflowServerTest >> openModel [
	"The diagram element follows the diagram before the model is asked: it answers the requestBounds"

	diagram := client openDiagram: 'workflow-diagram'.
	GLSPBlocDiagramElement new diagram: diagram.
	diagram requestModel: file asZnUrl printString.
	^ diagram
]

{ #category : 'tests' }
GLSPBlocEclipseWorkflowServerTest >> testCreatedTasksGetASize [
	| before task |
	self openModel.
	before := diagram root children collect: [ :each | each id ] as: Set.
	diagram dispatch: (GLSPCreateNodeOperation new elementTypeId: 'task:manual'; location: 300 @ 300; yourself) andWaitFor: 'setDirtyState'.
	self waitUntil: [ diagram root children anySatisfy: [ :each | (before includes: each id) not ] ].
	task := diagram root children detect: [ :each | (before includes: each id) not ].
	self assert: task size isNotNil.
	self assert: task size x > 30.
	self assert: task size y > 15.
	self assert: (task children allSatisfy: [ :each | each size isNotNil ])
]
