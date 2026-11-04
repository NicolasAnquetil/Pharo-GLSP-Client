"
I test the GLSP editor window on a real TaskList server of the image. Spaces are shown on the headless Bloc host: no window appears, but the UI process of Bloc runs.
"
Class {
	#name : 'GLSPBlocEditorTest',
	#superclass : 'GLSPClientTestCase',
	#instVars : [
		'space'
	],
	#category : 'GLSP-Client-Bloc-Tests',
	#package : 'GLSP-Client-Bloc-Tests'
}

{ #category : 'tests' }
GLSPBlocEditorTest >> openEditor [
	"Open an editor on the model in a space of the headless host and wait until it is displayed"

	space := GLSPBlocEditor openOn: self openModel host: BlHeadlessHost default.
	space settle.
	^ space root children detect: [ :each | each isKindOf: GLSPBlocEditor ]
]

{ #category : 'running' }
GLSPBlocEditorTest >> tearDown [
	"Closing a space is asynchronous: wait for it, not to leave spaces of the tests open"

	space ifNotNil: [
			space isOpened ifTrue: [ space close ].
			self waitUntil: [ space isOpened not ] ].
	super tearDown
]

{ #category : 'tests' }
GLSPBlocEditorTest >> testCloseActionsRunAfterTheDiagramIsClosed [

	| editor diagram sessionsWhenRun |
	editor := self openEditor.
	diagram := editor diagram.
	editor whenClosedDo: [ sessionsWhenRun := server sessions size ].
	space close.
	self waitUntil: [ sessionsWhenRun notNil ].
	self assert: sessionsWhenRun equals: 0
]

{ #category : 'tests' }
GLSPBlocEditorTest >> testClosingTheWindowClosesTheDiagram [

	self openEditor.
	space close.
	self waitUntil: [ server sessions isEmpty ].
	self assert: server sessions isEmpty.
	self assert: client diagrams isEmpty
]

{ #category : 'tests' }
GLSPBlocEditorTest >> testClosingTheWindowWhenTheServerFailsDoesNotSignal [
	"The server does not answer any more: disposing the session fails, closing the window must not"

	| editor |
	editor := self openEditor.
	client setConnection: GLSPRecordingClientConnection new.
	client timeout: 0.1.
	editor windowClosed.
	self assert: editor diagram isNil.
	self assert: client diagrams isEmpty
]

{ #category : 'tests' }
GLSPBlocEditorTest >> testDirtyModelIsShownInTheTitle [

	| editor |
	editor := self openEditor.
	self deny: (space title beginsWith: '*').
	editor diagram dispatch: (GLSPCreateNodeOperation new
			 elementTypeId: 'task';
			 location: 300 @ 300;
			 yourself).
	space settle.
	self assert: (space title beginsWith: '*')
]

{ #category : 'tests' }
GLSPBlocEditorTest >> testEditorShowsTheDiagram [

	| editor |
	editor := self openEditor.
	self assert: (editor diagramElement viewAt: 'task1_label') text asString equals: 'Push'.
	self assert: (editor diagramElement viewAt: 'transition1') isEdgeView
]

{ #category : 'tests' }
GLSPBlocEditorTest >> testPaletteShowsTheToolPalette [

	| editor |
	editor := self openEditor.
	self assert: editor palette groupLabels equals: #( 'Nodes' 'Edges' ).
	self assert: (editor palette itemLabels includes: 'Task')
]

{ #category : 'tests' }
GLSPBlocEditorTest >> testServerUpdatesAreAppliedInTheUIProcess [

	| editor |
	editor := self openEditor.
	editor diagram dispatch: (GLSPCreateNodeOperation new
			 elementTypeId: 'task';
			 location: 300 @ 300;
			 yourself).
	space settle.
	self assert: (editor diagramElement views count: [ :each | each class = GLSPBlocNodeView ]) equals: 3
]

{ #category : 'tests' }
GLSPBlocEditorTest >> testTheWindowIsTitledAfterTheModel [

	self openEditor.
	self assert: (space title includesSubstring: file basename)
]
