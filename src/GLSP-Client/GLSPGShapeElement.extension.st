Extension { #name : 'GLSPGShapeElement' }

{ #category : '*GLSP-Client' }
GLSPGShapeElement >> isShape [
	^ true
]

{ #category : '*GLSP-Client' }
GLSPGShapeElement >> readPropertiesFrom: aDictionary [

	position := GLSPAction pointFromJSON: (aDictionary at: 'position' ifAbsent: [ nil ]).
	size := GLSPAction dimensionFromJSON: (aDictionary at: 'size' ifAbsent: [ nil ]).
	layout := aDictionary at: 'layout' ifAbsent: [ nil ]
]
