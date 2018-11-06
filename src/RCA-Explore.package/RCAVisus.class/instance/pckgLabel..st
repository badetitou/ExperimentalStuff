private - utilities
pckgLabel: aNamespace
	^ (aNamespace mooseName withoutPrefix: self defaultJavaPackagePrefix)
			copyReplaceAll: '::' with: '.'