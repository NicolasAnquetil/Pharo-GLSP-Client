"
I test the client against the Workflow example server of Eclipse GLSP (Java), a third-party GLSP server. I am skipped when no server listens on my port (5007 by default).

Start the server with interop/start-workflow-server.sh, or:
	java -jar org.eclipse.glsp.example.workflow-2.8.0-glsp.jar --port 5007

I work on a copy of a sample workflow model (example1.wf from the Eclipse GLSP examples) in the temporary directory.
"
Class {
	#name : 'GLSPEclipseWorkflowServerTest',
	#superclass : 'TestCase',
	#instVars : [
		'client',
		'diagram',
		'file'
	],
	#category : 'GLSP-Client-Tests',
	#package : 'GLSP-Client-Tests'
}

{ #category : 'accessing' }
GLSPEclipseWorkflowServerTest class >> port [
	"The port of the Eclipse GLSP Workflow server"

	^ 5007
]

{ #category : 'accessing' }
GLSPEclipseWorkflowServerTest class >> sampleModel [
	"An extract of example1.wf of the Eclipse GLSP examples: Push (manual task) -> fork -> ChkTp (automated task)"

	^ '{"cssClasses":[],"type":"graph","position":{"x":0,"y":0},"id":"sprotty","revision":1,"children":[{"cssClasses":["task","manual"],"type":"task:manual","id":"task_Push","layout":"hbox","args":{"radiusTopLeft":5,"radiusBottomLeft":5,"radiusBottomRight":5,"radiusTopRight":5},"position":{"x":70,"y":100},"name":"Push","taskType":"manual","layoutOptions":{"paddingRight":10,"prefWidth":72.921875,"prefHeight":30},"size":{"width":72.921875,"height":30},"children":[{"cssClasses":[],"type":"icon","id":"task_Push_icon","position":{"x":5,"y":5},"size":{"width":25,"height":20},"children":[]},{"cssClasses":[],"type":"label:heading","alignment":{"x":15.9609375,"y":13},"id":"task_Push_label","text":"Push","position":{"x":31,"y":7},"size":{"width":31.921875,"height":16},"children":[]}]},{"cssClasses":["forkOrJoin"],"type":"activityNode:fork","id":"fork_1","position":{"x":170,"y":90},"nodeType":"forkNode","size":{"width":10,"height":50},"children":[]},{"cssClasses":["task","automated"],"type":"task:automated","id":"task_ChkTp","layout":"hbox","args":{"radiusTopLeft":5,"radiusBottomLeft":5,"radiusBottomRight":5,"radiusTopRight":5},"position":{"x":220,"y":150},"name":"ChkTp","taskType":"automated","layoutOptions":{"paddingRight":10,"prefWidth":82.4482421875,"prefHeight":30},"size":{"width":82.4482421875,"height":30},"children":[{"cssClasses":[],"type":"icon","id":"task_ChkTp_icon","position":{"x":5,"y":5},"size":{"width":25,"height":20},"children":[]},{"cssClasses":[],"type":"label:heading","alignment":{"x":20.6171875,"y":13},"id":"task_ChkTp_label","text":"ChkTp","position":{"x":31,"y":7},"size":{"width":41.4482421875,"height":16},"children":[]}]},{"cssClasses":[],"type":"edge","routingPoints":[],"id":"edge_task_Push_fork_1","sourceId":"task_Push","targetId":"fork_1","children":[]},{"cssClasses":[],"type":"edge","routingPoints":[],"id":"edge_fork1_task_ChkTp","sourceId":"fork_1","targetId":"task_ChkTp","children":[]}]}'
]

{ #category : 'tests' }
GLSPEclipseWorkflowServerTest >> openModel [

	diagram := client openDiagram: 'workflow-diagram'.
	diagram requestModel: file asZnUrl printString.
	^ diagram
]

{ #category : 'running' }
GLSPEclipseWorkflowServerTest >> setUp [

	super setUp.
	client := [ GLSPClient host: 'localhost' port: self class port ]
		          on: GLSPClientError
		          do: [ :e | ^ self skip: 'No Eclipse GLSP Workflow server on port ' , self class port printString ].
	file := FileReference newTempFilePrefix: 'glsp-workflow-' suffix: '.wf'.
	file writeStreamDo: [ :stream | stream nextPutAll: self class sampleModel ]
]

{ #category : 'running' }
GLSPEclipseWorkflowServerTest >> tearDown [

	diagram ifNotNil: [
			[ diagram close ]
				on: GLSPClientError
				do: [ :e | e return: nil ] ].
	client ifNotNil: [ client connection close ].
	file ifNotNil: [ file ensureDelete ].
	super tearDown
]

{ #category : 'tests' }
GLSPEclipseWorkflowServerTest >> testCreateATaskMakesTheModelDirty [

	| count |
	self openModel.
	count := diagram root children size.
	diagram
		dispatch: (GLSPCreateNodeOperation new
				 elementTypeId: 'task:manual';
				 location: 300 @ 300;
				 yourself)
		andWaitFor: 'setDirtyState'.
	self assert: diagram isDirty.
	self waitUntil: [ diagram root children size = (count + 1) ].
	self assert: diagram root children size equals: count + 1
]

{ #category : 'tests' }
GLSPEclipseWorkflowServerTest >> testInitialize [

	| result |
	result := client initializeServer.
	self assert: (result at: 'protocolVersion') equals: '1.0.0'.
	self assert: ((client serverActionsFor: 'workflow-diagram') includes: 'requestModel')
]

{ #category : 'tests' }
GLSPEclipseWorkflowServerTest >> testRequestModel [
	self openModel.
	self assert: diagram root class equals: GLSPGModelRoot.
	self
		assert: (diagram root children collect: [ :each | each id ] as: Set)
		equals: #( 'task_Push' 'fork_1' 'task_ChkTp' 'edge_task_Push_fork_1' 'edge_fork1_task_ChkTp' ) asSet.
	self assert: (diagram root elementAt: 'task_Push_label') text equals: 'Push'.
	self assert: (diagram root elementAt: 'edge_fork1_task_ChkTp') class equals: GLSPGEdge
]

{ #category : 'tests' }
GLSPEclipseWorkflowServerTest >> testTypeHintsAndToolPalette [

	self openModel.
	diagram requestTypeHints.
	self assert: ((diagram shapeHints collect: [ :each | each at: 'elementTypeId' ]) includes: 'task:manual').
	diagram requestToolPalette.
	self assert: diagram paletteItems isNotEmpty
]

{ #category : 'tests' }
GLSPEclipseWorkflowServerTest >> testUndoAndSave [

	| count |
	self openModel.
	count := diagram root children size.
	diagram
		dispatch: (GLSPDeleteElementOperation new
				 elementIds: #( 'task_ChkTp' );
				 yourself)
		andWaitFor: 'setDirtyState'.
	self waitUntil: [ (diagram root elementAt: 'task_ChkTp') isNil ].
	self assert: (diagram root elementAt: 'task_ChkTp') isNil.
	diagram dispatch: GLSPUndoAction new andWaitFor: 'setDirtyState'.
	self waitUntil: [ (diagram root elementAt: 'task_ChkTp') isNotNil ].
	self assert: (diagram root elementAt: 'task_ChkTp') isNotNil.
	diagram dispatch: GLSPSaveModelAction new andWaitFor: 'setDirtyState'.
	self deny: diagram isDirty
]

{ #category : 'tests' }
GLSPEclipseWorkflowServerTest >> waitUntil: aBlock [

	| deadline |
	deadline := DateAndTime now + 5 seconds.
	[ aBlock value or: [ DateAndTime now > deadline ] ] whileFalse: [ 20 milliSeconds wait ]
]
