So! we're hoping that we can more easily process the node and connectom information than we can the main table for finding individual interactions between bits of the data. So the Theory is given a state (theoretical state most likely, a state we've never seen before) can we trace back the actions and states that get us to that state from some state we've seen before. that's what we're looking for - a pattern we recognize. then we can take that to the main table and using recall (candle technique) we can achieve the shortest possible distance between the two states, get the actions and go there.

So! the question is How can we do that? I was thinking we might be able to do that in the following way:

1. get the highest connection scores for all cells leading this this node....

2. on this particular digit. that...

3. does not disallow any other currently active node. and...

4. that does not equal the same as the currently active nodes.

So lets image what that means by taking an example.

lets take an environment that has two actions and two digits in it's state representation.
  Actions:  A B
  STATES:   1 4
            1 5
            1 6
            2 4
            2 5
            2 6
            3 4
            3 5
            3 6

Here's what the actions do.
  B:
    _ 4  ->  _ 5      (4 and anything goes to 5 and anything)
    3 6  ->  1 6      (3 and 6 goes to 1 and 6)
                      (on all other states this action has no effect)

  A:
    1 _  ->  2 _      (1 and anything goes to 2 and anything)
    2 5  ->  3 6      (2 and 5 goes to 3 and 6)
    3 6  ->  3 4      (3 and 6 goes to 3 and 4)
                      (on all other states this action has no effect)

This produces the following graph:

      (A: means the action returns you to 34)

                  A:
                34 <--- A    
               /  \      \
            A /  B \      \   
             /      \  A:  \
           24        35     |
          /  \         B:   |  
       A /  B \             |
        /      \      A     |    A    
      14        25 ------> 36 <----- 26
        \      /  B:         \      /  B:
       B \  A /             B \  A /
          \  /                 \  /
           15                   16
                                  B:

Ok, so we can visually see what each state leads to given either action. very fun. So we know that if this structure was explored the connectom would look something like this: (these are the counts for how many times the left side goes to the top) so the 2nd number (3) is how many times 1 has been followed by 2 in this structure.

                    Goes To  NODES
              A   B   1   2   3   4   5   6
      f   A   -   -   -   -   -   -   -   -
      r   B   -   -   -   -   -   -   -   -
      o   1   -   -   3   3   0   1   3   2
      m   2   -   -   0   3   3   1   2   3
      N   3   -   -   1   0   5   3   3   0
      O   4   -   -   1   2   2   2   2   0
      D   5   -   -   1   2   3   0   5   1
      E   6   -   -   2   2   2   1   0   5

So! lets give it an option we know for sure where it came from - 35. If I gave this the state of 35 we already know the only way to get there is through 34 using the B action. so if we were trying to figure this out from the db we'd count up the things that lead 35 and then prune it down.


              Goes To  NODES
              3   5
              -----
          1|  0   3
      N   2|  3   2   
      O   3|  5   3   
      D   4|  2   2   
      E   5|  3   5   
      S   6|  2   0

Now that we have a list of candidates, lets prune that list

            Goes To  NODES
              3   5
              -----
          1|  0   3   <--- 1 cannot lead to 3 ever so its no good
      N   2|  3   2   
      O   3|  5   3   <---|
      D   4|  2   2       |--- 3 and 5 are possible, but not together - its a repeat of what we have active now.
      E   5|  3   5   <---|
      S   6|  2   0   <--- 6 cannot lead to 5 ever so its no good


So that leaves us with the following

            Goes To  NODES
              3   5
              -----
      N   2|  3   2   
      O   3|  5   3   <---|
      D   4|  2   2       |--- not together
      E   5|  3   5   <---|


Which means we now have to look at what nodes are part of which digits. We would consult node table for this information. 2 and 3 are the first digit and 4 and 5 are the second digit so we have these combinations of particular states as candidate states that could have lead to 35:

          2 4
          2 5
          3 4

So, if these are the options we have to narrow it down.

              Goes To  NODES
              3   5
              -----
      N   2|  3 + 2 = 5  
      O   3|  5 + 3 = 8  
      D   4|  2 + 2 = 4   
      E   5|  3 + 5 = 8

          2 4 = 4 + 5
          2 5 = 4 + 8
          3 4 = 8 + 4

At this point I'm not sure If I'm doing it right, but to get the most likely active nodes to lead to this set of active nodes (35) we should be able to add up the nodes that individually lead to these numbers right?

          2 4 |9
          2 5 |12
          3 4 |12

So we have a list of things we think might lead to 35. and 34 is in that list. We could at this point return the whole list or repeat the process on each item in the list (perhaps in order of their likeliness) to find something in the main table that would would be an option to travel to and explore. I'm not to happy about just adding up aggregates but whatever.

I feel like there should be an even more fine tuned way to do this - like a next step that prunes it down even further or something. Well we could look in the main table and say, look have I seen 24, 25, or 34? if so have I done every action at those locations? if no, then perhaps we go to one of those locations and do the actions that are missing. Now, what about actions, I didn't include them but theoretically they're no different than different indexes of the state. so lets explore that together now.


                    Goes To  NODES
              A   B   1   2   3   4   5   6
          A   -   -   0   3   8   4   4   6
          B   -   -   4   3   2   0   6   3





EXTRA IDEA:
(this could be the foundation for a better "curious" search too. It could make up a combination of nodes it's never seen before and attempt to get there using this method. as it travels it will learn how to get to something like what it imagined better - like dreaming - and you could make this adaptive: if it's easily getting to what it imagines make what it imagines crazier like less and less bits being familiar, if it it is having a hard time getting to its dreams make them more like baby steps, just substituting one digit as being different - of course this presupposes that the data will be somewhat semantically encoded, but that should usually be the case and if its not, it'll still work, just more slowly).
