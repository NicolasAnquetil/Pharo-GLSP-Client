"
I connect a GLSP client to a GLSP server running in the same image, without any socket: messages are handed over directly (synchronously).
"
Class {
	#name : 'GLSPLoopbackConnection',
	#superclass : 'GLSPClientConnection',
	#instVars : [
		'server'
	],
	#category : 'GLSP-Client-Connection',
	#package : 'GLSP-Client',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
GLSPLoopbackConnection class >> server: aGLSPServer [

	^ self new
		  setServer: aGLSPServer;
		  yourself
]

{ #category : 'connection' }
GLSPLoopbackConnection >> send: aJSONString [

	server handleMessage: aJSONString
]

{ #category : 'connection' }
GLSPLoopbackConnection >> server [

	^ server
]

{ #category : 'connection' }
GLSPLoopbackConnection >> setServer: aGLSPServer [

	server := aGLSPServer.
	server transport: (GLSPCallbackTransport block: [ :message | client receive: message ])
]
