grep -r "transition.to" . | grep -v "Memmory.transitionStash"
grep -r "timer.performWithDelay" . | grep -v "Memmory.timerStash"
grep -r "physics.addBody" . | grep -v "Memmory.trackPhys"
