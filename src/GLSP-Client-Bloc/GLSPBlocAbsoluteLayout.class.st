"
I place the children at their position, as a GModel container without layout. Unlike BlBasicLayout, a container that fits its content gets the extent of the box enclosing its children.
"
Class {
	#name : 'GLSPBlocAbsoluteLayout',
	#superclass : 'BlBasicLayout',
	#category : 'GLSP-Client-Bloc-Views',
	#package : 'GLSP-Client-Bloc',
	#tag : 'Views'
}

{ #category : 'measure' }
GLSPBlocAbsoluteLayout >> measure: anElement with: anExtentSpec [

	| extent |
	self measuredChildren: anElement do: [ :aChild | self measureChild: aChild parentSpec: anExtentSpec ].
	extent := anElement children accountedByLayout
		          inject: 0 @ 0
		          into: [ :corner :aChild | corner max: aChild constraints position + aChild measuredExtent ].
	extent := extent + (anElement padding right @ anElement padding bottom).
	anElement measuredExtent: (anExtentSpec extentForWidth: extent x height: extent y).
	self measureIgnored: anElement with: anExtentSpec
]
