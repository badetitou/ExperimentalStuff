private  model
topNamespaceFor: aFamixEntity
	"returns the top namespace of the system or one of its direct children"
	| namespace |
	namespace := aFamixEntity namespaceScope.
	(namespace mooseName = self defaultJavaPackagePrefix) ifTrue: [ ^ namespace ].
	(namespace parentScope mooseName = self defaultJavaPackagePrefix) ifTrue: [ ^ namespace ].
	^ self topNamespaceFor: namespace parentScope
