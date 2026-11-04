"
Sent by a server that needs the client to compute the layout (e.g. the Eclipse GLSP Workflow example): the client answers the bounds of the elements of newRoot with a GLSPComputedBoundsAction, before the server sends the model.
"
Class {
	#name : 'GLSPRequestBoundsAction',
	#superclass : 'GLSPRequestAction',
	#instVars : [
		'newRoot'
	],
	#category : 'GLSP-Client-Actions',
	#package : 'GLSP-Client',
	#tag : 'Actions'
}

{ #category : 'accessing' }
GLSPRequestBoundsAction class >> kind [

	^ 'requestBounds'
]

{ #category : 'accessing' }
GLSPRequestBoundsAction >> newRoot [
	"The model to lay out (JSON)"

	^ newRoot
]

{ #category : 'accessing' }
GLSPRequestBoundsAction >> newRoot: aDictionary [

	newRoot := aDictionary
]
