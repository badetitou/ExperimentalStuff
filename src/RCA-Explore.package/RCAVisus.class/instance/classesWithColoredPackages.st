software visualization
classesWithColoredPackages
	<script: 'RCAVisus new classesWithColoredPackages'>
	
	| entities legend |
	
	entities := model allModelTypes select: [ :c | c numberOfLinesOfCode > 10 ].
	self initializeNamespaceDependenciesFor: entities.

	self zoomableMondrianBuilder.
	builder interaction
		popupText: [ :elt | 
			(self formatName: elt) , String cr ,
					'Attributes:' , elt numberOfAttributes asString ,
					' / Methods:' , elt numberOfMethods asString ,
					' / LOC:' , elt numberOfLinesOfCode asString ].

	builder shape rectangle
		borderColor: Color darkGray ;
		size: [ :c | (self namespaceDependenciesFor: c) size max: 1 ].
	builder nodes: entities.
	self makeNodesClickable.

	builder normalizer
	   objects: entities ;
		distinctColorUsing: [ :e |  self topNamespaceFor: e ].

	builder shape line
		color: [ :a ||from to|
			from := a key.
			to := a value.
			((self topNamespaceFor: from) = (self topNamespaceFor: to) )
				ifTrue: [ Color lightBlue ] ifFalse: [ Color lightGray ] ].
	builder edges
		moveBehind ;
		beDirectional ;
		connectToAll: [ :c | c queryOutgoingDependencies withoutSelfLoops atScope: FAMIXType ].

	builder layout force
		charge: -100.

	legend := RTLegendBuilder new.
	legend view: builder view.
	legend onDemand: 'Legend'.
	legend addColor: Color lightBlue object: TRLineShape new text: 'Dependency within a package'.
	legend addColor: Color lightGray object: TRLineShape new text: 'Dependency between packages'.
	
	legend addColor: Color white object: TRLineShape new text: '-- Package colors: --'.
	self collectPackageColors do: [ :assoc | 
			legend
				addColor: assoc value
				object: TRBoxShape new
				text: [:a | self formatName: assoc key] ].
	legend build.

	builder open