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
	<script: 'RCACriticsVisu new adherenceToExternalLibrary inspect'>
	^ (model allNamespaces
		select: [ :n | n isStub and: [ n classes notEmpty ] ]
		thenCollect: [ :n | n -> n queryIncomingDependencies ]) asOrderedDictionary
]

{ #category : #'software visualization' }
RCACriticsVisu >> classDiagram [
	<script: 'RCACriticsVisu new classDiagram inspect'>
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
	<script: 'RCACriticsVisu new classesAttributes inspect'>
	^ model allModelClasses sort: [ :classeA :classeB | classeA attributes size > classeB attributes size ]
]

{ #category : #'software visualization' }
RCACriticsVisu >> classesInPackagesHierarchy [
	<script: 'RCACriticsVisu new classesInPackagesHierarchy inspect'>
	| b |
	b := RTMondrian new.
	b shape rectangle.
	^ b
		nodes: model allModelNamespaces
			forEach: [ :p | 
			b shape rectangle
				color: Color red;
				size: #numberOfLinesOfCode.
			b nodes: p classes.
			b edges connectFrom: #superclass. b layout tree ];
		edgesFrom: #parentScope;
		treeLayout;
		build;
		view
]

{ #category : #'software visualization' }
RCACriticsVisu >> deadMethod [
	<script: 'RCACriticsVisu new deadMethod inspect'>
	^ (model allModelMethods collect: #incomingInvocations thenSelect: #isNotEmpty) asOrderedCollection
]

{ #category : #'software visualization' }
RCACriticsVisu >> deprecatedClasses [
	<script: 'RCACriticsVisu new deprecatedClasses inspect'>
	^ model allModelClasses
		select: [ :t | 
			t annotationInstances notEmpty
				and: [ t annotationTypes anySatisfy: [ :a | a name = 'Deprecated' ] ] ]
]

{ #category : #'software visualization' }
RCACriticsVisu >> godClassesByLines [
	<script: 'RCACriticsVisu new godClassesByLines inspect'>
	^ (model allModelClasses select: [ :each | each numberOfLinesOfCode > 150 ])
]

{ #category : #'software visualization' }
RCACriticsVisu >> godClassesByMethods [
	<script: 'RCACriticsVisu new godClassesByMethods inspect'>
	^ (model allModelClasses select: [ :each | each numberOfMethods > 50 ])
]

{ #category : #initialization }
RCACriticsVisu >> initialize [
	model := MooseModel root allModels detect: [:m | m name = 'rca']
]

{ #category : #'software visualization' }
RCACriticsVisu >> mainMethods [
	"How handle the JavaFX application ? The Swing applications ? "

	<script: 'RCACriticsVisu new mainMethods inspect'>
	^ (model allModelMethods select: [ :method | method name = 'main' ]) asOrderedCollection 
]

{ #category : #'software visualization' }
RCACriticsVisu >> packages [
	<script: 'RCACriticsVisu new packages inspect'>
	^ (model allModelNamespaces)
]

{ #category : #'software visualization' }
RCACriticsVisu >> packagesHierarchy [
	<script: 'RCACriticsVisu new packagesHierarchy inspect'>
	^ RTMondrian new
		nodes: model allModelNamespaces;
		edgesFrom: #parentScope;
		treeLayout;
		build;
		view
]

{ #category : #'software visualization' }
RCACriticsVisu >> packagesHierarchyWithComplexity [
	<script: 'RCACriticsVisu new packagesHierarchyWithComplexity inspect'>
	| view |
	view := RTMondrian new.
	view shape rectangle
			width: [ :p | p numberOfClasses ];
			height: [ :p | p numberOfMethods ];
			linearFillColor: #numberOfLinesOfCode within: model allModelNamespaces entities;
			borderColor: Color lightGray.
	^ view
		nodes: model allModelNamespaces;
		edgesFrom: #parentScope;
		treeLayout;
		build;
		view
]
