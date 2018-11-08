software visualization
packagesAndClasses
	<script: 'RCAVisus new packagesAndClasses'>
	| entities viewEdges |
	
	entities := model allModelNamespaces.
	self initializeNamespaceDependenciesFor: entities.

	self zoomableMondrianBuilder.
	builder shape rectangle
		color: Color white;
		borderColor: Color black;
		withTextAbove: [ :p | self formatName: p ].

	builder nodes:  entities
		forEach: [ :p | 
			builder shape rectangle
				width: #numberOfAttributes;
				height: #numberOfMethods;
				borderColor: Color black.
			builder nodes: (p types reject: #isParameterizedType).
			builder layout grid ].
	self makeNodesClickable.

	builder normalizer
		objects: model allModelClasses;
		normalizeColor: #numberOfLinesOfCode
			using:
			{Color white.
				Color black}
			min: 0
			max: 1000.

	builder edges moveBehind ; beDirectional.
	builder shape shape: self arrowedLineOnCompositeNodes.
	viewEdges := builder edges connectToAll: [ :p | (self namespaceDependenciesFor: p) ].
	builder normalizer 
   		edges: viewEdges;
   		normalizeLineWidth: [ :from :to | (self dependenciesBetween: from and: to) size ]
			min: 0.2 max: 20.
	self makeLinksClickable.

	"builder layout circle."	
	builder layout force
		nbIterations: 1000;
		strength: 0.1;
		charge: -500.


	builder open