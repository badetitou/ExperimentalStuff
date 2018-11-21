Class {
	#name : #RCAVisus,
	#superclass : #Object,
	#instVars : [
		'model',
		'dependencyMatrix',
		'builder'
	],
	#category : 'RCA-Explore'
}

{ #category : #'private view' }
RCAVisus >> arrowedLineOnCompositeNodes [
	^ RTArrowedLine new
		attachPoint:
			(RTShorterDistanceAttachPointAndCompositeShape new
				composedShapeSelection: #second)
]

{ #category : #'software visualization' }
RCAVisus >> classesWithColoredPackages [
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
]

{ #category : #'private view' }
RCAVisus >> collectPackageColors [
	^(builder view elements
		collectAsSet: [ :e | e model namespaceScope -> e color ])
		asOrderedCollection sorted: [ :x :y | x key mooseName <= y key mooseName ]
]

{ #category : #'software visualization' }
RCAVisus >> cyclesInPackage [
	<script: 'RCAVisus new cyclesInPackage'>

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
	self makeLinksClickable.

	builder layout force
		nbIterations: 1000;
		strength: 0.1;
		charge: -500.

	builder open
]

{ #category : #'software visualization' }
RCAVisus >> cyclesInPackageRoassalSpecial [
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
]

{ #category : #'private  model' }
RCAVisus >> defaultJavaPackagePrefix [
	^ 'org::rcaexplore'
]

{ #category : #'private  model' }
RCAVisus >> dependenciesBetween: aFamixEntity and: aNamespace [
	^ (dependencyMatrix at: aFamixEntity ifAbsent: [ Dictionary new])
			at: aNamespace ifAbsent: [ #()]
]

{ #category : #'private  model' }
RCAVisus >> formatName: aNamespace [
	^ (aNamespace mooseName withoutPrefix: (self defaultJavaPackagePrefix , '::'))
			copyReplaceAll: '::' with: '.'
]

{ #category : #initialization }
RCAVisus >> initialize [
	model := MooseModel root allModels detect: [:m | m name = 'rca']
]

{ #category : #'private  model' }
RCAVisus >> initializeNamespaceDependenciesFor: entities [
	dependencyMatrix := Dictionary new.
	entities
		do:
			[ :p | dependencyMatrix at: p put: (p queryOutgoingDependencies withoutSelfLoops opposites asOrderedCollection groupedBy: #namespaceScope) ].
]

{ #category : #'private  model' }
RCAVisus >> is: p inCycle: cycleCalculator [
	^ (cycleCalculator findNode: p) isInCycle
]

{ #category : #'private view' }
RCAVisus >> makeLinksClickable [
	(builder view edges) when: TRMouseClick do: [ :evt || from to|
		from := evt element from model.
		to := evt element to model.
		(self dependenciesBetween: from and: to) inspect
	]
]

{ #category : #'private view' }
RCAVisus >> makeNodesClickable [
	(builder view elements) when: TRMouseClick do: [ :evt | evt element model inspect ]
]

{ #category : #'private  model' }
RCAVisus >> namespaceDependenciesFor: aNamespace [
	^ (dependencyMatrix at: aNamespace) values flatten asSet collect: #namespaceScope
]

{ #category : #'software visualization' }
RCAVisus >> packagesAndClasses [
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
]

{ #category : #'private  model' }
RCAVisus >> topNamespaceFor: aFamixEntity [
	"returns the top namespace of the system or one of its direct children"
	| namespace |
	namespace := aFamixEntity namespaceScope.
	(namespace mooseName = self defaultJavaPackagePrefix) ifTrue: [ ^ namespace ].
	(namespace parentScope mooseName = self defaultJavaPackagePrefix) ifTrue: [ ^ namespace ].
	^ self topNamespaceFor: namespace parentScope

]

{ #category : #'private view' }
RCAVisus >> zoomableMondrianBuilder [
	builder := RTMondrian new.
	builder view @ RTZoomableView.
	^ builder
]
