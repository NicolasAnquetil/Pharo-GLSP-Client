"
I test a Bloc diagram element following a GLSPClientDiagram connected to a real TaskList server of the image (loopback).
"
Class {
	#name : 'GLSPBlocClientTest',
	#superclass : 'GLSPClientTestCase',
	#category : 'GLSP-Client-Bloc-Tests',
	#package : 'GLSP-Client-Bloc-Tests'
}

{ #category : 'tests' }
GLSPBlocClientTest >> display: aClientDiagram [

	| element |
	element := GLSPBlocDiagramElement new.
	element extent: 1000 @ 1000.
	element diagram: aClientDiagram.
	element forceLayout.
	^ element
]

{ #category : 'tests' }
GLSPBlocClientTest >> testFollowsTheModelUpdates [

	| diagram element view |
	diagram := self openModel.
	element := self display: diagram.
	view := element viewAt: 'task1'.
	diagram dispatch: (GLSPChangeBoundsOperation new
			 newBounds: { (Dictionary new
					  at: 'elementId' put: 'task1';
					  at: 'newPosition' put: (Dictionary new
							   at: 'x' put: 70;
							   at: 'y' put: 80;
							   yourself);
					  yourself) };
			 yourself).
	diagram dispatch: (GLSPCreateNodeOperation new
			 elementTypeId: 'task';
			 location: 300 @ 300;
			 yourself).
	element forceLayout.
	self assert: (element viewAt: 'task1') identicalTo: view.
	self assert: view position equals: 70 @ 80.
	self assert: (element views count: [ :each | each class = GLSPBlocNodeView ]) equals: 3
]

{ #category : 'tests' }
GLSPBlocClientTest >> testShowsTheModelOfTheDiagram [

	| element |
	element := self display: self openModel.
	self assert: (element viewAt: 'task1') position equals: 10 @ 20.
	self assert: (element viewAt: 'task1_label') text asString equals: 'Push'.
	self assert: (element viewAt: 'transition1') isEdgeView
]

{ #category : 'tests' }
GLSPBlocClientTest >> testStopsFollowingAClosedDiagram [

	| diagram element |
	diagram := self openModel.
	element := self display: diagram.
	element diagram: nil.
	self assert: diagram announcer numberOfSubscriptions equals: 0
]
