private  model
is: p inCycle: cycleCalculator
	^ (cycleCalculator findNode: p) isInCycle