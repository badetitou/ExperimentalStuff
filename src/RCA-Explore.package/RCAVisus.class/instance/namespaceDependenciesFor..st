private  model
namespaceDependenciesFor: aNamespace
	^ (dependencyMatrix at: aNamespace) values flatten asSet collect: #namespaceScope