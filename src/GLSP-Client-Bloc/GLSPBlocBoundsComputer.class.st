"
I compute the bounds asked by a server (requestBounds) by laying out the Bloc views of the model offscreen: labels are measured, containers with an hbox or vbox layout fit their children (as the Sprotty layouts of the Eclipse GLSP clients), shapes with a size keep it.

A GLSPBlocDiagramElement following a GLSPClientDiagram installs me on the diagram, with its view registry.
"
Class {
	#name : 'GLSPBlocBoundsComputer',
	#superclass : 'GLSPGModelBoundsComputer',
	#instVars : [
		'registry',
		'element'
	],
	#category : 'GLSP-Client-Bloc-Core',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GLSPBlocBoundsComputer class >> registry: aViewRegistry [

	^ self new
		  registry: aViewRegistry;
		  yourself
]

{ #category : 'computing' }
GLSPBlocBoundsComputer >> boundsOf: aGModelRoot [
	"Lay out the views of aGModelRoot offscreen, then answer the bounds of its shapes"

	element := GLSPBlocDiagramElement new.
	element registry: self registry.
	element root: aGModelRoot.
	element forceLayout.
	^ [ super boundsOf: aGModelRoot ] ensure: [ element := nil ]
]

{ #category : 'computing' }
GLSPBlocBoundsComputer >> positionOf: aGModelElement [
	"Relative to the parent, as in the GModel"

	^ (element viewAt: aGModelElement id) ifNil: [ super positionOf: aGModelElement ] ifNotNil: [ :view | view position ]
]

{ #category : 'computing' }
GLSPBlocBoundsComputer >> registry [

	^ registry ifNil: [ registry := GLSPBlocViewRegistry new ]
]

{ #category : 'computing' }
GLSPBlocBoundsComputer >> registry: aViewRegistry [

	registry := aViewRegistry
]

{ #category : 'computing' }
GLSPBlocBoundsComputer >> sizeOf: aGModelElement [

	aGModelElement isShape ifFalse: [ ^ nil ].
	^ (element viewAt: aGModelElement id) ifNil: [ super sizeOf: aGModelElement ] ifNotNil: [ :view | view extent ]
]
