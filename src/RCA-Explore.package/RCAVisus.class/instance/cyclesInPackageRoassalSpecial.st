software visualization
cyclesInPackageRoassalSpecial
	"same as cyclesInPackage, but correct a bug in Roassal to allow width and color on edges"
	<script: 'RCAVisus new cyclesInPackageRoassalSpecial'>

	| cycleCalculator entities |

	entities := model allModelNamespaces.
	self initializeNamespaceDependenciesFor: entities.

	cycleCalculator := MalTarjan new.
	cycleCalculator nodes: entities.
	cycleCalculator
		edges: entities
		from: #yourself
		toAll: [ :p | self namespaceDependenciesFor: p ].
	cycleCalculator run.

	self zoomableMondrianBuilder.
	builder shape rectangle
				size: 10;
				borderColor: Color darkGray ;
				color: [ :p | 
					(self is: p inCycle: cycleCalculator)
						ifTrue: [ Color red ]
						ifFalse: [ Color white ] ] ;
				withTextAbove: [ :ns | self formatName: ns ] ;
				withTextColor: Color black.

	builder nodes: entities.
	self makeNodesClickable.
	
	builder edges
		moveBehind ;
		beDirectional ;
		resetShape ;
		shape:
			(self arrowedLineOnCompositeNodes 
				color: [ :e | | from to |
					from := e key.
					to := e value.
					((self is: from inCycle: cycleCalculator) and: [self is: to inCycle: cycleCalculator])
						ifTrue: [ Color lightRed ]
						ifFalse: [ Color gray ] ]) ;
		connectToAll: [ :p | (self namespaceDependenciesFor: p) ].
	builder normalizer 
   		edges: builder edges createdEdges ;
		elements: entities ;
   		normalizeLineWidth: [ :from :to | (self dependenciesBetween: from and: to) size ]
			min: 0.2 max: 20.
	self makeLinksClickable.

	builder layout force
		nbIterations: 1000;
		strength: 0.1;
		charge: -500.

	builder open