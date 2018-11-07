private view
arrowedLineOnCompositeNodes
	^ RTArrowedLine new
		attachPoint:
			(RTShorterDistanceAttachPointAndCompositeShape new
				composedShapeSelection: #second)