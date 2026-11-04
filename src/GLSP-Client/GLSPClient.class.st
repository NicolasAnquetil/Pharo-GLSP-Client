"
I am a GLSP client: the client side of the protocol, independent from any rendering.

I send JSON-RPC requests and notifications to a GLSP server through a connection (an in-image GLSPLoopbackConnection or a socket), wait for the responses, and route the action messages received through the 'process' notification to the open diagrams (GLSPClientDiagram).

	client := GLSPClient loopbackOn: aGLSPServer.
	diagram := client openDiagram: 'tasklist-diagram'.
	diagram requestModel: 'file:///path/to/model.tasklist'.
	diagram root ""the current GModel""
"
Class {
	#name : 'GLSPClient',
	#superclass : 'Object',
	#instVars : [
		'connection',
		'nextId',
		'pending',
		'responses',
		'diagrams',
		'serverActions',
		'mutex'
	],
	#category : 'GLSP-Client-Core',
	#package : 'GLSP-Client',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GLSPClient class >> connection: aClientConnection [

	^ self new
		  setConnection: aClientConnection;
		  yourself
]

{ #category : 'instance creation' }
GLSPClient class >> loopbackOn: aGLSPServer [
	"A client talking to a server of the same image"

	^ self connection: (GLSPLoopbackConnection server: aGLSPServer)
]

{ #category : 'glsp' }
GLSPClient >> closeDiagram: aClientDiagram [

	diagrams removeKey: aClientDiagram id ifAbsent: [ ^ self ].
	self request: 'disposeClientSession' params: (Dictionary new
			 at: 'clientSessionId' put: aClientDiagram id;
			 yourself)
]

{ #category : 'glsp' }
GLSPClient >> diagrams [

	^ diagrams values
]

{ #category : 'initialization' }
GLSPClient >> initialize [

	super initialize.
	nextId := 0.
	pending := Dictionary new.
	responses := Dictionary new.
	diagrams := Dictionary new.
	mutex := Mutex new
]

{ #category : 'glsp' }
GLSPClient >> initializeServer [

	| result |
	result := self request: 'initialize' params: (Dictionary new
			           at: 'applicationId' put: 'pharo-glsp-client';
			           at: 'protocolVersion' put: '1.0.0';
			           yourself).
	serverActions := result at: 'serverActions' ifAbsent: [ Dictionary new ].
	^ result
]

{ #category : 'glsp' }
GLSPClient >> isInitialized [

	^ serverActions notNil
]

{ #category : 'json-rpc' }
GLSPClient >> message: aMethodName params: params [

	| message |
	message := Dictionary new
		           at: 'jsonrpc' put: '2.0';
		           at: 'method' put: aMethodName;
		           yourself.
	params ifNotNil: [ message at: 'params' put: params ].
	^ message
]

{ #category : 'json-rpc' }
GLSPClient >> notify: aMethodName params: params [

	connection send: (STONJSON toString: (self message: aMethodName params: params))
]

{ #category : 'glsp' }
GLSPClient >> openDiagram: aDiagramType [
	"Open a client session for a diagram of aDiagramType (initializing the server first if needed)"

	| diagram |
	self isInitialized ifFalse: [ self initializeServer ].
	diagram := GLSPClientDiagram client: self id: 'diagram-' , UUID new asString diagramType: aDiagramType.
	diagrams at: diagram id put: diagram.
	[
		self request: 'initializeClientSession' params: (Dictionary new
				 at: 'clientSessionId' put: diagram id;
				 at: 'diagramType' put: aDiagramType;
				 at: 'clientActionKinds' put: GLSPClientDiagram clientActionKinds;
				 yourself) ] ifCurtailed: [ diagrams removeKey: diagram id ifAbsent: [ ] ].
	^ diagram
]

{ #category : 'json-rpc' }
GLSPClient >> receive: aJSONString [
	"A message from the server: a response to one of my requests, or a notification"

	| message |
	message := STONJSON fromString: aJSONString.
	(message includesKey: 'method') ifFalse: [ ^ self receiveResponse: message ].
	(message at: 'method') = 'process' ifTrue: [ self receiveActionMessage: (GLSPActionMessage fromJSON: (message at: 'params')) ]
]

{ #category : 'json-rpc' }
GLSPClient >> receiveActionMessage: anActionMessage [

	diagrams at: anActionMessage clientId ifPresent: [ :diagram | diagram handleAction: anActionMessage action ]
]

{ #category : 'json-rpc' }
GLSPClient >> receiveResponse: aDictionary [

	| id |
	id := aDictionary at: 'id' ifAbsent: [ ^ self ].
	mutex critical: [
			responses at: id put: aDictionary.
			(pending at: id ifAbsent: [ nil ]) ifNotNil: [ :semaphore | semaphore signal ] ]
]

{ #category : 'json-rpc' }
GLSPClient >> request: aMethodName params: params [
	"Send a request and answer its result. Signal a GLSPClientError on an error response or without response in time"

	| id semaphore message response |
	id := mutex critical: [ nextId := nextId + 1 ].
	semaphore := Semaphore new.
	mutex critical: [ pending at: id put: semaphore ].
	message := self message: aMethodName params: params.
	message at: 'id' put: id.
	connection send: (STONJSON toString: message).
	(semaphore waitTimeoutSeconds: self timeout) ifTrue: [
			mutex critical: [ pending removeKey: id ifAbsent: [ ] ].
			GLSPClientError signal: 'No response to ' , aMethodName ].
	response := mutex critical: [
			            pending removeKey: id ifAbsent: [ ].
			            responses removeKey: id ].
	response
		at: 'error'
		ifPresent: [ :error | GLSPClientError signal: aMethodName , ': ' , (error at: 'message' ifAbsent: [ error printString ]) ].
	^ response at: 'result' ifAbsent: [ nil ]
]

{ #category : 'glsp' }
GLSPClient >> sendAction: anAction to: aClientDiagram [

	self notify: 'process' params: (GLSPActionMessage clientId: aClientDiagram id action: anAction) asJRPCJSON
]

{ #category : 'glsp' }
GLSPClient >> serverActionsFor: aDiagramType [

	^ (serverActions ifNil: [ Dictionary new ]) at: aDiagramType ifAbsent: [ #(  ) ]
]

{ #category : 'initialization' }
GLSPClient >> setConnection: aClientConnection [

	connection := aClientConnection.
	connection client: self
]

{ #category : 'glsp' }
GLSPClient >> shutdown [

	diagrams removeAll.
	self notify: 'shutdown' params: nil.
	connection close
]

{ #category : 'json-rpc' }
GLSPClient >> timeout [
	"Seconds to wait for the response to a request"

	^ 10
]
