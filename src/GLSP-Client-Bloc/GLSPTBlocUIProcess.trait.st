"
I let a Bloc element apply changes coming from another process (e.g. the reader of a server connection): in an open space they are run by the UI process of Bloc, otherwise right away.
"
Trait {
	#name : 'GLSPTBlocUIProcess',
	#category : 'GLSP-Client-Bloc-Core',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Core'
}

{ #category : 'ui process' }
GLSPTBlocUIProcess >> applyInUIProcess: aBlock [
	"In an open space, changes must happen in the UI process of Bloc: run aBlock now if it is the active process, else at the next pulse"

	self isAttachedToSceneGraph
		ifTrue: [ self space deferOrValue: aBlock ]
		ifFalse: [ aBlock value ]
]
