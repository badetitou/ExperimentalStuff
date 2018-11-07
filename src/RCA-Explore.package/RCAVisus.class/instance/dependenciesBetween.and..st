private  model
dependenciesBetween: aFamixEntity and: aNamespace
	^ (dependencyMatrix at: aFamixEntity ifAbsent: [ Dictionary new])
			at: aNamespace ifAbsent: [ #()]