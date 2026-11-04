"
Announced by a GLSPClientDiagram when an action received from the server changed it (new model, dirty state, type hints, palette...).
"
Class {
	#name : 'GLSPClientDiagramChanged',
	#superclass : 'Announcement',
	#instVars : [
		'diagram',
		'action'
	],
	#category : 'GLSP-Client-Core',
	#package : 'GLSP-Client',
	#tag : 'Core'
}

{ #category : 'accessing' }
GLSPClientDiagramChanged >> action [

	^ action
]

{ #category : 'accessing' }
GLSPClientDiagramChanged >> diagram [

	^ diagram
]

{ #category : 'accessing' }
GLSPClientDiagramChanged >> setDiagram: aClientDiagram action: anAction [

	diagram := aClientDiagram.
	action := anAction
]
