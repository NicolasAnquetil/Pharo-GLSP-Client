"
I test reading a GModel from its JSON form, as a client receives it in setModel / updateModel.
"
Class {
	#name : 'GLSPGModelReadingTest',
	#superclass : 'TestCase',
	#category : 'GLSP-Client-Tests',
	#package : 'GLSP-Client-Tests'
}

{ #category : 'tests' }
GLSPGModelReadingTest >> read: aGModelElement [
	"Read back the JSON of aGModelElement, as it travels on the wire"

	^ GLSPGModelElement fromJSON: (STONJSON fromString: (STONJSON toString: aGModelElement asJRPCJSON))
]

{ #category : 'tests' }
GLSPGModelReadingTest >> sampleRoot [

	| root node |
	root := GLSPGModelRoot new
		        id: 'root';
		        revision: 4;
		        yourself.
	node := GLSPGNode new
		        id: 'task1';
		        type: 'task';
		        position: 10 @ 20;
		        size: 80 @ 30;
		        layout: 'hbox';
		        yourself.
	node addCssClass: 'tasklist-node'.
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
			 routingPoints: { (100 @ 50) };
			 yourself).
	^ root
]

{ #category : 'tests' }
GLSPGModelReadingTest >> testArgsAreKept [

	| node |
	node := GLSPGNode new
		        id: 'n';
		        yourself.
	node argsAt: 'color' put: 'red'.
	self assert: ((self read: node) args at: 'color') equals: 'red'
]

{ #category : 'tests' }
GLSPGModelReadingTest >> testReadCompartmentAndPortByTypePrefix [

	| root |
	root := GLSPGModelElement fromJSON: (STONJSON fromString:
			         '{"id":"r","type":"graph","children":[{"id":"n","type":"node","children":[{"id":"h","type":"comp:header","children":[]},{"id":"p","type":"port","children":[]}]}]}').
	self assert: (root elementAt: 'h') class equals: GLSPGCompartment.
	self assert: (root elementAt: 'p') class equals: GLSPGPort
]

{ #category : 'tests' }
GLSPGModelReadingTest >> testReadEdge [

	| edge |
	edge := (self read: self sampleRoot) elementAt: 'transition1'.
	self assert: edge class equals: GLSPGEdge.
	self assert: edge sourceId equals: 'task1'.
	self assert: edge targetId equals: 'task2'.
	self assert: edge routingPoints asArray equals: { (100 @ 50) }
]

{ #category : 'tests' }
GLSPGModelReadingTest >> testReadLabel [

	| root label |
	root := self read: self sampleRoot.
	label := root elementAt: 'task1_label'.
	self assert: label class equals: GLSPGLabel.
	self assert: label text equals: 'Push'.
	self assert: label parent equals: (root elementAt: 'task1')
]

{ #category : 'tests' }
GLSPGModelReadingTest >> testReadNode [

	| node |
	node := (self read: self sampleRoot) elementAt: 'task1'.
	self assert: node class equals: GLSPGNode.
	self assert: node type equals: 'task'.
	self assert: node position equals: 10 @ 20.
	self assert: node size equals: 80 @ 30.
	self assert: node layout equals: 'hbox'.
	self assert: node cssClasses asArray equals: #( 'tasklist-node' )
]

{ #category : 'tests' }
GLSPGModelReadingTest >> testReadRoot [

	| root |
	root := self read: self sampleRoot.
	self assert: root class equals: GLSPGModelRoot.
	self assert: root id equals: 'root'.
	self assert: root revision equals: 4.
	self assert: root children size equals: 3
]

{ #category : 'tests' }
GLSPGModelReadingTest >> testRoundTrip [

	| original |
	original := self sampleRoot.
	self assert: (self read: original) asJRPCJSON equals: original asJRPCJSON
]
