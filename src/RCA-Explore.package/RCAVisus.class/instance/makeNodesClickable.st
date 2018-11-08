private view
makeNodesClickable
	(builder view elements) when: TRMouseClick do: [ :evt | evt element model inspect ]