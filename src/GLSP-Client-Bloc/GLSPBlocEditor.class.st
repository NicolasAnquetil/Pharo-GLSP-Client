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

{ #category : 'examples' }
GLSPBlocEditor class >> exampleWorkflow [
	"Open an editor on a workflow model served by the Workflow example server of Eclipse GLSP (Java), listening on port 5007.
	Start it first with interop/start-workflow-server.sh"

	<example>
	^ self openWorkflow: self exampleWorkflowFile host: 'localhost' port: 5007
]

{ #category : 'examples' }
GLSPBlocEditor class >> exampleWorkflowFile [
	"A sample workflow model, created in the temporary directory if needed: an extract of example1.wf of the Eclipse GLSP examples"

	| file |
	file := (FileLocator temp / 'glsp-example.wf') asFileReference.
	file exists ifFalse: [
			file writeStreamDo: [ :stream |
					stream nextPutAll:
						'{"type":"graph","id":"sprotty","revision":1,"position":{"x":0,"y":0},"cssClasses":[],"children":[{"cssClasses":["task","manual"],"type":"task:manual","id":"task_Push","layout":"hbox","args":{"radiusTopLeft":5,"radiusBottomLeft":5,"radiusBottomRight":5,"radiusTopRight":5},"position":{"x":70,"y":100},"name":"Push","taskType":"manual","layoutOptions":{"paddingRight":10,"prefWidth":72.921875,"prefHeight":30},"size":{"width":72.921875,"height":30},"children":[{"cssClasses":[],"type":"icon","id":"task_Push_icon","position":{"x":5,"y":5},"size":{"width":25,"height":20},"children":[]},{"cssClasses":[],"type":"label:heading","alignment":{"x":15.9609375,"y":13},"id":"task_Push_label","text":"Push","position":{"x":31,"y":7},"size":{"width":31.921875,"height":16},"children":[]}]},{"cssClasses":["forkOrJoin"],"type":"activityNode:fork","id":"fork_1","position":{"x":170,"y":90},"nodeType":"forkNode","size":{"width":10,"height":50},"children":[]},{"cssClasses":["task","automated"],"type":"task:automated","id":"task_ChkTp","layout":"hbox","args":{"radiusTopLeft":5,"radiusBottomLeft":5,"radiusBottomRight":5,"radiusTopRight":5},"position":{"x":220,"y":150},"name":"ChkTp","taskType":"automated","layoutOptions":{"paddingRight":10,"prefWidth":82.4482421875,"prefHeight":30},"size":{"width":82.4482421875,"height":30},"children":[{"cssClasses":[],"type":"icon","id":"task_ChkTp_icon","position":{"x":5,"y":5},"size":{"width":25,"height":20},"children":[]},{"cssClasses":[],"type":"label:heading","alignment":{"x":20.6171875,"y":13},"id":"task_ChkTp_label","text":"ChkTp","position":{"x":31,"y":7},"size":{"width":41.4482421875,"height":16},"children":[]}]},{"cssClasses":[],"type":"edge","routingPoints":[],"id":"edge_task_Push_fork_1","sourceId":"task_Push","targetId":"fork_1","children":[]},{"cssClasses":[],"type":"edge","routingPoints":[],"id":"edge_fork1_task_ChkTp","sourceId":"fork_1","targetId":"task_ChkTp","children":[]}]}' ] ].
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

{ #category : 'opening' }
GLSPBlocEditor class >> openWorkflow: aFileReference host: aHostName port: aPortNumber [
	"Open an editor on the workflow model aFileReference (.wf), served by an Eclipse GLSP Workflow server. Closing the window closes the connection"

	| client diagram editor |
	client := GLSPClient host: aHostName port: aPortNumber.
	diagram := client openDiagram: 'workflow-diagram'.
	diagram requestModel: aFileReference asFileReference asZnUrl printString.
	editor := self on: diagram.
	editor whenClosedDo: [ client connection close ].
	^ self openEditor: editor host: nil
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
