software visualization
packagesAndClasses
	<script: 'RCAVisus new packagesAndClasses'>
	| dependencies entities |
	
	entities := model allModelNamespaces.
	dependencies := self dictionaryOfOutgoingDependenciesFor: entities.

	view := RTMondrian new.
	view shape rectangle
		color: Color white;
		borderColor: Color black;
		withTextAbove: [ :p | self formatName: p ].

	view
		nodes: entities
		forEach: [ :p | 
			view shape rectangle
				width: #numberOfAttributes;
				height: #numberOfMethods;
				borderColor: Color black.
			view nodes: (p types reject: #isParameterizedType).
			view layout grid ].
	"view shape arrowedLine withShorterDistanceAttachPoint."
	view shape shape: self arrowedLineOnCompositeNodes.

	view edges
		moveBehind;
		connectToAll: [ :p | (dependencies at: p) atScope: FAMIXNamespace ].

	view normalizer
		objects: model allModelClasses;
		normalizeColor: #numberOfLinesOfCode
			using:
			{Color white.
				Color black}
			min: 0
			max: 1000.

	"view normalizer
	edges: view edges ;
	normalizeColor: [:e | ((dependenciesP at: (e from model)) select: [ :dep | dep to atScope: FAMIXNamespace ]) size ]
     using: {Color yellow . Color red}
	  using: view edges."
	view layout circle.

	view open