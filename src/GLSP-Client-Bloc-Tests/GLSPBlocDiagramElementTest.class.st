"
I test the Bloc display of GModels (headless: no space is opened).
"
Class {
	#name : 'GLSPBlocDiagramElementTest',
	#superclass : 'TestCase',
	#category : 'GLSP-Client-Bloc-Tests',
	#package : 'GLSP-Client-Bloc-Tests'
}

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> display: aRoot [

	| element |
	element := GLSPBlocDiagramElement new.
	element extent: 1000 @ 1000.
	element root: aRoot.
	element forceLayout.
	^ element
]

{ #category : 'tests - update' }
GLSPBlocDiagramElementTest >> movedRoot [
	"The sample model, after task1 moved, task2 was deleted (with its transition) and task3 was created"

	| root node |
	root := GLSPGModelRoot new
		        id: 'root';
		        revision: 2;
		        yourself.
	node := GLSPGNode new
		        id: 'task1';
		        type: 'task';
		        position: 50 @ 60;
		        size: 80 @ 30;
		        layout: 'hbox';
		        yourself.
	node add: (GLSPGLabel new
			 id: 'task1_label';
			 text: 'Push!';
			 yourself).
	root add: node.
	root add: (GLSPGNode new
			 id: 'task3';
			 type: 'task';
			 position: 50 @ 200;
			 size: 80 @ 30;
			 yourself).
	root add: (GLSPGEdge new
			 id: 'transition2';
			 type: 'transition';
			 sourceId: 'task1';
			 targetId: 'task3';
			 yourself).
	^ root
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> sampleRoot [

	| root node |
	root := GLSPGModelRoot new
		        id: 'root';
		        revision: 1;
		        yourself.
	node := GLSPGNode new
		        id: 'task1';
		        type: 'task';
		        position: 10 @ 20;
		        size: 80 @ 30;
		        layout: 'hbox';
		        yourself.
	node add: (GLSPGLabel new
			 id: 'task1_label';
			 text: 'Push';
			 yourself).
	root add: node.
	root add: (GLSPGNode new
			 id: 'task2';
			 type: 'task';
			 position: 200 @ 20;
			 size: 80 @ 30;
			 yourself).
	root add: (GLSPGEdge new
			 id: 'transition1';
			 type: 'transition';
			 sourceId: 'task1';
			 targetId: 'task2';
			 yourself).
	^ root
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> testChildrenOfANodeWithoutLayoutAreAtTheirPosition [

	| root element |
	root := GLSPGModelRoot new
		        id: 'root';
		        yourself.
	root add: ((GLSPGNode new
			  id: 'a';
			  position: 5 @ 5;
			  yourself)
			 add: (GLSPGLabel new
					  id: 'l';
					  text: 'Some text';
					  position: 3 @ 4;
					  yourself);
			 yourself).
	element := self display: root.
	self assert: (element viewAt: 'l') position equals: 3 @ 4.
	self assert: (element viewAt: 'a') extent equals: 3 @ 4 + (element viewAt: 'l') extent
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> testEdgeClipsOnTheTopAndBottomBorders [

	| root edge |
	root := GLSPGModelRoot new
		        id: 'root';
		        yourself.
	root add: (GLSPGNode new
			 id: 'a';
			 position: 0 @ 0;
			 size: 100 @ 40;
			 yourself).
	root add: (GLSPGNode new
			 id: 'b';
			 position: 0 @ 200;
			 size: 100 @ 40;
			 yourself).
	root add: (GLSPGEdge new
			 id: 'e';
			 sourceId: 'a';
			 targetId: 'b';
			 yourself).
	edge := (self display: root) viewAt: 'e'.
	self assert: edge fromPoint equals: 50 @ 40.
	self assert: edge toPoint equals: 50 @ 200
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> testEdgeGoesFromBorderToBorder [

	| edge |
	edge := (self display: self sampleRoot) viewAt: 'transition1'.
	self assert: edge class equals: GLSPBlocEdgeView.
	self assert: edge fromPoint equals: 90 @ 35.
	self assert: edge toPoint equals: 200 @ 35
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> testEdgesAreAboveNodes [

	| element |
	element := self display: self sampleRoot.
	self assert: (element viewAt: 'transition1') elevation elevation > (element viewAt: 'task1') elevation elevation
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> testLabelIsInsideItsNode [

	| element |
	element := self display: self sampleRoot.
	self assert: (element viewAt: 'task1_label') parent equals: (element viewAt: 'task1')
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> testLabelShowsItsText [

	| label |
	label := (self display: self sampleRoot) viewAt: 'task1_label'.
	self assert: label class equals: GLSPBlocLabelView.
	self assert: label text asString equals: 'Push'
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> testNodeWithoutSizeFitsItsContent [

	| root view |
	root := GLSPGModelRoot new
		        id: 'root';
		        yourself.
	root add: ((GLSPGNode new
			  id: 'a';
			  position: 5 @ 5;
			  yourself)
			 add: (GLSPGLabel new
					  id: 'l';
					  text: 'Some text';
					  yourself);
			 yourself).
	view := (self display: root) viewAt: 'a'.
	self assert: view extent x > 0.
	self assert: view extent y > 0
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> testNodesBecomeViews [

	| view |
	view := (self display: self sampleRoot) viewAt: 'task1'.
	self assert: view class equals: GLSPBlocNodeView.
	self assert: view position equals: 10 @ 20.
	self assert: view extent equals: 80 @ 30
]

{ #category : 'tests' }
GLSPBlocDiagramElementTest >> testRegistryChoosesTheViewOfAType [

	| element |
	element := GLSPBlocDiagramElement new.
	element registry register: GLSPBlocTestTaskView forType: 'task'.
	element root: self sampleRoot.
	self assert: (element viewAt: 'task1') class equals: GLSPBlocTestTaskView.
	self assert: (element viewAt: 'transition1') class equals: GLSPBlocEdgeView
]

{ #category : 'tests - update' }
GLSPBlocDiagramElementTest >> testUpdateKeepsTheViewsOfTheSameElements [

	| element view label |
	element := self display: self sampleRoot.
	view := element viewAt: 'task1'.
	label := element viewAt: 'task1_label'.
	element root: self movedRoot.
	element forceLayout.
	self assert: (element viewAt: 'task1') identicalTo: view.
	self assert: (element viewAt: 'task1_label') identicalTo: label.
	self assert: view position equals: 50 @ 60.
	self assert: label text asString equals: 'Push!'
]

{ #category : 'tests - update' }
GLSPBlocDiagramElementTest >> testUpdateMovesTheEdges [

	| element edge |
	element := self display: self sampleRoot.
	element root: self movedRoot.
	edge := element viewAt: 'transition2'.
	self assert: edge fromPoint equals: 90 @ 90.
	self assert: edge toPoint equals: 90 @ 200
]

{ #category : 'tests - update' }
GLSPBlocDiagramElementTest >> testUpdateRemovesAndAddsViews [
	| element |
	element := self display: self sampleRoot.
	element root: self movedRoot.
	self assert: (element viewAt: 'task2') isNil.
	self assert: (element viewAt: 'transition1') isNil.
	self assert: (element viewAt: 'task3') isNotNil.
	self assert: (element viewAt: 'task3') parent equals: element.
	self assert: (element children count: [ :each | each class = GLSPBlocNodeView ]) equals: 2
]
