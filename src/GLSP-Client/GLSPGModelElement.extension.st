Extension { #name : 'GLSPGModelElement' }

{ #category : '*GLSP-Client' }
GLSPGModelElement class >> classForJSON: aDictionary [
	"The class of the element: from the standard type prefixes, then from the structure (types like 'task' or 'transition' are language specific)"

	| type |
	type := aDictionary at: 'type' ifAbsent: [ '' ].
	((type beginsWith: 'graph') or: [ aDictionary includesKey: 'revision' ]) ifTrue: [ ^ GLSPGModelRoot ].
	(type beginsWith: 'comp') ifTrue: [ ^ GLSPGCompartment ].
	(type beginsWith: 'port') ifTrue: [ ^ GLSPGPort ].
	((type beginsWith: 'edge') or: [ aDictionary includesKey: 'sourceId' ]) ifTrue: [ ^ GLSPGEdge ].
	((type beginsWith: 'label') or: [ aDictionary includesKey: 'text' ]) ifTrue: [ ^ GLSPGLabel ].
	^ GLSPGNode
]

{ #category : '*GLSP-Client' }
GLSPGModelElement class >> fromJSON: aDictionary [
	"Read a GModel element (and its children) from its JSON form"

	^ (self classForJSON: aDictionary) new
		  readJSON: aDictionary;
		  yourself
]

{ #category : '*GLSP-Client' }
GLSPGModelElement >> isShape [
	"Whether I have a position and a size"

	^ false
]

{ #category : '*GLSP-Client' }
GLSPGModelElement >> readJSON: aDictionary [
	id := aDictionary at: 'id' ifAbsent: [ nil ].
	type := aDictionary at: 'type' ifAbsent: [ nil ].
	aDictionary at: 'cssClasses' ifPresent: [ :classes | cssClasses := classes asOrderedCollection ].
	aDictionary at: 'args' ifPresent: [ :dictionary | args := dictionary ].
	self addAll: ((aDictionary at: 'children' ifAbsent: [ #(  ) ]) collect: [ :each | self class fromJSON: each ]).
	self readPropertiesFrom: aDictionary
]

{ #category : '*GLSP-Client' }
GLSPGModelElement >> readPropertiesFrom: aDictionary [
	"Hook for subclasses to read their own JSON properties"

	
]

{ #category : '*GLSP-Client' }
GLSPGModelElement >> withAllParentsDo: aBlock [
	"Evaluate aBlock with me, then with each of my parents up to the root"

	aBlock value: self.
	parent ifNotNil: [ parent withAllParentsDo: aBlock ]
]
