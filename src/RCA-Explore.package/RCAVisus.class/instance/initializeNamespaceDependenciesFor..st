private  model
initializeNamespaceDependenciesFor: entities
	dependencyMatrix := Dictionary new.
	entities
		do:
			[ :p | dependencyMatrix at: p put: (p queryOutgoingDependencies withoutSelfLoops opposites asOrderedCollection groupedBy: #namespaceScope) ].