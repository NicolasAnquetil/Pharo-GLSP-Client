Extension { #name : 'GLSPBlocEditor' }

{ #category : '*GLSP-Client-Workflow' }
GLSPBlocEditor class >> exampleWorkflow [
	"Open an editor on a workflow model served by the Workflow example server of Eclipse GLSP (Java), listening on port 5007.
	Start it first with interop/start-workflow-server.sh"

	<example>
	^ self openWorkflow: self exampleWorkflowFile host: 'localhost' port: 5007
]

{ #category : '*GLSP-Client-Workflow' }
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

{ #category : '*GLSP-Client-Workflow' }
GLSPBlocEditor class >> openWorkflow: aFileReference host: aHostName port: aPortNumber [
	"Open an editor on the workflow model aFileReference (.wf), served by an Eclipse GLSP Workflow server, with the Workflow views.
	The editor follows the diagram before the model is asked, to measure the bounds the server asks for. Closing the window closes the connection"

	| client diagram editor |
	client := GLSPClient host: aHostName port: aPortNumber.
	diagram := client openDiagram: 'workflow-diagram'.
	editor := self on: diagram.
	GLSPWorkflowViews registerOn: editor diagramElement registry.
	editor whenClosedDo: [ client connection close ].
	diagram requestModel: aFileReference asFileReference asZnUrl printString.
	^ self openEditor: editor host: nil
]
