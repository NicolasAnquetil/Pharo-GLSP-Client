Extension { #name : 'GLSPGEdge' }

{ #category : '*GLSP-Client' }
GLSPGEdge >> readPropertiesFrom: aDictionary [

	sourceId := aDictionary at: 'sourceId' ifAbsent: [ nil ].
	targetId := aDictionary at: 'targetId' ifAbsent: [ nil ].
	routingPoints := ((aDictionary at: 'routingPoints' ifAbsent: [ #(  ) ]) collect: [ :each | GLSPAction pointFromJSON: each ])
		                 asOrderedCollection
]
