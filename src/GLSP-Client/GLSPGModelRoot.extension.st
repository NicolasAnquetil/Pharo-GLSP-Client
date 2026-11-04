Extension { #name : 'GLSPGModelRoot' }

{ #category : '*GLSP-Client' }
GLSPGModelRoot >> readPropertiesFrom: aDictionary [

	revision := aDictionary at: 'revision' ifAbsent: [ nil ]
]
