"
I test how a client diagram answers the requestBounds of a server that needs the client to compute the layout.
"
Class {
	#name : 'GLSPRequestBoundsTest',
	#superclass : 'TestCase',
	#instVars : [
		'connection',
		'client',
		'diagram'
	],
	#category : 'GLSP-Client-Tests',
	#package : 'GLSP-Client-Tests'
}

{ #category : 'tests' }
GLSPRequestBoundsTest >> receiveRequestBounds [

	diagram handleAction: (GLSPAction fromJSON: self requestBoundsJSON).
	self assert: connection sentActions size equals: 1.
	^ connection sentActions first
]

{ #category : 'tests' }
GLSPRequestBoundsTest >> requestBoundsJSON [

	^ STONJSON fromString:
		  '{"kind":"requestBounds","requestId":"r1","newRoot":{"type":"graph","id":"root","revision":3,"children":[{"type":"task:manual","id":"n1","position":{"x":10,"y":20},"size":{"width":30,"height":40},"children":[{"type":"label:heading","id":"l1","text":"A","position":{"x":5,"y":5},"size":{"width":20,"height":10}}]},{"type":"task:manual","id":"n2"},{"type":"edge","id":"e1","sourceId":"n1","targetId":"n1"}]}}'
]

{ #category : 'running' }
GLSPRequestBoundsTest >> setUp [

	super setUp.
	connection := GLSPRecordingClientConnection new.
	client := GLSPClient connection: connection.
	diagram := GLSPClientDiagram client: client id: 'd1' diagramType: 'workflow-diagram'
]

{ #category : 'tests' }
GLSPRequestBoundsTest >> testClientDeclaresRequestBounds [

	self assert: (GLSPClientDiagram clientActionKinds includes: 'requestBounds')
]

{ #category : 'tests' }
GLSPRequestBoundsTest >> testComputedBoundsOfTheShapesOfTheModel [
	| bounds node |
	bounds := (self receiveRequestBounds at: 'bounds') ifNil: [ #(  ) ].
	self assert: (bounds collect: [ :each | each at: 'elementId' ] as: Array) equals: #( 'n1' 'l1' ).
	node := bounds first.
	self assert: (node at: 'newSize') equals: (Dictionary new at: 'width' put: 30; at: 'height' put: 40; yourself).
	self assert: (node at: 'newPosition') equals: (Dictionary new at: 'x' put: 10; at: 'y' put: 20; yourself)
]

{ #category : 'tests' }
GLSPRequestBoundsTest >> testRequestBoundsDoesNotChangeTheModel [

	self receiveRequestBounds.
	self assert: diagram root isNil
]

{ #category : 'tests' }
GLSPRequestBoundsTest >> testRequestBoundsIsARequestBoundsAction [

	| action |
	action := GLSPAction fromJSON: self requestBoundsJSON.
	self assert: action class equals: GLSPRequestBoundsAction.
	self assert: action requestId equals: 'r1'.
	self assert: action isRequest
]

{ #category : 'tests' }
GLSPRequestBoundsTest >> testRequestBoundsIsAnsweredWithComputedBounds [

	| answer |
	answer := self receiveRequestBounds.
	self assert: (answer at: 'kind') equals: 'computedBounds'.
	self assert: (answer at: 'responseId') equals: 'r1'.
	self assert: (answer at: 'revision') equals: 3
]

{ #category : 'tests' }
GLSPRequestBoundsTest >> testTheBoundsComputerCanBeReplaced [

	| computer |
	computer := GLSPGModelBoundsComputer new.
	diagram boundsComputer: computer.
	self assert: diagram boundsComputer identicalTo: computer
]
