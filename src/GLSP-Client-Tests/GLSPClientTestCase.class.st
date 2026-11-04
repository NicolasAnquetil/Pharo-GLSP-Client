"
I am the abstract superclass of the tests of GLSP clients: a TaskList server of the image with a .tasklist file in the temporary directory, and a client connected to it through a loopback connection.
"
Class {
	#name : 'GLSPClientTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'server',
		'client',
		'file'
	],
	#category : 'GLSP-Client-Tests',
	#package : 'GLSP-Client-Tests'
}

{ #category : 'testing' }
GLSPClientTestCase class >> isAbstract [
	^ self = GLSPClientTestCase
]

{ #category : 'running' }
GLSPClientTestCase >> newClient [
	"A client connected to my server"

	^ GLSPClient loopbackOn: server
]

{ #category : 'running' }
GLSPClientTestCase >> openModel [

	| diagram |
	diagram := client openDiagram: 'tasklist-diagram'.
	diagram requestModel: file asZnUrl printString.
	^ diagram
]

{ #category : 'running' }
GLSPClientTestCase >> setUp [

	super setUp.
	file := FileReference newTempFilePrefix: 'glsp-client-' suffix: '.tasklist'.
	file writeStreamDo: [ :stream |
			stream nextPutAll:
				'{"id":"tasklist","tasks":[{"id":"task1","name":"Push","position":{"x":10,"y":20}},{"id":"task2","name":"Pull","position":{"x":200,"y":20}}],"transitions":[{"id":"transition1","sourceTaskId":"task1","targetTaskId":"task2"}]}' ].
	server := GLSPServer new
		          registerDiagramModule: GLSPTaskListDiagramModule new;
		          yourself.
	client := self newClient
]

{ #category : 'running' }
GLSPClientTestCase >> tearDown [

	file ifNotNil: [ file ensureDelete ].
	super tearDown
]

{ #category : 'running' }
GLSPClientTestCase >> waitUntil: aBlock [

	| deadline |
	deadline := DateAndTime now + 5 seconds.
	[ aBlock value or: [ DateAndTime now > deadline ] ] whileFalse: [ 20 milliSeconds wait ]
]
