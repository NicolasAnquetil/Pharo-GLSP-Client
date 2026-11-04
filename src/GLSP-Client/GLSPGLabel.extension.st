Extension { #name : 'GLSPGLabel' }

{ #category : '*GLSP-Client' }
GLSPGLabel >> readPropertiesFrom: aDictionary [

	super readPropertiesFrom: aDictionary.
	text := aDictionary at: 'text' ifAbsent: [ nil ]
]
