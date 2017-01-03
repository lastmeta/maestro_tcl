
DONE:
6. I'm thinking when maestro comes online and is told it's environment it should send a 0 action to it to ask what state it's in. 0 can be a "I'm doing nothing action"




NODES: we have several problems:

0. the node id in connectom is not acurate at all.
1. action cells aren't connecting to anything! - all zeros.
2. once that's fixed we have to fix the intuition removeZeros
3. and alreadyBeenTried
4. and splitNode (into input state, and action to take)
5. and then finish up the recall main where we loop through intuition to get a path.


GENERAL:

1. predictions does not put in actions.
2. not recording the right stuff on generals. therefore not path finding right.
3. randomly will just stop when try or explore which means while try. seems to only happen after sleep and do.
    This is because prepdata combos returns a randomized list so it matches on random ones. going back and forth and back and forth.
    ??? maybe?
4. tried to fix above, problem persists, so maybe its a problem with the order anyway.
5. noticed it doesn't record chains correctly.
6. lsort seems to sort things differently for numbers vs letters vs underscore could this be the problem? I could sort manually.
