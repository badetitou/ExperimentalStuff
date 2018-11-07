private view
zoomableMondrianBuilder
	| blr |
	blr := RTMondrian new.
	blr view @ RTZoomableView.
	^ blr