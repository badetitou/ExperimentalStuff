private view
makeLinksClickable
	(builder view edges) when: TRMouseClick do: [ :evt || from to|
		from := evt element from model.
		to := evt element to model.
		(self dependenciesBetween: from and: to) inspect
	]