Class {
	#name : #BaselineOfOOAnalysis,
	#superclass : #BaselineOf,
	#category : #BaselineOfOOAnalysis
}

{ #category : #baselines }
BaselineOfOOAnalysis >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec ]
]

{ #category : #baselines }
BaselineOfOOAnalysis >> customProjectAttributes [
    self class environment at: #MooseEntity ifAbsent: [ ^ #(#WithoutFamix) ].

    ^ #()
]

{ #category : #baselines }
BaselineOfOOAnalysis >> defineDependencies: spec [
	
]

{ #category : #baselines }
BaselineOfOOAnalysis >> defineGroups: spec [
]

{ #category : #baselines }
BaselineOfOOAnalysis >> definePackages: spec [
	spec package: 'OOAnalysis'.

	spec for: #(#WithoutFamix) do: [ 
		spec baseline: 'Moose' with: [ spec repository: 'github://moosetechnology/Moose:development/src' ].
		spec package: 'OOAnalysis' with: [ spec requires: #('Moose') ] ]
]
