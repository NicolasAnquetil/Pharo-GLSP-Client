"
I record the messages a client sends, without server: tests check what the client answers to the actions they give it.
"
Class {
	#name : 'GLSPRecordingClientConnection',
	#superclass : 'GLSPClientConnection',
	#instVars : [
		'messages'
	],
	#category : 'GLSP-Client-Tests',
	#package : 'GLSP-Client-Tests'
}

{ #category : 'connection' }
GLSPRecordingClientConnection >> initialize [

	super initialize.
	messages := OrderedCollection new
]

{ #category : 'connection' }
GLSPRecordingClientConnection >> messages [

	^ messages
]

{ #category : 'connection' }
GLSPRecordingClientConnection >> send: aJSONString [

	messages add: (STONJSON fromString: aJSONString)
]

{ #category : 'connection' }
GLSPRecordingClientConnection >> sentActions [
	"The JSON of the actions sent to the server"

	^ (messages select: [ :each | (each at: 'method' ifAbsent: [ nil ]) = 'process' ]) collect: [ :each |
		  (each at: 'params') at: 'action' ]
]
