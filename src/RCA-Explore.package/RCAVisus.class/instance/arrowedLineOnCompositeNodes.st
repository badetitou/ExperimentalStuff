private - utilities
arrowedLineOnCompositeNodes
	^ RTArrowedLine new
		attachPoint:
			(RTShorterDistanceAttachPointAndCompositeShape new
				composedShapeSelection: #second)