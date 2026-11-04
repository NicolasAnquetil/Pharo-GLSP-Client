"
I connect a GLSPClient to a GLSP server through a TCP socket, with the Content-Length framing of JSON-RPC (as vscode-jsonrpc and the Eclipse GLSP servers).

A reader process passes each message of the server to the client. When the server closes the connection, the pending requests of the client fail.
"
Class {
	#name : 'GLSPSocketConnection',
	#superclass : 'GLSPClientConnection',
	#instVars : [
		'host',
		'port',
		'transport',
		'reader',
		'writeMutex'
	],
	#category : 'GLSP-Client-Connection',
	#package : 'GLSP-Client',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
GLSPSocketConnection class >> host: aHostName port: aPortNumber [

	^ self new
		  setHost: aHostName port: aPortNumber;
		  yourself
]

{ #category : 'connection' }
GLSPSocketConnection >> close [
	"Closing the transport ends the reader process"

	transport ifNotNil: [ :each | each close ]
]

{ #category : 'connection' }
GLSPSocketConnection >> deliver: aJSONString [
	"An error while handling one message must not stop the reading of the next ones"

	[ client receive: aJSONString ]
		on: Error
		do: [ :e | client receiveFailed: e on: aJSONString ]
]

{ #category : 'connection' }
GLSPSocketConnection >> host [

	^ host
]

{ #category : 'connection' }
GLSPSocketConnection >> isConnected [

	^ reader isNotNil
]

{ #category : 'connection' }
GLSPSocketConnection >> open [
	"Connect to the server and start reading its messages. Signal a GLSPClientError if the server cannot be reached"

	| stream |
	stream := [ SocketStream openConnectionToHostNamed: host port: port ]
		on: NetworkError
		do: [ :e | GLSPClientError signal: ('Cannot connect to the GLSP server on {1}:{2}' format: { host. port }) ].
	stream binary.
	transport := GLSPStreamTransport in: stream out: stream.
	transport waitForever: true.
	reader := [ self readLoop ]
		forkAt: Processor lowIOPriority
		named: ('GLSP client reader {1}:{2}' format: { host. port })
]

{ #category : 'connection' }
GLSPSocketConnection >> port [

	^ port
]

{ #category : 'connection' }
GLSPSocketConnection >> readLoop [
	"Pass each message of the server to the client, until the connection is closed"

	[
		| message |
		[ (message := transport next) isNotNil ] whileTrue: [ self deliver: message ] ] ensure: [
			reader := nil.
			transport close.
			client connectionClosed ]
]

{ #category : 'connection' }
GLSPSocketConnection >> send: aJSONString [

	transport ifNil: [ GLSPClientError signal: 'Not connected to the GLSP server' ].
	[ writeMutex critical: [ transport send: aJSONString ] ]
		on: NetworkError , PrimitiveFailed
		do: [ :e | GLSPClientError signal: 'Connection to the GLSP server lost' ]
]

{ #category : 'connection' }
GLSPSocketConnection >> setHost: aHostName port: aPortNumber [

	host := aHostName.
	port := aPortNumber.
	writeMutex := Mutex new
]
