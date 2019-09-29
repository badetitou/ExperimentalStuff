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
	^ (model allNamespaces
		select: [ :n | n isStub and: [ n classes notEmpty ] ]
		thenCollect: [ :n | n -> n queryIncomingDependencies ]) asOrderedDictionary
]

{ #category : #'software visualization' }
OOCriticsVisu >> classDiagram [
	<script: 'self new classDiagram inspect'>
	| b v |
	b := RTMondrian new.
	b nodes: model allModelClasses.
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
	^ model allModelClasses
		sort: [ :classeA :classeB | classeA attributes size > classeB attributes size ]
]

{ #category : #'software visualization' }
OOCriticsVisu >> classesInPackagesHierarchy [
	<script: 'self new classesInPackagesHierarchy inspect'>
	| b v |
	b := RTMondrian new.
	b shape rectangle.
	v := b
		nodes: (model allModelNamespaces flatCollectAsSet: #withAllParentScopes)
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
OOCriticsVisu >> deadMethod [
	<script: 'self new deadMethod inspect'>
	^ (model allModelMethods collect: #incomingInvocations thenSelect: #isNotEmpty)
		asOrderedCollection
]

{ #category : #'software visualization' }
OOCriticsVisu >> deprecatedClasses [
	<script: 'self new deprecatedClasses inspect'>
	^ model allModelClasses
		select: [ :t | 
			t annotationInstances notEmpty
				and: [ t annotationTypes anySatisfy: [ :a | a name = 'Deprecated' ] ] ]
]

{ #category : #'software visualization' }
OOCriticsVisu >> godClassesByLines [
	<script: 'self new godClassesByLines inspect'>
	^ model allModelClasses select: [ :each | each numberOfLinesOfCode > 150 ]
]

{ #category : #'software visualization' }
OOCriticsVisu >> godClassesByMethods [
	<script: 'self new godClassesByMethods inspect'>
	^ model allModelClasses select: [ :each | each numberOfMethods > 50 ]
]

{ #category : #initialization }
OOCriticsVisu >> initialize [
	model := MooseModel root allModels
		detect: [ :m | m name = self modelName ]
		ifNone: [ [ MooseModel root allModels first ]
				on: SubscriptOutOfBounds
				do: [ :exc | 
					Error
						signal: 'Cannot perform analysis because no model is loaded into Moose.' ] ]
]

{ #category : #'software visualization' }
OOCriticsVisu >> mainMethods [
	"How handle the JavaFX application ? The Swing applications ? "

	<script: 'self new mainMethods inspect'>
	^ (model allModelMethods select: [ :method | method name = 'main' ]) asOrderedCollection
]

{ #category : #'private - configuration' }
OOCriticsVisu >> modelName [
	^ 'rca'
]

{ #category : #'software visualization' }
OOCriticsVisu >> packages [
	<script: 'self new packages inspect'>
	^ model allModelNamespaces
]

{ #category : #'software visualization' }
OOCriticsVisu >> packagesHierarchy [
	<script: 'self new packagesHierarchy inspect'>
	|v |
	
	v := RTMondrian new
		nodes: model allModelNamespaces;
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
	| b v |
	b := RTMondrian new.
	b shape rectangle
		width: [ :p | p numberOfClasses ];
		height: [ :p | p numberOfMethods ];
		linearFillColor: #numberOfLinesOfCode
			within: model allModelNamespaces entities;
		borderColor: Color lightGray.
	v := b
		nodes: model allModelNamespaces;
		edgesFrom: #parentScope;
		treeLayout;
		build;
		view.
	v @ RTZoomableView.
	v @ RTDraggableView.
	^ v
]

{ #category : #'software visualization' }
OOCriticsVisu >> testMethods [
	<script: 'self new testMethods inspect'>
	^ (model allModelMethods
		select: [ :t | 
			t annotationInstances notEmpty
				and: [ t annotationTypes anySatisfy: [ :annotation | annotation name endsWith: 'Test' ] ] ])
		asOrderedCollection flattened
]
