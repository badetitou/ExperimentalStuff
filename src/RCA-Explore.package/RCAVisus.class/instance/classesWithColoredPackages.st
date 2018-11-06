software visualization
classesWithColoredPackages
	<script: 'RCAVisus new classesWithColoredPackages'>
	
	| legend entities |
	
	entities := model allModelTypes select: [ :c | c numberOfLinesOfCode > 10 ].

	view := RTMondrian new.
	view interaction
		noInteractions ;
		popupText: [ :elt | 
			(self formatName: elt) , String cr ,
					'Attributes:' , elt numberOfAttributes asString ,
					' / Methods:' , elt numberOfMethods asString ,
					' / LOC:' , elt numberOfLinesOfCode asString ].

	view shape rectangle
		borderColor: Color darkGray ;
		size: [ :c | (self dependenciesToModelNamespaces: c) size max: 1 ].
	view nodes: entities.

	view normalizer
	   objects: entities ;
		distinctColorUsing: [ :e | 
			| ns |
			ns := e namespaceScope.
			[ (self formatName: ns) includes: $. ]
				whileTrue: [ ns := ns parentScope ].
			ns ].

	view edges
		moveBehind ;
		beDirectional ;
		connectToAll: [ :c | c queryOutgoingDependencies withoutSelfLoops atScope: FAMIXType ].

	view layout force
		charge: -100.

	legend := RTLegendBuilder new.
	legend onDemand: 'Legend'.
	legend view: view view.
	((view  view elements
		collectAsSet: [ :e | e model namespaceScope -> e color ])
		asOrderedCollection sorted: [ :x :y | x key mooseName <= y key mooseName ])
		do: [ :assoc | 
			legend
				addColor: assoc value
				object: TRBoxShape new
				text: [:a | self formatName: assoc key] ].
	legend build.

	view open