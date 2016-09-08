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

Ok, so we can visually see what each state leads to given either action. very fun. So we know that if this structure was explored the connectom would look something like this: (these are the counts for how many times the left side goes to the top) so the 2nd number (3) is how many times 1 has been followed by 2 in this structure. This structure assumes one cell per node.

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

Now that we have a list of candidates, lets prune that list.

            Goes To  NODES
              3   5
              -----
          1|  0   3   <--- 1 cannot lead to 3 ever so its no good
      N   2|  3   2   
      O   3|  5   3   <---|
      D   4|  2   2       |--- 3 and 5 are possible, but not together - its a repeat of what we have active now.
      E   5|  3   5   <---|
      S   6|  2   0   <--- 6 cannot lead to 5 ever so its no good


So that leaves us with the following. The hope here is that there are lots of 0's - things that have never happened before and we can assume wont happen forever. If there are we can prune this down a lot. the more we explore the fewer zeros there will be you would think, but that's not necessarily true, because the more we explore the more nodes will be created and instantiated with all zeros so it'll take quite a bit exploring to get there. UPDATE! as I've been programming this I've decided removing the zeros is premature at this point. Just because we've never seen something happen before doesn't mean that it can't and what if we remove the ones with zeros then we have nothing left? No, the best way is to move those to the bottom of the list later instead of removing them now. Even if there's a crazy high correlation on say, node 1 below for node 5 if there is a 0 in the list no matter, move it to the bottom of the list of candidates.

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

So we have a list of things we think might lead to 35. and 34 is in that list. We could at this point return the whole list or repeat the process on each item in the list (perhaps in order of their likeliness) to find something in the main table that would would be an option to travel to and explore. I'm not to happy about just adding up aggregates but whatever. it maybe better to create a score out of the median and the aggregate or something, idk, at that point i think you're just trying to do surgery with a butchers knife - what you really want is a fine tuned model comparison, with all the precision of a scalpel, not aggregated blunt objects. But at the moment I'm afraid this is the best I can do. Is it good enough?

I feel like there should be an even more fine tuned way to do this - like a next step that prunes it down even further or something. Well we could look in the main table and say, look have I seen 24, 25, or 34? if so have I done every action at those locations? if no, then perhaps we go to one of those locations and do the actions that are missing. Now, what about actions, I didn't include them but theoretically they're no different than different indexes of the state. so lets explore that together now.


                    Goes To  NODES
              A   B   1   2   3   4   5   6
          A   -   -   0   3   8   4   4   6
          B   -   -   4   3   2   0   6   3

              3   5
          A   8 + 4 = 12
          B   2 + 6 = 8

so then our options really become:

      A 2 4 |21    <--- second place
      B 2 4 |17    <--- fourth place
      A 2 5 |24    <--- first  place
      B 2 5 |20    <--- third  place
      A 3 4 |24    <--- first  place
      B 3 4 |20    <--- third  place *** actual solution ***


You can see how having actions affect only one thing in the environment would be useful, or how having as few actions as possible is efficient. What you might do is score them separately so first you do this

      3 4 |12
      2 5 |12
      2 4 |9

then you say, which action should I take at each location

      A| 12
      B| 8

so then you get this list in order of what to try:

      A   34
      A   25
      B   34
      B   25
      A   24
      B   24

In this case the top scores were the same (12) so 34 and 25 are interwoven. So you would come across the correct solution after 3 or 4 attempts.

With this strategy we may not want to have a decrement unless its a percentage and never reaches 0. we want a clear distinction between what is never seen and what is rare. we may also want to have the threshold (if we need a threshold at all) to be a percentage of the highest connection on the map, idk.

Also once we have a list of states and actions could we not play it forward and say, well if I did this here whats the most likely thing to show up out of all the options and if the answer to that closely matches our thing make that one our top prospect.

Last thing I'll say on this topic, it may be the case that if you were to do this multiple times and make long chains, you could evaluate the chains as a whole and say, oh this chain is more likely to succeed than that chain. But aside from seeing of the states are in main I'm not sure how you would do this. Anyway, I think this has potential to be useful, and maybe improve speed at which we come to intuitive understandings, but all this information I think is in main (unrepeated) and maybe that would be faster. we'll have to consider it, however since its unrepeated we'll get vastly different scores. for instance lets say there's a bottle neck in the space where you have to take a particular action to get a common outcome, if this is unique it may be represented in main only once, but count in connectom thousands of times. we could however, make a simpler table than connectom if all we need to do is count the number of times we see each node. idk. for now we'll use connectom.

sorry, one last thing I thought about. this entire example has used the assumption that we're using 1 cell per node. but if we were to use more than one cell per node we might be able to get a better insight by analyzing what context the hypothetical state should be in and following those particular cells backwards like we do above. However, since that adds an extra and exponential layer of complexity what I think we're going to do instead is only use 1 cell per node until we're ready to do more, and maybe even for this naive intuition always use the aggregate of connections regardless of how many cells are in the node.

EXTRA IDEA:
(this could be the foundation for a better "curious" search too. It could make up a combination of nodes it's never seen before and attempt to get there using this method. as it travels it will learn how to get to something like what it imagined better - like dreaming - and you could make this adaptive: if it's easily getting to what it imagines make what it imagines crazier like less and less bits being familiar, if it it is having a hard time getting to its dreams make them more like baby steps, just substituting one digit as being different - of course this presupposes that the data will be somewhat semantically encoded, but that should usually be the case and if its not, it'll still work, just more slowly).

Extra twist:
We may be able to better order and thereby limit the list of candidates by first comparing the theoretical state with the closest match in the main table. Then find the list of things we think could lead to it. Then compare that list with the thing that lead to the item in the main table that was most like your theoretical state. and order my list of candidates based one how closely they match that one (or an average of close ones). Then we can more easily perform the thing again and the longer the chain we can make with the best matching scores maybe the better? probably not, but we'll see.

```
I wish we could do this a different way - make a causal map (like the diagram way above) using the main as our guide then make a mapping between state changes and its relative position on the map. because what I'm trying to do in all this intuition idea is create a structure that I can pattern match against to give my program the ability to reason by analogy.
```
