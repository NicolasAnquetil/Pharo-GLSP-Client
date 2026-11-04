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
		'sourceUri'
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
	"The action kinds handled by the client, announced to the server"

	^ #( 'setModel' 'updateModel' 'setDirtyState' 'setTypeHints' 'setContextActions' 'status' 'message' )
]

{ #category : 'accessing' }
GLSPClientDiagram >> announcer [

	^ announcer
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
GLSPClientDiagram >> requestModel: anUri [

	sourceUri := anUri.
	self dispatch: (GLSPRequestModelAction new
			 requestId: self newRequestId;
			 options: (Dictionary new
					  at: 'sourceUri' put: anUri;
					  at: 'diagramType' put: diagramType;
					  yourself);
			 yourself)
]

{ #category : 'actions' }
GLSPClientDiagram >> requestToolPalette [

	self dispatch: (GLSPRequestContextActions new
			 requestId: self newRequestId;
			 contextId: 'tool-palette';
			 editorContext: (Dictionary new
					  at: 'selectedElementIds' put: #(  );
					  yourself);
			 yourself)
]

{ #category : 'actions' }
GLSPClientDiagram >> requestTypeHints [

	self dispatch: (GLSPRequestTypeHintsAction new
			 requestId: self newRequestId;
			 yourself)
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
