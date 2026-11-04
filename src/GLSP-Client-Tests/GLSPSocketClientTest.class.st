"
I run all the client tests through a real TCP socket, against a GLSP server of the image listening on a free port, and test what is specific to sockets (connection closed by either side).
"
Class {
	#name : 'GLSPSocketClientTest',
	#superclass : 'GLSPClientTest',
	#instVars : [
		'launcher'
	],
	#category : 'GLSP-Client-Tests',
	#package : 'GLSP-Client-Tests'
}

{ #category : 'testing' }
GLSPSocketClientTest class >> shouldInheritSelectors [
	"Run all the client tests through a socket"

	^ true
]

{ #category : 'running' }
GLSPSocketClientTest >> freePort [

	| socket port |
	socket := Socket newTCP.
	socket listenOn: 0 backlogSize: 1.
	port := socket port.
	socket closeAndDestroy.
	^ port
]

{ #category : 'running' }
GLSPSocketClientTest >> newClient [
	"Serve my server on a free port, and connect a client to it"

	launcher := GLSPSocketLauncher new.
	launcher serverFactory: [ server ].
	launcher startOnPort: 0.
	^ GLSPClient host: 'localhost' port: launcher port
]

{ #category : 'running' }
GLSPSocketClientTest >> tearDown [

	client ifNotNil: [ client connection close ].
	launcher ifNotNil: [ launcher stop ].
	super tearDown
]

{ #category : 'tests - socket' }
GLSPSocketClientTest >> testClientShutdownEndsTheServerConnection [

	self openModel.
	self waitUntil: [ launcher connections notEmpty ].
	client shutdown.
	self waitUntil: [ launcher connections isEmpty ].
	self assert: launcher connections isEmpty
]

{ #category : 'tests - socket' }
GLSPSocketClientTest >> testClosingADiagramAfterTheConnectionIsLost [

	| diagram |
	diagram := self openModel.
	launcher stop.
	self waitUntil: [ client connection isConnected not ].
	diagram close.
	self deny: (client diagrams includes: diagram)
]

{ #category : 'tests - socket' }
GLSPSocketClientTest >> testConnectingWithoutServerSignalsAClientError [

	self should: [ GLSPClient host: 'localhost' port: self freePort ] raise: GLSPClientError
]

{ #category : 'tests - socket' }
GLSPSocketClientTest >> testServerClosingTheConnectionFailsTheRequests [

	| start |
	client initializeServer.
	launcher stop.
	self waitUntil: [ client connection isConnected not ].
	start := DateAndTime now.
	self should: [ client request: 'initializeClientSession' params: Dictionary new ] raise: GLSPClientError.
	self assert: DateAndTime now - start < 2 seconds
]
