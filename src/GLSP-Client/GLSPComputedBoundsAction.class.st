"
The answer to a GLSPRequestBoundsAction: the bounds computed by the client, as a collection of JSON objects {elementId, newSize: {width, height}, newPosition: {x, y}}.
"
Class {
	#name : 'GLSPComputedBoundsAction',
	#superclass : 'GLSPAction',
	#instVars : [
		'responseId',
		'bounds',
		'revision'
	],
	#category : 'GLSP-Client-Actions',
	#package : 'GLSP-Client',
	#tag : 'Actions'
}

{ #category : 'accessing' }
GLSPComputedBoundsAction class >> kind [

	^ 'computedBounds'
]

{ #category : 'accessing' }
GLSPComputedBoundsAction >> bounds [

	^ bounds
]

{ #category : 'accessing' }
GLSPComputedBoundsAction >> bounds: aCollection [

	bounds := aCollection
]

{ #category : 'accessing' }
GLSPComputedBoundsAction >> isResponse [

	^ true
]

{ #category : 'accessing' }
GLSPComputedBoundsAction >> isResponseAction [

	^ true
]

{ #category : 'accessing' }
GLSPComputedBoundsAction >> responseId [

	^ responseId
]

{ #category : 'accessing' }
GLSPComputedBoundsAction >> responseId: aString [

	responseId := aString
]

{ #category : 'accessing' }
GLSPComputedBoundsAction >> revision [

	^ revision
]

{ #category : 'accessing' }
GLSPComputedBoundsAction >> revision: anInteger [

	revision := anInteger
]
