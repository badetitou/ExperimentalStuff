private view
collectPackageColors: aRTView
	^(aRTView elements
		collectAsSet: [ :e | e model namespaceScope -> e color ])
		asOrderedCollection sorted: [ :x :y | x key mooseName <= y key mooseName ]