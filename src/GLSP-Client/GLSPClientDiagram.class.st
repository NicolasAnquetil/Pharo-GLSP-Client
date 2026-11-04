"
I am a diagram open in a GLSP client: the client side of a client session. I keep the GModel last received (setModel / updateModel), the dirty state, the type hints and the tool palette, and I announce my changes (GLSPClientDiagramChanged) so that views can follow them.

I send actions to the server with #dispatch:, and offer shortcuts for the usual ones (#requestModel:, #undo, #redo, #save...).
"
Class {
	#name : 'GLSPClientDiagram',
	#superclass : 'Object',
	#instVars : [
		'client',
		'id',
		'diagramType',
		'root',
		'dirty',
		'shapeHints',
		'edgeHints',
		'paletteItems',
		'announcer',
		'sourceUri',
		'boundsComputer'
	],
	#category : 'GLSP-Client-Core',
	#package : 'GLSP-Client',
	#tag : 'Core'
}

{ #category : 'accessing' }
GLSPClientDiagram class >> client: aGLSPClient id: aString diagramType: aDiagramType [

	^ self new
		  setClient: aGLSPClient id: aString diagramType: aDiagramType;
		  yourself
]

{ #category : 'accessing' }
GLSPClientDiagram class >> clientActionKinds [
	"The action kinds handled by the client, announced to the server. A server does not send the other kinds"

	^ #('setModel' 'updateModel' 'setDirtyState' 'setTypeHints' 'setContextActions' 'requestBounds' 'status' 'message')
]

{ #category : 'accessing' }
GLSPClientDiagram >> announcer [

	^ announcer
]

{ #category : 'handling' }
GLSPClientDiagram >> answerRequestBounds: aRequestBoundsAction [
	"Lay out the model of the server and answer its bounds. The model is not displayed: the server sends it next, with the bounds"

	| model |
	model := GLSPGModelElement fromJSON: aRequestBoundsAction newRoot.
	self dispatch: (GLSPComputedBoundsAction new
		responseId: aRequestBoundsAction requestId;
		revision: model revision;
		bounds: (self boundsComputer boundsOf: model);
		yourself)
]

{ #category : 'accessing' }
GLSPClientDiagram >> boundsComputer [
	"Computes the bounds asked by the server (requestBounds) when it needs the client to lay out the model"

	^ boundsComputer ifNil: [ boundsComputer := GLSPGModelBoundsComputer new ]
]

{ #category : 'accessing' }
GLSPClientDiagram >> boundsComputer: aBoundsComputer [
	boundsComputer := aBoundsComputer
]

{ #category : 'accessing' }
GLSPClientDiagram >> client [

	^ client
]

{ #category : 'actions' }
GLSPClientDiagram >> close [

	client closeDiagram: self
]

{ #category : 'accessing' }
GLSPClientDiagram >> diagramType [

	^ diagramType
]

{ #category : 'actions' }
GLSPClientDiagram >> dispatch: anAction [
	"Send anAction to the server"

	client sendAction: anAction to: self
]

{ #category : 'actions' }
GLSPClientDiagram >> dispatch: anAction andWaitFor: anActionKind [
	"Dispatch anAction (e.g. an operation) and answer the next action of anActionKind sent by the server (e.g. 'setDirtyState')"

	^ self waitForActionSuchThat: [ :action | action kind = anActionKind ] during: [ self dispatch: anAction ]
]

{ #category : 'accessing' }
GLSPClientDiagram >> edgeHints [

	^ edgeHints
]

{ #category : 'handling' }
GLSPClientDiagram >> handleAction: anAction [
	"An action received from the server"

	| kind |
	kind := anAction kind.
	(#( 'setModel' 'updateModel' ) includes: kind) ifTrue: [ root := GLSPGModelElement fromJSON: anAction newRoot ].
	kind = 'setDirtyState' ifTrue: [ dirty := anAction isDirty ].
	kind = 'setTypeHints' ifTrue: [
		shapeHints := anAction shapeHints ifNil: [ #(  ) ].
		edgeHints := anAction edgeHints ifNil: [ #(  ) ] ].
	kind = 'setContextActions' ifTrue: [ paletteItems := anAction actions ifNil: [ #(  ) ] ].
	kind = 'requestBounds' ifTrue: [ self answerRequestBounds: anAction ].
	announcer announce: (GLSPClientDiagramChanged new
		setDiagram: self action: anAction;
		yourself)
]

{ #category : 'accessing' }
GLSPClientDiagram >> id [

	^ id
]

{ #category : 'initialization' }
GLSPClientDiagram >> initialize [

	super initialize.
	dirty := false.
	shapeHints := #(  ).
	edgeHints := #(  ).
	paletteItems := #(  ).
	announcer := Announcer new
]

{ #category : 'accessing' }
GLSPClientDiagram >> isDirty [

	^ dirty
]

{ #category : 'actions' }
GLSPClientDiagram >> newRequestId [

	^ 'request-' , UUID new asString
]

{ #category : 'accessing' }
GLSPClientDiagram >> paletteItems [

	^ paletteItems
]

{ #category : 'actions' }
GLSPClientDiagram >> redo [

	self dispatch: GLSPRedoAction new
]

{ #category : 'actions' }
GLSPClientDiagram >> request: aRequestAction [
	"Dispatch aRequestAction and answer the response of the server (the action with the same responseId)"

	| requestId |
	requestId := aRequestAction requestId ifNil: [
			             aRequestAction
				             requestId: self newRequestId;
				             requestId ].
	^ self
		  waitForActionSuchThat: [ :action | (action respondsTo: #responseId) and: [ action responseId = requestId ] ]
		  during: [ self dispatch: aRequestAction ]
]

{ #category : 'actions' }
GLSPClientDiagram >> requestModel: anUri [
	"Ask the server for the model of anUri and wait for it"

	sourceUri := anUri.
	^ self request: (GLSPRequestModelAction new
			   options: (Dictionary new
					    at: 'sourceUri' put: anUri;
					    at: 'diagramType' put: diagramType;
					    yourself);
			   yourself)
]

{ #category : 'actions' }
GLSPClientDiagram >> requestToolPalette [

	^ self request: (GLSPRequestContextActions new
			   contextId: 'tool-palette';
			   editorContext: (Dictionary new
					    at: 'selectedElementIds' put: #(  );
					    yourself);
			   yourself)
]

{ #category : 'actions' }
GLSPClientDiagram >> requestTypeHints [

	^ self request: GLSPRequestTypeHintsAction new
]

{ #category : 'accessing' }
GLSPClientDiagram >> root [
	"The current GModel (a GLSPGModelRoot), nil before the first setModel"

	^ root
]

{ #category : 'actions' }
GLSPClientDiagram >> save [

	self dispatch: GLSPSaveModelAction new
]

{ #category : 'initialization' }
GLSPClientDiagram >> setClient: aGLSPClient id: aString diagramType: aDiagramType [

	client := aGLSPClient.
	id := aString.
	diagramType := aDiagramType
]

{ #category : 'accessing' }
GLSPClientDiagram >> shapeHints [

	^ shapeHints
]

{ #category : 'accessing' }
GLSPClientDiagram >> sourceUri [

	^ sourceUri
]

{ #category : 'actions' }
GLSPClientDiagram >> undo [

	self dispatch: GLSPUndoAction new
]

{ #category : 'actions' }
GLSPClientDiagram >> waitForActionSuchThat: aBlock during: anActionBlock [
	"Evaluate anActionBlock, then wait until an action received from the server satisfies aBlock and answer it. Signal a GLSPClientError after the timeout of the client"

	| received semaphore subscription |
	semaphore := Semaphore new.
	subscription := announcer
		                when: GLSPClientDiagramChanged
		                do: [ :announcement |
				                (received isNil and: [ aBlock value: announcement action ]) ifTrue: [
						                received := announcement action.
						                semaphore signal ] ]
		                for: self.
	[
		anActionBlock value.
		(semaphore waitTimeoutSeconds: client timeout) ifTrue: [ GLSPClientError signal: 'No answer from the GLSP server' ] ] ensure: [
		announcer removeSubscription: subscription ].
	^ received
]
