"
I test the GLSP client against a real GLSP server (the TaskList example) running in the image, through a loopback connection.
"
Class {
	#name : 'GLSPClientTest',
	#superclass : 'GLSPClientTestCase',
	#category : 'GLSP-Client-Tests',
	#package : 'GLSP-Client-Tests'
}

{ #category : 'tests' }
GLSPClientTest >> testChangesAreAnnounced [

	| diagram kinds |
	diagram := self openModel.
	kinds := OrderedCollection new.
	diagram announcer when: GLSPClientDiagramChanged do: [ :announcement | kinds add: announcement action kind ] for: self.
	diagram
		dispatch: (GLSPCreateNodeOperation new
				 elementTypeId: 'task';
				 yourself)
		andWaitFor: 'setDirtyState'.
	self assert: kinds asArray equals: #( 'updateModel' 'setDirtyState' )
]

{ #category : 'tests' }
GLSPClientTest >> testCloseDisposesTheServerSession [

	| diagram |
	diagram := self openModel.
	diagram close.
	self assert: server sessions isEmpty.
	self deny: (client diagrams includes: diagram)
]

{ #category : 'tests' }
GLSPClientTest >> testErrorResponseSignalsAClientError [

	self
		should: [
				client request: 'initializeClientSession' params: (Dictionary new
						 at: 'clientSessionId' put: 'x';
						 at: 'diagramType' put: 'tasklist-diagram';
						 at: 'clientActionKinds' put: #(  );
						 yourself) ]
		raise: GLSPClientError
]

{ #category : 'tests' }
GLSPClientTest >> testInitializeServer [

	| result |
	result := client initializeServer.
	self assert: (result at: 'protocolVersion') equals: '1.0.0'.
	self assert: ((client serverActionsFor: 'tasklist-diagram') includes: 'requestModel')
]

{ #category : 'tests' }
GLSPClientTest >> testOpenDiagramCreatesAServerSession [

	| diagram |
	diagram := client openDiagram: 'tasklist-diagram'.
	self assert: (server sessions includesKey: diagram id).
	self assert: diagram diagramType equals: 'tasklist-diagram'
]

{ #category : 'tests' }
GLSPClientTest >> testOperationUpdatesTheModelAndTheDirtyState [

	| diagram |
	diagram := self openModel.
	diagram
		dispatch: (GLSPCreateNodeOperation new
				 elementTypeId: 'task';
				 location: 5 @ 5;
				 yourself)
		andWaitFor: 'setDirtyState'.
	self assert: diagram root children size equals: 4.
	self assert: diagram root revision equals: 2.
	self assert: diagram isDirty
]

{ #category : 'tests' }
GLSPClientTest >> testRequestAnswersTheResponse [

	| diagram response |
	diagram := self openModel.
	response := diagram requestTypeHints.
	self assert: response kind equals: 'setTypeHints'
]

{ #category : 'tests' }
GLSPClientTest >> testRequestModel [

	| diagram |
	diagram := self openModel.
	self assert: diagram root class equals: GLSPGModelRoot.
	self assert: diagram root children size equals: 3.
	self assert: (diagram root elementAt: 'task1_label') text equals: 'Push'.
	self deny: diagram isDirty
]

{ #category : 'tests' }
GLSPClientTest >> testTwoDiagramsAreIndependent [

	| first second |
	first := self openModel.
	second := self openModel.
	first
		dispatch: (GLSPCreateNodeOperation new
				 elementTypeId: 'task';
				 yourself)
		andWaitFor: 'setDirtyState'.
	self assert: first root children size equals: 4.
	self assert: second root children size equals: 3
]

{ #category : 'tests' }
GLSPClientTest >> testTypeHintsAndToolPalette [
	| diagram |
	diagram := self openModel.
	diagram requestTypeHints.
	self assert: (diagram shapeHints collect: [ :each | each at: 'elementTypeId' ] as: Array) equals: #( 'task' ).
	self assert: (diagram edgeHints collect: [ :each | each at: 'elementTypeId' ] as: Array) equals: #( 'transition' ).
	diagram requestToolPalette.
	self assert: (diagram paletteItems collect: [ :each | each at: 'label' ] as: Array) equals: #( 'Nodes' 'Edges' )
]

{ #category : 'tests' }
GLSPClientTest >> testUndoRedoAndSave [

	| diagram |
	diagram := self openModel.
	diagram
		dispatch: (GLSPDeleteElementOperation new
				 elementIds: #( 'task2' );
				 yourself)
		andWaitFor: 'setDirtyState'.
	self assert: diagram root children size equals: 1.
	diagram dispatch: GLSPUndoAction new andWaitFor: 'setDirtyState'.
	self assert: diagram root children size equals: 3.
	diagram dispatch: GLSPRedoAction new andWaitFor: 'setDirtyState'.
	self assert: diagram root children size equals: 1.
	diagram dispatch: GLSPSaveModelAction new andWaitFor: 'setDirtyState'.
	self deny: diagram isDirty.
	self assert: ((STONJSON fromString: file contents) at: 'tasks') size equals: 1
]

{ #category : 'tests' }
GLSPClientTest >> testWaitingForAnAnswerThatNeverComesSignalsAClientError [

	| diagram |
	diagram := self openModel.
	client timeout: 0.2.
	self should: [ diagram dispatch: GLSPUndoAction new andWaitFor: 'noSuchAction' ] raise: GLSPClientError
]
