"
I connect a GLSP client to a server: #send: writes one JSON-RPC message to the server; the messages from the server are given to the client with #receive:.
"
Class {
	#name : 'GLSPClientConnection',
	#superclass : 'Object',
	#instVars : [
		'client'
	],
	#category : 'GLSP-Client-Connection',
	#package : 'GLSP-Client',
	#tag : 'Connection'
}

{ #category : 'connection' }
GLSPClientConnection >> client: aGLSPClient [

	client := aGLSPClient
]

{ #category : 'connection' }
GLSPClientConnection >> close [
	"Release the resources of the connection"

	
]

{ #category : 'connection' }
GLSPClientConnection >> send: aJSONString [
	"Write one JSON-RPC message to the server"

	self subclassResponsibility
]
