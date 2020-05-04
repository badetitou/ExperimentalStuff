"
MooseModel resetRoot.
msePath := 'D:\Developpement\mse\rcaexplore\verveinej\rca.mse'.
rootFolderPath := 'D:\Developpement\mse\rcaexplore\rcaexplore'.
mooseModel := MooseModel importFromMSEStream: msePath asFileReference readStream.
mooseModel rootFolder: rootFolderPath.
mooseModel name: 'rca'.
mooseModel install.
"
Class {
	#name : #OOCriticsVisu,
	#superclass : #Object,
	#instVars : [
		'model'
	],
	#category : #OOAnalysis
}

{ #category : #'software visualization' }
OOCriticsVisu >> adherenceToExternalLibrary [
	<script: 'self new adherenceToExternalLibrary inspect'>
	^ (self model allNamespaces
		select: [ :n | n isStub and: [ n classes notEmpty ] ]
		thenCollect: [ :n | n -> n queryIncomingDependencies ]) asOrderedDictionary
]

{ #category : #'software visualization' }
OOCriticsVisu >> classDiagram [
	<script: 'self new classDiagram inspect'>
	| b v |
	b := RTMondrian new.
	b nodes: self model allModelClasses.
	b edges connectFrom: #superclass.
	b layout tree.
	b build.
	v := b view.
	v @ RTZoomableView.
	v @ RTDraggableView.
	^ v
]

{ #category : #'software visualization' }
OOCriticsVisu >> classesAttributes [
	<script: 'self new classesAttributes inspect'>
	^ (self model allModelClasses collect: [ :each | each -> each attributes size ]) asOrderedCollection
		sort: #value descending
]

{ #category : #'software visualization' }
OOCriticsVisu >> classesInPackagesHierarchy [
	<script: 'self new classesInPackagesHierarchy inspect'>
	| b v |
	b := RTMondrian new.
	b shape rectangle.
	v := b
		nodes: (self model allModelNamespaces flatCollectAsSet: #withAllParentScopes)
			forEach: [ :p | 
			b shape rectangle
				color: Color red;
				size: #numberOfLinesOfCode.
			b nodes: p classes.
			b edges connectFrom: #superclass.
			b layout tree ];
		edgesFrom: #parentScope;
		treeLayout;
		build;
		view.
	v @ RTDraggableView.
	v @ RTZoomableView.
	^ v
]

{ #category : #'software visualization' }
OOCriticsVisu >> computeCyclesInNamespaces [
	"(tarjan findNode: p) isInCycle"

	<script: 'self new classDiagram inspect'>
	| tarjan |
	tarjan := MalTarjan new.
	tarjan nodes: self model allModelNamespaces.
	tarjan edges: self model allModelNamespaces from: #yourself toAll: [ :a | a allProvidersAtScope: FamixTNamespace ].
	tarjan run.
	^ tarjan
]

{ #category : #'software visualization' }
OOCriticsVisu >> deadMethod [
	<script: 'self new deadMethod inspect'>
	^ (self model allModelMethods collect: [ :method | method -> method incomingInvocations ] thenSelect: [ :assoc | assoc value isEmpty ]) asOrderedCollection
]

{ #category : #'software visualization' }
OOCriticsVisu >> dependenciesWithCycles [
  < script: 'self new dependenciesWithCycles inspect'>
  (self model allUsing: FamixTNamespace) viewDependenciesWithCycles
]

{ #category : #'software visualization' }
OOCriticsVisu >> deprecatedClasses [
	<script: 'self new deprecatedClasses inspect'>
	^ self model allModelClasses
		select: [ :t | 
			t annotationInstances notEmpty
				and: [ t annotationTypes anySatisfy: [ :a | a name = 'Deprecated' ] ] ]
]

{ #category : #'software visualization' }
OOCriticsVisu >> deprecatedMethods [
	<script: 'self new deprecatedMethods inspect'>
	^ self model allModelMethods
		select: [ :t | 
			t annotationInstances notEmpty
				and: [ t annotationTypes anySatisfy: [ :a | a name = 'Deprecated' ] ] ]
]

{ #category : #'students visualization' }
OOCriticsVisu >> florianChevalier [
  < script: 'self new florianChevalier inspect'>
  | b |
  b := RTMondrian new.
  b shape
     rectangle;
     if: [:m |  m numberOfLinesOfCode < 50 ] fillColor: Color green;
     if: [:m |  m numberOfLinesOfCode >= 50 ] fillColor: Color orange;
     if: [:m |  m numberOfLinesOfCode >= 500 ] fillColor: Color red;
     withTextAbove: #name.
  b nodes: self model allModelClasses forEach: [:m |  b shape circle
           size: #numberOfLinesOfCode;
           if: [:method |  method incomingInvocations isEmpty ] fillColor: Color blue.
        b nodes: m methods.
        b layout verticalLine ].
  b edgesFrom: #parentPackage.
  b layout tree.
  b build.
  ^ b view
]

{ #category : #'software visualization' }
OOCriticsVisu >> godClassesByLines [
	<script: 'self new godClassesByLines inspect'>
	^ (self model allModelClasses select: [ :each | each numberOfLinesOfCode > 500 ] thenCollect: [ :each | each -> each numberOfLinesOfCode ]) sort: #value descending 
]

{ #category : #'software visualization' }
OOCriticsVisu >> godClassesByMethods [
	<script: 'self new godClassesByMethods inspect'>
	^ (self model allModelClasses select: [ :each | each numberOfMethods > 50 ] thenCollect: [ :each | each -> each numberOfMethods ]) sort: #value descending 
]

{ #category : #'software visualization' }
OOCriticsVisu >> godCyclomaticComplexity [
	<script: 'self new godCyclomaticComplexity inspect'>
	^ ((self model allBehaviourals) collect: [ :entity | entity -> entity cyclomaticComplexity ] thenSelect: [ :assoc | assoc value > 3 ])
		asOrderedCollection sort: #value descending
]

{ #category : #'software visualization' }
OOCriticsVisu >> mainMethods [
	"How handle the JavaFX application ? The Swing applications ? "

	<script: 'self new mainMethods inspect'>
	^ (self model allModelMethods select: [ :method | method name = 'main' ]) asOrderedCollection
]

{ #category : #accessing }
OOCriticsVisu >> model [
	^ model
		ifNil: [ MooseModel root allModels
				detect: [ :m | m name = self modelName ]
				ifNone: [ [ MooseModel root allModels first ]
						on: SubscriptOutOfBounds
						do: [ :exc | Error signal: 'Cannot perform analysis because no model is loaded into Moose.' ] ] ]
]

{ #category : #accessing }
OOCriticsVisu >> model: anObject [
	model := anObject
]

{ #category : #'software visualization' }
OOCriticsVisu >> modelDependenciesWithCycles [
	<script: 'self new dependenciesWithCycles inspect'>
	| view lb |
	view := RTMondrian new.
	((self model allUsing: FamixTNamespace) reject: [ :a | a isStub and: [ a classes isEmpty ] ]) viewDependenciesWithCyclesOn: view.
	
	lb := RTLegendBuilder new.
	lb view: view view.

	lb addText: 'Dependencies'.
	lb addRectanglePolymetricWidth: 'number of classes' height: 'number of methods' box: 'namespace'.
	lb addColor: Color red text: 'isInCycle'.
	lb build.
	
	view openWithToolbar title: 'Dependencies (cycles)'
]

{ #category : #'private - configuration' }
OOCriticsVisu >> modelName [
	^ 'rca'
]

{ #category : #'software visualization' }
OOCriticsVisu >> namespacesMetrics [
	"
	to string -> 
	self associationsSelect: [ :assoc | (assoc value at: #bunchCohesion) isNotNil and: [ (assoc value at: #bunchCoupling) isNotNil ] ].

	String streamContents: [ :aStream | self associationsDo: [:assoc | (aStream << assoc key asString).
		aStream << String crlf.
		assoc value associationsDo: [:each | aStream << '    '.
			aStream << each key asString.
			aStream << ' -> '.
			aStream << each value asString.
			aStream << String crlf]] ]"

	<script: 'self new packagesMetrics inspect'>
	^ ((self model allUsing: FamixTNamespace)
		collect: [ :namespace | namespace -> {(#bunchCoupling -> namespace bunchCouplingWithAll) . (#bunchCohesion -> namespace bunchCohesion)} asDictionary ])
		asDictionary
]

{ #category : #'software visualization' }
OOCriticsVisu >> packages [
	<script: 'self new packages inspect'>
	^ self model allModelNamespaces
]

{ #category : #'software visualization' }
OOCriticsVisu >> packagesDependencyComplexity [
	<script: 'self new packagesHierarchyWithComplexity inspect'>
	| b v lb |
	b := RTMondrian new.
	b shape rectangle
		width: [ :p | (p queryIncomingDependencies withoutSelfLoops atScope: FamixTNamespace) size * 2 ];
		height: [ :p | (p queryOutgoingDependencies withoutSelfLoops atScope: FamixTNamespace) size * 2 ];
		linearFillColor: #numberOfClasses within: self model allModelNamespaces entities;
		borderColor: Color lightGray.
	b interaction highlightEdges: [ :each | each queryIncomingDependencies withoutSelfLoops atScope: FamixTNamespace ].
	b nodes: self model allModelNamespaces.
	b edges
		connectToAll: [ :p | (p queryIncomingDependencies withoutSelfLoops atScope: FamixTNamespace) , (p queryOutgoingDependencies withoutSelfLoops atScope: FamixTNamespace) ].

	"1halt."
	b layout circle.
	v := b
		build;
		view.
	v @ RTZoomableView.
	v @ RTDraggableView.

	lb := RTLegendBuilder new.
	lb view: b view.

	lb addText: 'Dependencies'.
	lb addRectanglePolymetricWidth: 'incomingDependency' height: 'outgoingDependency' box: 'namespace'.
	lb addColorFadingFrom: Color white to: Color black text: 'numberOfClasses'.
	lb build.

	^ v
]

{ #category : #'software visualization' }
OOCriticsVisu >> packagesHierarchy [
	<script: 'self new packagesHierarchy inspect'>
	|v |
	
	v := RTMondrian new
		nodes: self model allModelNamespaces;
		edgesFrom: #parentScope;
		treeLayout;
		build;
		view.
	v @ RTZoomableView.
	v @ RTDraggableView.
	^ v
]

{ #category : #'software visualization' }
OOCriticsVisu >> packagesHierarchyWithComplexity [
	<script: 'self new packagesHierarchyWithComplexity inspect'>
	| b v lb |
	b := RTMondrian new.
	b shape rectangle
		width: [ :p | p numberOfClasses ];
		height: [ :p | p numberOfMethods ];
		linearFillColor: #numberOfLinesOfCode within: self model allModelNamespaces entities;
		borderColor: Color lightGray.
	v := b
		nodes: self model allModelNamespaces;
		edgesFrom: #parentScope;
		treeLayout;
		build;
		view.
	v @ RTZoomableView.
	v @ RTDraggableView.

	lb := RTLegendBuilder new.
	lb view: b view.

	lb addText: 'Dependencies'.
	lb addRectanglePolymetricWidth: 'number of classes' height: 'number of methods' box: 'namespace'.
	lb addColorFadingFrom: Color white to: Color black text: 'numberOfLinesOfCode'.
	lb build.
	
	^ v
]

{ #category : #'software visualization' }
OOCriticsVisu >> testMethods [
	<script: 'self new testMethods inspect'>
	^ (self model allModelMethods
		select: [ :t | 
			t annotationInstances notEmpty
				and: [ t annotationTypes anySatisfy: [ :annotation | annotation name endsWith: 'Test' ] ] ])
		asOrderedCollection flattened
]

{ #category : #'students visualization' }
OOCriticsVisu >> yoannEon [
  < script: 'self new yoannEon inspect'>
  | b |
  b := RTMondrian new.
  b nodes: self model allModelClasses.
  b edgesFrom: #superclass .
  b normalizer normalizeColor: #numberOfLinesOfCode using: {Color white . 
        Color black} min: 0 max: 1000.
  b layout tree.
  b build.
  ^ b view
]
