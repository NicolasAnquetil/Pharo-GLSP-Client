"
I test the Bloc views of the Workflow example language of Eclipse GLSP, on a sample model (headless).
"
Class {
	#name : 'GLSPWorkflowViewsTest',
	#superclass : 'TestCase',
	#category : 'GLSP-Client-Workflow-Tests',
	#package : 'GLSP-Client-Workflow-Tests'
}

{ #category : 'tests' }
GLSPWorkflowViewsTest >> display [

	| element |
	element := GLSPBlocDiagramElement new.
	GLSPWorkflowViews registerOn: element registry.
	element extent: 800 @ 400.
	element root: self sampleRoot.
	element forceLayout.
	^ element
]

{ #category : 'tests' }
GLSPWorkflowViewsTest >> sampleRoot [

	^ GLSPGModelElement fromJSON: (STONJSON fromString:
			   '{"type":"graph","id":"root","revision":1,"children":[{"type":"task:manual","id":"m","cssClasses":["task","manual"],"position":{"x":10,"y":10},"layout":"hbox","layoutOptions":{"paddingRight":10},"children":[{"type":"icon","id":"m_icon"},{"type":"label:heading","id":"m_label","text":"Push"}]},{"type":"task:automated","id":"a","cssClasses":["task","automated"],"position":{"x":200,"y":10},"size":{"width":82,"height":30},"layout":"hbox","layoutOptions":{"paddingRight":10},"children":[{"type":"icon","id":"a_icon","size":{"width":25,"height":20}},{"type":"label:heading","id":"a_label","text":"ChkTp"}]},{"type":"activityNode:decision","id":"d","position":{"x":10,"y":100},"size":{"width":32,"height":32}},{"type":"activityNode:merge","id":"g","position":{"x":100,"y":100},"size":{"width":32,"height":32}},{"type":"activityNode:fork","id":"f","position":{"x":200,"y":100},"size":{"width":10,"height":50}},{"type":"activityNode:join","id":"j","position":{"x":300,"y":100},"size":{"width":10,"height":50}}]}')
]

{ #category : 'tests' }
GLSPWorkflowViewsTest >> testCreatedTasksAreMeasuredLikeTheEclipseClient [
	"The icon is 25x20, so the label is at 5 + 25 + 1 = 31, as in the models of the Eclipse client"

	| bounds label |
	bounds := GLSPBlocBoundsComputer new
		          registry: (GLSPBlocViewRegistry new in: [ :registry |
						           GLSPWorkflowViews registerOn: registry.
						           registry ]);
		          boundsOf: self sampleRoot.
	label := bounds detect: [ :each | (each at: 'elementId') = 'm_label' ].
	self assert: ((label at: 'newPosition') at: 'x') equals: 31.
	self assert: (((bounds detect: [ :each | (each at: 'elementId') = 'm_icon' ]) at: 'newSize') at: 'width') equals: 25
]

{ #category : 'tests' }
GLSPWorkflowViewsTest >> testDecisionAndMergeNodesAreDiamonds [

	| geometry |
	geometry := (self display viewAt: 'd') geometry.
	self assert: geometry class equals: BlPolygonGeometry.
	self assert: geometry vertices asArray equals: {
			(16 @ 0).
			(32 @ 16).
			(16 @ 32).
			(0 @ 16) }
]

{ #category : 'tests' }
GLSPWorkflowViewsTest >> testEachWorkflowTypeHasItsView [

	| element |
	element := self display.
	self assert: (element viewAt: 'm') class equals: GLSPWorkflowTaskView.
	self assert: (element viewAt: 'a') class equals: GLSPWorkflowTaskView.
	self assert: (element viewAt: 'm_icon') class equals: GLSPWorkflowIconView.
	self assert: (element viewAt: 'd') class equals: GLSPWorkflowDiamondView.
	self assert: (element viewAt: 'g') class equals: GLSPWorkflowDiamondView.
	self assert: (element viewAt: 'f') class equals: GLSPWorkflowBarView.
	self assert: (element viewAt: 'j') class equals: GLSPWorkflowBarView.
	self assert: (element viewAt: 'm_label') class equals: GLSPBlocLabelView
]

{ #category : 'tests' }
GLSPWorkflowViewsTest >> testEdgesAreClippedOnTheOutlineOfDiamonds [
	"An edge from the left to the decision node d (32x32 at 10@100) ends on the diamond: |dx|/16 + |dy|/16 = 1 from its center"

	| root element end delta |
	root := self sampleRoot.
	root add: (GLSPGNode new
			 id: 'start';
			 type: 'node';
			 position: -100 @ 90;
			 size: 20 @ 20;
			 yourself).
	root add: (GLSPGEdge new
			 id: 'to_d';
			 type: 'edge';
			 sourceId: 'start';
			 targetId: 'd';
			 yourself).
	element := GLSPBlocDiagramElement new.
	GLSPWorkflowViews registerOn: element registry.
	element extent: 800 @ 400.
	element root: root.
	element forceLayout.
	end := (element viewAt: 'to_d') toPoint.
	delta := end - (26 @ 116).
	self assert: (delta x abs / 16 + (delta y abs / 16) closeTo: 1).
	self assert: end x < 26
]

{ #category : 'tests' }
GLSPWorkflowViewsTest >> testForkAndJoinNodesAreDarkBars [

	| bar |
	bar := self display viewAt: 'f'.
	self assert: bar extent equals: 10 @ 50.
	self assert: bar background paint color brightness < 0.3
]

{ #category : 'tests' }
GLSPWorkflowViewsTest >> testIconsHaveTheSizeOfTheEclipseClient [

	self assert: (self display viewAt: 'm_icon') extent equals: 25 @ 20
]

{ #category : 'tests' }
GLSPWorkflowViewsTest >> testManualAndAutomatedTasksLookDifferent [

	| element |
	element := self display.
	self deny: (element viewAt: 'm') background equals: (element viewAt: 'a') background.
	self deny: (element viewAt: 'm_icon') text asString equals: (element viewAt: 'a_icon') text asString
]
