software visualization
cyclesInPackage
	<script: 'RCAVisus new cyclesInPackage'>
	| cycleCalculator entities dependencies |
	entities := model allModelNamespaces.
	dependencies := self
		outgoingDependenciesFor: model allModelNamespaces.
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
		color: [ :p | 
			(cycleCalculator findNode: p) isInCycle
				ifTrue: [ Color red ]
				ifFalse: [ Color white ] ];
		borderColor: Color black;
		withTextAbove: [ :p | self pckgLabel: p ].
	view nodes: entities.
	view shape arrowedLine withShorterDistanceAttachPoint.
	view edges
		moveBehind;
		connectToAll: [ :p | (dependencies at: p) atScope: FAMIXNamespace ].
	view layout force
		charge: -1000;
		length: 50;
		strength: 0.1;
		nbIterations: 100.
	"initialLayout: RTCircleLayout new ;"
	view open