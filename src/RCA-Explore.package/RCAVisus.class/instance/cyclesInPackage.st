software visualization
cyclesInPackage
	<script: 'RCAVisus new cyclesInPackage'>

	| cycleCalculator entities dependencies |

	entities := model allModelNamespaces.
	dependencies := self dependenciesToModelNamespaces: entities.

	cycleCalculator := MalTarjan new.
	cycleCalculator nodes: entities.
	cycleCalculator
		edges: entities
		from: #yourself
		toAll: [ :p | (dependencies at: p) atScope: FAMIXNamespace ].
	cycleCalculator run.

	view := RTMondrian new.
	view shape rectangle
				size: 10;
				borderColor: Color darkGray ;
				withTextAbove: [ :ns | self formatName: ns ] ;
				color: [ :p | 
					(self is: p inCycle: cycleCalculator)
						ifTrue: [ Color red ]
						ifFalse: [ Color white ] ] ;
					
		withTextColor: Color black.

	view nodes: entities.

	view shape
		shape:
			(RTArrowedLine new
		attachPoint:
			(RTShorterDistanceAttachPointAndCompositeShape new
				composedShapeSelection: #second) ;
				color: [ :e | | from to |
					from := e key.
					to := e value.
					((self is: from inCycle: cycleCalculator) and: [self is: to inCycle: cycleCalculator])
						ifTrue: [ Color lightRed ]
						ifFalse: [ Color gray ] ]).

	view edges
		moveBehind;
		beDirectional ;
		connectToAll: [ :p | (dependencies at: p) atScope: FAMIXNamespace ].

	view layout force
		nbIterations: 1000;
		strength: 0.1;
		charge: -500.

	view open