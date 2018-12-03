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
	#name : #RCACriticsVisu,
	#superclass : #Object,
	#instVars : [
		'model'
	],
	#category : #'RCA-Explore'
}

{ #category : #'software visualization' }
RCACriticsVisu >> adherenceToExternalLibrary [
	<script: 'self new adherenceToExternalLibrary inspect'>
	^ (model allNamespaces
		select: [ :n | n isStub and: [ n classes notEmpty ] ]
		thenCollect: [ :n | n -> n queryIncomingDependencies ]) asOrderedDictionary
]

{ #category : #'software visualization' }
RCACriticsVisu >> classDiagram [
	<script: 'self new classDiagram inspect'>
	| b |
	b := RTMondrian new.
	b nodes: model allModelClasses.
	b edges connectFrom: #superclass.
	b layout tree.
	b build.
	^ b view
]

{ #category : #'software visualization' }
RCACriticsVisu >> classesAttributes [
	<script: 'self new classesAttributes inspect'>
	^ model allModelClasses
		sort: [ :classeA :classeB | classeA attributes size > classeB attributes size ]
]

{ #category : #'software visualization' }
RCACriticsVisu >> classesInPackagesHierarchy [
	<script: 'self new classesInPackagesHierarchy inspect'>
	| b |
	b := RTMondrian new.
	b shape rectangle.
	^ b
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
		view
]

{ #category : #'software visualization' }
RCACriticsVisu >> deadMethod [
	<script: 'self new deadMethod inspect'>
	^ (model allModelMethods collect: #incomingInvocations thenSelect: #isNotEmpty)
		asOrderedCollection
]

{ #category : #'software visualization' }
RCACriticsVisu >> deprecatedClasses [
	<script: 'self new deprecatedClasses inspect'>
	^ model allModelClasses
		select: [ :t | 
			t annotationInstances notEmpty
				and: [ t annotationTypes anySatisfy: [ :a | a name = 'Deprecated' ] ] ]
]

{ #category : #'software visualization' }
RCACriticsVisu >> godClassesByLines [
	<script: 'self new godClassesByLines inspect'>
	^ model allModelClasses select: [ :each | each numberOfLinesOfCode > 150 ]
]

{ #category : #'software visualization' }
RCACriticsVisu >> godClassesByMethods [
	<script: 'self new godClassesByMethods inspect'>
	^ model allModelClasses select: [ :each | each numberOfMethods > 50 ]
]

{ #category : #initialization }
RCACriticsVisu >> initialize [
	model := MooseModel root allModels detect: [ :m | m name = self modelName ]
]

{ #category : #'software visualization' }
RCACriticsVisu >> mainMethods [
	"How handle the JavaFX application ? The Swing applications ? "

	<script: 'self new mainMethods inspect'>
	^ (model allModelMethods select: [ :method | method name = 'main' ]) asOrderedCollection
]

{ #category : #'private - configuration' }
RCACriticsVisu >> modelName [
	^ 'rca'
]

{ #category : #'software visualization' }
RCACriticsVisu >> packages [
	<script: 'self new packages inspect'>
	^ model allModelNamespaces
]

{ #category : #'software visualization' }
RCACriticsVisu >> packagesHierarchy [
	<script: 'self new packagesHierarchy inspect'>
	^ RTMondrian new
		nodes: model allModelNamespaces;
		edgesFrom: #parentScope;
		treeLayout;
		build;
		view
]

{ #category : #'software visualization' }
RCACriticsVisu >> packagesHierarchyWithComplexity [
	<script: 'self new packagesHierarchyWithComplexity inspect'>
	| b |
	b := RTMondrian new.
	b shape rectangle
		width: [ :p | p numberOfClasses ];
		height: [ :p | p numberOfMethods ];
		linearFillColor: #numberOfLinesOfCode within: model allModelNamespaces entities;
		borderColor: Color lightGray.
	^ b
		nodes: model allModelNamespaces;
		edgesFrom: #parentScope;
		treeLayout;
		build;
		view
]

{ #category : #'software visualization' }
RCACriticsVisu >> testMethods [
	<script: 'self new testMethods inspect'>
	^ (model allModelMethods
		select: [ :t | 
			t annotationInstances notEmpty
				and: [ t annotationTypes anySatisfy: [ :annotation | annotation name endsWith: 'Test' ] ] ])
		asOrderedCollection flattened
]
