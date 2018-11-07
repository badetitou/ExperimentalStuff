software visualization
classesWithColoredPackages
	<script: 'RCAVisus new classesWithColoredPackages'>
	
	| entities builder legend colors |
	
	entities := model allModelTypes select: [ :c | c numberOfLinesOfCode > 10 ].
	self initializeNamespaceDependenciesFor: entities.

	builder := self zoomableMondrianBuilder.
	builder interaction
		"noInteractions ;"
		popupText: [ :elt | 
			(self formatName: elt) , String cr ,
					'Attributes:' , elt numberOfAttributes asString ,
					' / Methods:' , elt numberOfMethods asString ,
					' / LOC:' , elt numberOfLinesOfCode asString ].

	builder shape rectangle
		borderColor: Color darkGray ;
		size: [ :c | (self namespaceDependenciesFor: c) size max: 1 ].
	builder nodes: entities.

	builder normalizer
	   objects: entities ;
		distinctColorUsing: [ :e | 
			| ns |
			ns := e namespaceScope.
			[ (self formatName: ns) includes: $. ]
				whileTrue: [ ns := ns parentScope ].
			ns ].

	builder edges
		moveBehind ;
		beDirectional ;
		connectToAll: [ :c | c queryOutgoingDependencies withoutSelfLoops atScope: FAMIXType ].

	builder layout force
		charge: -100.

	colors := self collectPackageColors: builder view.

	legend := RTLegendBuilder new.
	legend view: builder view.
	legend onDemand: 'Legend'.
	colors do: [ :assoc | 
			legend
				addColor: assoc value
				object: TRBoxShape new
				text: [:a | self formatName: assoc key] ].
	legend build.

	builder open