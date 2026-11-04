"
I am a server transport evaluating a block with each message the server sends (used by GLSPLoopbackConnection to hand the messages to the client).
"
Class {
	#name : 'GLSPCallbackTransport',
	#superclass : 'GLSPTransport',
	#instVars : [
		'block'
	],
	#category : 'GLSP-Client-Connection',
	#package : 'GLSP-Client',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
GLSPCallbackTransport class >> block: aBlock [

	^ self new
		  setBlock: aBlock;
		  yourself
]

{ #category : 'sending' }
GLSPCallbackTransport >> send: aJSONString [

	block value: aJSONString
]

{ #category : 'sending' }
GLSPCallbackTransport >> setBlock: aBlock [

	block := aBlock
]
