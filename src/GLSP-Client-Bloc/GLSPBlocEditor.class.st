"
I am a diagram editor for a GLSPClientDiagram: a tool palette on the left and the diagram on the right.

Open me in a window with GLSPBlocEditor openOn: aClientDiagram. Closing the window closes the client session of the diagram.
"
Class {
	#name : 'GLSPBlocEditor',
	#superclass : 'BlElement',
	#traits : 'GLSPTBlocUIProcess',
	#classTraits : 'GLSPTBlocUIProcess classTrait',
	#instVars : [
		'diagram',
		'palette',
		'diagramElement',
		'closeActions'
	],
	#category : 'GLSP-Client-Bloc-Editor',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Editor'
}

{ #category : 'examples' }
GLSPBlocEditor class >> exampleTaskList [
	"Open an editor on a TaskList model served by a GLSP server of this image"

	<example>
	| server client diagram |
	server := GLSPServer new
		          registerDiagramModule: GLSPTaskListDiagramModule new;
		          yourself.
	client := GLSPClient loopbackOn: server.
	diagram := client openDiagram: 'tasklist-diagram'.
	diagram requestModel: self exampleTaskListFile asZnUrl printString.
	^ self openOn: diagram
]

{ #category : 'examples' }
GLSPBlocEditor class >> exampleTaskListFile [
	"A sample TaskList model, created in the temporary directory if needed"

	| file |
	file := (FileLocator temp / 'glsp-example.tasklist') asFileReference.
	file exists ifFalse: [
			file writeStreamDo: [ :stream |
					stream nextPutAll:
						'{"id":"tasklist","tasks":[{"id":"task1","name":"Push","position":{"x":40,"y":40}},{"id":"task2","name":"Pull","position":{"x":300,"y":40}},{"id":"task3","name":"Review","position":{"x":170,"y":180}}],"transitions":[{"id":"t1","sourceTaskId":"task1","targetTaskId":"task2"},{"id":"t2","sourceTaskId":"task2","targetTaskId":"task3"},{"id":"t3","sourceTaskId":"task3","targetTaskId":"task1"}]}' ] ].
	^ file
]

{ #category : 'opening' }
GLSPBlocEditor class >> on: aClientDiagram [

	^ self new
		  setDiagram: aClientDiagram;
		  yourself
]

{ #category : 'opening' }
GLSPBlocEditor class >> openEditor: anEditor host: aBlHostOrNil [

	| space |
	space := BlSpace new.
	aBlHostOrNil ifNotNil: [ space host: aBlHostOrNil ].
	space
		title: anEditor title;
		extent: 900 @ 600.
	space root addChild: anEditor.
	space addEventHandlerOn: BlSpaceClosedEvent do: [ :event | anEditor windowClosed ].
	space show.
	^ space
]

{ #category : 'opening' }
GLSPBlocEditor class >> openOn: aClientDiagram [
	"Open an editor on aClientDiagram in a new window"

	^ self openOn: aClientDiagram host: nil
]

{ #category : 'opening' }
GLSPBlocEditor class >> openOn: aClientDiagram host: aBlHostOrNil [
	"Open an editor on aClientDiagram in a new space of aBlHostOrNil (nil: the default host). Answer the space"

	^ self openEditor: (self on: aClientDiagram) host: aBlHostOrNil
]

{ #category : 'client' }
GLSPBlocEditor >> closeDiagram [
	"Stop following the diagram and close its client session"

	| closing |
	diagram ifNil: [ ^ self ].
	closing := diagram.
	diagram := nil.
	closing announcer unsubscribe: self.
	palette diagram: nil.
	diagramElement diagram: nil.
	closing close
]

{ #category : 'accessing' }
GLSPBlocEditor >> diagram [

	^ diagram
]

{ #category : 'client' }
GLSPBlocEditor >> diagramChanged: aClientDiagramChanged [

	aClientDiagramChanged action kind = 'setDirtyState' ifTrue: [ self applyInUIProcess: [ self updateTitle ] ]
]

{ #category : 'accessing' }
GLSPBlocEditor >> diagramElement [

	^ diagramElement
]

{ #category : 'initialization' }
GLSPBlocEditor >> initialize [

	super initialize.
	palette := GLSPBlocPaletteElement new.
	diagramElement := GLSPBlocDiagramElement new.
	diagramElement constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
	self
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ];
		addChild: palette;
		addChild: diagramElement
]

{ #category : 'accessing' }
GLSPBlocEditor >> palette [

	^ palette
]

{ #category : 'client' }
GLSPBlocEditor >> reportFailuresOf: aBlock [

	aBlock
		on: Error
		do: [ :error |
				Transcript crShow: 'GLSP editor closing: ' , error description.
				error return: nil ]
]

{ #category : 'accessing' }
GLSPBlocEditor >> setDiagram: aClientDiagram [

	diagram := aClientDiagram.
	diagram announcer when: GLSPClientDiagramChanged send: #diagramChanged: to: self.
	palette diagram: diagram.
	diagramElement diagram: diagram.
	diagram paletteItems ifEmpty: [ diagram requestToolPalette ].
	diagram shapeHints ifEmpty: [ diagram requestTypeHints ]
]

{ #category : 'accessing' }
GLSPBlocEditor >> title [
	"The name of the model, with a star when it has unsaved changes"

	| name |
	name := diagram sourceUri ifNil: [ diagram diagramType ] ifNotNil: [ :uri | uri asZnUrl asFileReference basename ].
	^ diagram isDirty
		  ifTrue: [ '*' , name ]
		  ifFalse: [ name ]
]

{ #category : 'client' }
GLSPBlocEditor >> updateTitle [

	self isAttachedToSceneGraph ifTrue: [ self space title: self title ]
]

{ #category : 'client' }
GLSPBlocEditor >> whenClosedDo: aBlock [
	"Evaluate aBlock when my window is closed, after my diagram is closed (e.g. to close the connection to the server)"

	closeActions := (closeActions ifNil: [ #(  ) ]) copyWith: aBlock
]

{ #category : 'client' }
GLSPBlocEditor >> windowClosed [
	"My window is closed: close my diagram, then run my close actions. Closing a window must not fail, even when the server is gone: failures are only reported on the Transcript"

	self reportFailuresOf: [ self closeDiagram ].
	(closeActions ifNil: [ #(  ) ]) do: [ :each | self reportFailuresOf: each ]
]
