software visualization
cyclesInPackage
	<script: 'RCAVisus new cyclesInPackage'>

	| cycleCalculator entities dependencies shape elts |

	entities := model allModelNamespaces.
	dependencies := self outgoingDependenciesFor: entities.
	cycleCalculator := MalTarjan new.
	cycleCalculator nodes: entities.
	cycleCalculator
		edges: entities
		from: #yourself
		toAll: [ :p | (dependencies at: p) atScope: FAMIXNamespace ].
	cycleCalculator run.
	view := RTView new.
	view @ RTDraggableView.
	view @ RTZoomableView.
	shape := RTCompositeShape new.
	shape
		add:
			(RTLabel new
				color: Color black;
				text: [ :p | self formatName: p ]).
	shape
		add:
			(RTBox new
				size: 10;
				borderColor: Color darkGray;
				color: [ :p | 
					(self is: p inCycle: cycleCalculator)
						ifTrue: [ Color red ]
						ifFalse: [ Color white ] ]).
	shape vertical.
	elts := shape elementsOn: entities.
	view addAll: elts.
	elts @ RTDraggable.
	RTEdgeBuilder new
		view: view;
		moveBehind;
		objects: entities;
		shape:
			(self arrowedLineOnCompositeNodes 
				color: [ :e | 
					| from to |
					from := e key.
					to := e value.
					((self is: from inCycle: cycleCalculator) and: [self is: to inCycle: cycleCalculator])
						ifTrue: [ Color lightRed ]
						ifFalse: [ Color gray ] ]) ;
		connectToAll: [ :p | (dependencies at: p) atScope: FAMIXNamespace ].

	RTOptimizedForceBasedLayout new
		nbIterations: 1000;
		strength: 0.1;
		charge: -500;
		on: elts.

	view open