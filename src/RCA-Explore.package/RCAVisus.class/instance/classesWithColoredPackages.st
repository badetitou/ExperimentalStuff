software visualization
classesWithColoredPackages
	<script: 'RCAVisus new classesWithColoredPackages'>
	| shape elts legend entities |

	entities := model allModelTypes
		select: [ :c | c numberOfLinesOfCode > 10 ].

	view := RTView new.
	view @ RTDraggableView.
	view @ RTZoomableView.
	shape := RTBox new borderColor: Color darkGray.
	shape size: [ :c | (self dependenciesToModelNamespaces: c) size max: 1 ].

	elts := shape elementsOn: entities.
	view addAll: elts.
	elts @ RTDraggable.
	elts
		@
			(RTPopup new
				text: [ :elt | 
					(self pckgLabel: elt) , String cr ,
					'Attributes:' , elt numberOfAttributes asString ,
					' / Methods:' , elt numberOfMethods asString ,
					' / LOC:' , elt numberOfLinesOfCode asString ]).

	RTMetricNormalizer new
		elements: (elts sorted: [ :x :y | x mooseName <= y mooseName ]);
		distinctColorUsing: [ :e | 
			| ns |
			ns := e namespaceScope.
			[ (self pckgLabel: ns) includes: $. ]
				whileTrue: [ ns := ns parentScope ].
			ns ].

	RTEdgeBuilder new
		view: view;
		moveBehind;
		objects: entities;
		connectToAll:
				[ :c | c queryOutgoingDependencies withoutSelfLoops atScope: FAMIXType ].

	RTOptimizedForceBasedLayout new
		on: elts;
		nbIterations: 50;
		strength: 0.5;
		charge: -500;
		initialLayout: RTCircleLayout.

	legend := RTLegendBuilder new.
	legend onDemand: 'Legend'.
	legend view: view.
	(view elements
		collectAsSet: [ :e | e model namespaceScope -> e color ])
		do: [ :assoc | 
			legend
				addColor: assoc value
				object: TRBoxShape new
				text: [:a | self pckgLabel: assoc key] ].
	legend build.

	view open