"
I compute the bounds asked by a requestBounds of the server from the GModel itself: the size and position of each shape, when the GModel has them. Rendering clients use computers that measure their views instead.
"
Class {
	#name : 'GLSPGModelBoundsComputer',
	#superclass : 'Object',
	#category : 'GLSP-Client-Core',
	#package : 'GLSP-Client',
	#tag : 'Core'
}

{ #category : 'computing' }
GLSPGModelBoundsComputer >> addBoundsOf: aGModelElement to: aCollection [

	(self sizeOf: aGModelElement) ifNotNil: [ :size | aCollection add: (self boundsJSONOf: aGModelElement size: size) ].
	aGModelElement children do: [ :each | self addBoundsOf: each to: aCollection ]
]

{ #category : 'computing' }
GLSPGModelBoundsComputer >> boundsJSONOf: aGModelElement size: aPoint [

	| json |
	json := Dictionary new.
	json at: 'elementId' put: aGModelElement id.
	json at: 'newSize' put: aPoint asGLSPDimensionJSON.
	(self positionOf: aGModelElement) ifNotNil: [ :position | json at: 'newPosition' put: position asGLSPPointJSON ].
	^ json
]

{ #category : 'computing' }
GLSPGModelBoundsComputer >> boundsOf: aGModelRoot [
	"The bounds of the shapes of aGModelRoot, as JSON objects {elementId, newSize, newPosition}"

	| result |
	result := OrderedCollection new.
	aGModelRoot children do: [ :each | self addBoundsOf: each to: result ].
	^ result asArray
]

{ #category : 'computing' }
GLSPGModelBoundsComputer >> positionOf: aGModelElement [

	^ aGModelElement position
]

{ #category : 'computing' }
GLSPGModelBoundsComputer >> sizeOf: aGModelElement [
	"The size of aGModelElement, nil when it has none. Subclasses measure the elements"

	aGModelElement isShape ifFalse: [ ^ nil ].
	^ aGModelElement size
]
