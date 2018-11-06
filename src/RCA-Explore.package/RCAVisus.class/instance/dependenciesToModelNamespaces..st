private - utilities
dependenciesToModelNamespaces: aFamixEntity
	^ (aFamixEntity queryOutgoingDependencies atScope: FAMIXNamespace) withoutSelfLoops
			reject: #isStub "select: [ :n | n mooseName beginsWith: self defaultJavaPackagePrefix ]"