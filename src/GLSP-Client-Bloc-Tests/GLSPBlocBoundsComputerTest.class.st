"
I test the bounds a Bloc client answers to a requestBounds of the server.
"
Class {
	#name : 'GLSPBlocBoundsComputerTest',
	#superclass : 'TestCase',
	#category : 'GLSP-Client-Bloc-Tests',
	#package : 'GLSP-Client-Bloc-Tests'
}

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> boundsOf: anId [

	^ (GLSPBlocBoundsComputer new boundsOf: self workflowRoot) detect: [ :each | (each at: 'elementId') = anId ] ifNone: [ nil ]
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> positionOf: anId [

	| position |
	position := (self boundsOf: anId) at: 'newPosition'.
	^ (position at: 'x') @ (position at: 'y')
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> sizeOf: anId [

	| size |
	size := (self boundsOf: anId) at: 'newSize'.
	^ (size at: 'width') @ (size at: 'height')
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> testAFollowingDiagramElementInstallsABlocBoundsComputer [

	| client diagram element |
	client := GLSPClient connection: GLSPRecordingClientConnection new.
	diagram := GLSPClientDiagram client: client id: 'd' diagramType: 'workflow-diagram'.
	element := GLSPBlocDiagramElement new.
	element diagram: diagram.
	self assert: diagram boundsComputer class equals: GLSPBlocBoundsComputer.
	self assert: diagram boundsComputer registry identicalTo: element registry
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> testEdgesHaveNoBounds [

	self assert: (self boundsOf: 'e') isNil
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> testHBoxFitsItsChildrenAndPaddings [
	"Sprotty hbox: default paddings 5, paddingRight 10 here, hGap 1"

	| label |
	label := self sizeOf: 't_label'.
	self assert: ((self sizeOf: 't') x closeTo: 5 + 25 + 1 + label x + 10).
	self assert: ((self sizeOf: 't') y closeTo: (20 max: label y) + 10)
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> testHBoxPlacesItsChildren [

	| label height |
	label := self sizeOf: 't_label'.
	height := 20 max: label y.
	self assert: (self positionOf: 't_icon') equals: 5 @ (5 + (height - 20 / 2)).
	self assert: ((self positionOf: 't_label') x closeTo: 31).
	self assert: ((self positionOf: 't_label') y closeTo: 5 + (height - label y / 2))
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> testLabelsAreMeasured [

	| size |
	size := self sizeOf: 't_label'.
	self assert: size x > 20.
	self assert: size y > 10
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> testShapesWithASizeKeepIt [

	self assert: (self sizeOf: 'f') equals: 10 @ 50.
	self assert: (self positionOf: 'f') equals: 10 @ 10
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> testTopLevelShapesKeepTheirPosition [

	self assert: (self positionOf: 't') equals: 300 @ 200
]

{ #category : 'tests' }
GLSPBlocBoundsComputerTest >> workflowRoot [
	"A task as created by the Eclipse GLSP Workflow server: no sizes, an hbox with an icon and a label"

	^ GLSPGModelElement fromJSON: (STONJSON fromString:
			   '{"type":"graph","id":"root","revision":2,"children":[{"type":"task:manual","id":"t","position":{"x":300,"y":200},"layout":"hbox","layoutOptions":{"paddingRight":10},"children":[{"type":"icon","id":"t_icon","size":{"width":25,"height":20}},{"type":"label:heading","id":"t_label","text":"Push"}]},{"type":"activityNode:fork","id":"f","position":{"x":10,"y":10},"size":{"width":10,"height":50}},{"type":"edge","id":"e","sourceId":"t","targetId":"f"}]}')
]
