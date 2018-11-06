private - utilities
dependenciesToModelNamespaces: aFamixEntity
	^ (aFamixEntity queryOutgoingDependencies atScope: FAMIXNamespace) withoutSelfLoops
			reject: #isStub