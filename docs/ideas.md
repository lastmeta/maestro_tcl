1. NOTE
Here I have some ideas about how to generalize stuff, but there are many more ideas in the naisen project if you have access to that you can see the evolution of many of these ideas.


2. MODIFIED HTM COLUMN ALGORITHM
My idea for making a pattern recognition piece that dynamically and automatically resizes itself to the size and complexity of the data is to make a new "node" or column each time a new symbol is found in a specific index of the input and each action taken - which technically could be seen by the system as an index of the input.

the state representation of 000 gives us 3 nodes. 001 is seen and another node is created.

  node    index   symbol
  0       0       0
  1       1       0
  2       2       0
  3       2       1

Then each time we create a node we create an extra node that is relatively randomly connected to all existing nodes. for example if there are 10 nodes it has the chance to be connected to the last node at 100% and the first one at 10%. 100 is 1% to 100%. Now this half of the nodes may be the only half we need. But maybe not. idk. These ones are dynamic - they reduce their connections and increase their connections just like HTM.


  node    cell    connections to other cells
  0       0       0 0 0 0 0
  0       1       0 0 0 0 0
  1       2       0 0 0 0 0
  1       3       0 0 0 0 0
  2       4       0 0 0 0 0
  3       5       0 0 0 0 0

The reason these are cool is we can then make any number of cells in the nodes. If a node is seen a lot or we should say in a lot of different contexts we can put many cells in the node. But if a certain node is almost never activated then forget it, we don't need many cells in that node because they would be redundant. So each time you see a node active in a different set of active node neighbors you make a new cell in that node.

Then when actions are made and the program is exploring like normal we create and destroy connections between cells - not between nodes. That way if a specific set of cells fire we know exactly what is coming next, and if we get a state representation we've never seen before we can extrapolate what is the correct next representation by summing all the connections from all the cells in the active nodes.

3. CONCERNS THAT I'M USING A COMPLICATED NEURAL NET TO ACHIEVE SOMETHING THAT COULD BE DONE NAIVELY.

I'm worried that everything I described in 2 is a very silly way to just look at the entire main table and just run statistical analysis on everything we've ever seen before.  


4. ON THE VALUE OF THE NODE CELL ARCHITECTURE

I think that the value of this structure that I'm building with cells and nodes isn't really seen until I find a way to naturally query the structure. Not just having a state representation naturally activate semantic memories, but also find a path to a goal using this structure, or a structure of many instances of this structure. For instance if there was another layer that put many cells in a special pseudo-predictive state to guide temporal activity to a specific path to work with other structures on the same level.

5. SPEAKING OF A HIERARCHY...

I wondered how to do a hierarchy appropriately for the longest time! Perhaps we reduce familiar representations to specific ones and pass those up the hierarchy so that on each level the representations reduce by one index or something. I think that might be the best way to do it. The goal is to let the higher structures observe and generalize patterns from the lower structures so that it can coordinate their efforts with each other without having to know the details of their paths. And what would it be passing up exactly?

Could it pass up the longest correctly predicted pattern as a name for this pattern its learned? meaning if it sees nodes: 1 4 5, 4 7 2, 5 2 2. It might send up 1 2 4 5 7 as a pattern? It might not need the longest recognized pattern, but a recognized pattern of a specific length? 2 time series, etc.? How would that make the representation simplified? It seems like its reduced in time, but not reduced in space. Well, it needs to know the correct nodes to activate on the lower levels, so perhaps sending up that name is really the best. Therefore it doesn't send up everything it sees it only sends up things it predicts correctly. This is kind of the opposite idea of HTM when it only sends up stuff it doesn't know how to deal with - patterns that were unexpected.

Another option to fix the space is to invert the space. Go with me. If you have a 2-digit state representation we might could have 2 agents at the first level, each that only sees 1 index and the state representation is basically recreated in the top level but not in state form, but in node form that have maps to states in the lower levels. that way we have a hard limit to how complex the data gets on the highest level and the time series data is managed well too. That way if you have a 4-digit state we would have 4 on the bottom, 2 in the middle and 1 on the top. The bottom would only memorize 2 time steps, the middle would learn 2 of those - effectively 4, and the top would learn 2 of those, effectively 8 steps into the future.

So here's how it would work from the top down? With 2 levels we would necessarily have 3 agents. the lower states would get a state representation that the user wants them to make happen. They already have a mapping to those nodes, so they'd send up which nodes that state rep maps to. Then the higher agent would try to figure out the general path of how to get from where it is to the nodes that the lower agents representations map to in the higher agent. It would send down the names of the learned paths for the lower agents to do at the same time.

6. GENERALIZATION

I think generalization is a combination of two things which are actually one and the same on a small scale and on a large scale: probability and reasoning by analogy or having frameworks.

For instance you throw a ball to me and I've never seen a ball thrown at me in the exact way you're throwing it to me. But I have caught a ball before, in fact many times. I have developed connects between cells that have learned "what its like" to catch a ball. They make predictions and those predictions are based on past experience - they mirror the odds of the ball's behavior. Odds are it will arch down at this predictable rate. Here I've tried to come up with a micro example of how the mind approximates odds given a small pattern. But truly this is a macro example because perhaps most micro examples happen subconsciously.

Oh well, let me give you a macro example now. You walk into a restaurant and sit down to eat. You have a macro framework for this experience. Even though you haven't seen the door to a restroom you know there is one somewhere around, probably in the back. You know that the waiter will come take your order. Even if you aren't seeing these patterns (such as a sign to the restroom) you know the odds are that pattern is present if you went and searched for it. The framework in other words is a collection of patterns that typically (probably) occur together.

Thus generalization, in my estimation can be approximated by nothing more than: 1. pattern recognition and 2. statistical probabilities on all levels from the micro and macro scales. This is perhaps the main reason I'm so obsessed with the idea of a hierarchy - because generalization must happen on all levels, and should probably be a conversation between levels. For instance a high level may say, "I expect we'll find a restroom somewhere near here." But if indeed there is no public restroom the lower levels need to send up information so that the higher level can say, "mmm. I was wrong in this case. My prediction was incorrect based upon the odds I've surmised from my framework. What is different about this instance that may lead to better predictions about this framework in the future? Is there something unique here which can give me a hint next time I notice it that there isn't a restroom in this building? Oh I see, this restaurant is part of a strip mall. I will increase the connection between my 'strip mall' pattern and my 'no restroom in store' pattern so that next time that will highly influence my estimation of the odds of finding a restroom in a restaurant in the a strip mall."

7. INFORMATION PASSED DOWN

The agent gets some input, makes a prediction, and gives some output - what should that output naturally be? Whatever output it believes will help produce the prediction. I think that is the only way to make an effective hierarchy. On the lowest levels this means an action. On the highest levels this means a name of a temporal pattern in the next layer down. "I expect you'll see this" from the top layer is interpreted as, "If you can make this pattern happen, please do, I believe its possible."

8. FULLY OBSERVABLE ENVIRONMENT MAY NOT NEED HIERARCHY

Perhaps in a fully observable environment we don't to break up the state representation into smaller bits. We might instead go with my original hunch and make a stack. I think that is a simpler way to do it, and we still get the functionality I expressed above without the hassle of object oriented pattern recognition (horizontal information synchronization).

So if we had a stack of two agents and the environment was a regular old number-line what would happen?


9. ISOLATION OF VARIABLES IN TO 'OBJECTS'

With the rubix cube I had wondered what would happen if I made many maestro's and had each of them look only at one specific cube. I ran into problems when I realized in order for this to work it would have to be able to see everything. So then we have a problem. everything has to see everything and model everything? seems like its unnecessarily redundant. Now, if I could get that to work I'd have a system that could perfectly work together to put each cube in it's place in the absolutely most efficient way possible. That would be nice, but I'm not even that good with the cube. So I had an idea:

Instead of isolating every moving part out in space, why not isolate every moving part out in time. For instance lets say I'm trying to solve the rubik's cube. I might look at one piece and say, 'I need this there.' Then I'm going to try a series of actions that puts every other cube back where it was when I said that. In other words I'm searching for ways to move this cube around without ultimately effecting the rest of the cube. That way I can focus on one thing at a time.

This is how I solve it - now I was shown all the moves that I know - but they basically do this. the first moves I use move one cube into place, not caring what happens to the rest of the cube, but as cubes are in place all the subsequent moves get more and more complex to the point where when I move one cube I have to put all the others back in place during the move.

Thus I'm finding special patterns that have a particular effect. I compile those patterns into a list of patterns and know when to use them. Then I can solve it. But I want Maestro to be able to solve in this or a similar way.

My mind knows a clear distinction between causally linked things. This seems to be a principle, not just a strategy. The system must keep track of how thing are effected, remember my unique design from back in the day? it was only paying attention to what changed, which lacked context, but I keep coming back to that idea. When I see a halfway solved cube I immediately see what moves have to be done, the particular set of moves gets triggered by the input of the current state of the cube since I've done it so many times.

What I really want, bare minimum is for it to create a structure as it learns - slightly abstract. so that it can later say, oh, this new thing has the same structure as that, if not the same details. Then it should be able to act on that new thing nearly just as efficiently as the old thing. in order to do that it needs to be able to isolate 'things' away from their environments. It needs object oriented learning.


10. HOW TO FIND CORRELATIONS NAIVELY

So I've created three processes that analyze the data. 1. sleep opps - this finds which actions have the opposite effect. 2. sleep effects - this finds which indexes actions consistently change. 3. sleep always - this finds the ways in which the actions change the data. Combining two and three may allow us to generate predictions about underlying structure, and therefore predictions about things we've never seen before. But how? Lets work through it together.

1 2 3 4	        available actions

1 3 3 1 2 4 4 2	opposite actions

1 2	            special effects
1 {1 2}	        special effects
1 {0 1 2}	      special effects
2 1	            special effects
2 {0 1}	        special effects
3 2	            special effects
3 {1 2}	        special effects
4 1   	        special effects
4 {0 1}	        special effects
(REORDERED FOR SIMPLICITY)
..0 1 ..1	      general always
..1 1 ..2	      general always
..2 1 ..3	      general always
..3 1 ..4	      general always
..4 1 ..5	      general always
..5 1 ..6	      general always
..6 1 ..7	      general always
..7 1 ..8	      general always
..8 1 ..9	      general always
.09 1 .10	      general always
.19 1 .20	      general always
.29 1 .30	      general always
.39 1 .40	      general always
.49 1 .50	      general always
.59 1 .60	      general always
.69 1 .70	      general always
.79 1 .80	      general always
.89 1 .90	      general always
399 1 400	      general always
.0. 2 .1.	      general always
.1. 2 .2.	      general always
.2. 2 .3.	      general always
.3. 2 .4.	      general always
.4. 2 .5.	      general always
.5. 2 .6.	      general always
.6. 2 .7.	      general always
.7. 2 .8.	      general always
.8. 2 .9.	      general always
09. 2 10.	      general always
19. 2 20.	      general always
29. 2 30.	      general always
39. 2 40.	      general always
..1 3 ..0	      general always
..2 3 ..1	      general always
..3 3 ..2	      general always
..4 3 ..3	      general always
..5 3 ..4	      general always
..6 3 ..5	      general always
..7 3 ..6	      general always
..8 3 ..7	      general always
..9 3 ..8	      general always
.10 3 .09	      general always
.20 3 .19	      general always
.30 3 .29	      general always
.40 3 .39	      general always
.50 3 .49	      general always
.60 3 .59	      general always
.70 3 .69	      general always
.80 3 .79	      general always
.90 3 .89	      general always
.1. 4 .0.	      general always
.2. 4 .1.	      general always
.3. 4 .2.	      general always
.4. 4 .3.	      general always
.5. 4 .4.	      general always
.6. 4 .5.	      general always
.7. 4 .6.	      general always
.8. 4 .7.	      general always
.9. 4 .8.	      general always
10. 4 09.	      general always
20. 4 19.	      general always
30. 4 29.	      general always
40. 4 39.	      general always

So I've never been over like 500 in this example. So if I wanted to get from 000 to 999 how would I do it? there maybe one more meta analysis I need to do - to see if there are any patterns in this data I can leverage like 0 -> 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 9. That might help but for now we'll assume this pattern has not been explicitly recognized.

So what I may do is this. first look at the effects and see what ones have to change. all of them. So now pull out everything in the always rules that has a matching thing in the last digit, and then the middle digit then the first digit in the result.

one's place match:
..8 1 ..9	      general always
.50 3 .49	      general always
.30 3 .29	      general always
.20 3 .19	      general always
.40 3 .39	      general always
.70 3 .69	      general always
.80 3 .79	      general always
.90 3 .89	      general always
.10 3 .09	      general always
.60 3 .59	      general always
tens place match:
.8. 2 .9.	      general always
.89 1 .90	      general always
10. 4 09.	      general always
20. 4 19.	      general always
30. 4 29.	      general always
40. 4 39.	      general always
first place match:
(none)

Probably the best place to start are the ones that require the least amount of other changes. So ..8 1 ..9 and .8. 2 .9. Put these together and you get .88 2 1 .99. Now ideally we could do the same to find out how to get there.

one's place:
..7 1 ..8	      general always
..9 3 ..8	      general always
ten's place:
.7. 2 .8.	      general always
.79 1 .80	      general always
.9. 4 .8.	      general always
.90 3 .89	      general always
..7 1 ..8 + .7. 2 .8. = .77 1 2 .88

repeat...
..6 1 ..7	      general always
.6. 2 .7.	      general always
.66 1 2 .77

..5 1 ..6	      general always
.5. 2 .6.	      general always
.55 1 2 .66

..4 1 ..5	      general always
.4. 2 .5.	      general always
.44 1 2 .55

..3 1 ..4	      general always
.3. 2 .4.	      general always
.33 1 2 .44

..2 1 ..3	      general always
.2. 2 .3.	      general always
.22 1 2 .33

..1 1 ..2	      general always
.1. 2 .2.	      general always
.11 1 2 .22

..0 1 ..1	      general always
.0. 2 .1.	      general always
.00 1 2 .11

ok so now we know how to get from .00 to .99 by using these actions: 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2. not the most efficient path. we could get there by 2 2 2 2 2 2 2 2 2 2 3 much faster. Now, this is a process I could have done without all these sleep analysis modules. mmm. in order to make this useful we need to do a meta analysis on all these general rules. but would that kind of analysis even be useful on an environment that doesn't follow the same patterns on large and small scales? maybe its a fools errand.  

Well lets see. If I want to get somewhere I've never seen before like in this example without any post analysis, that is just the raw data in main what would I do? Well for each index I'd get a list of everything that lead to ..9 for instance. and .9. and .99 and 9.. and 99. and 9.9 and 999 (which isn't in the db). I'd want to figure out what kinds of things lead to these kinds of representations.

So we need to know what is similar amongst all the representations that lead to the instances above. Then since we don't have a way to get from 0.. to 9.. we also need to know how X.. changes. What action do I have to take and what does the rest of the representation have to look like to get it to change? this is an easy question to answer for the number line example. the tens place will be most important and consistently either 9 or 0 for the input to change the hundred's place. So it'll be easy to make that discovery. But this wouldn't necessarily work on complex systems where it could changed based on anything. Anyway I think its worth a try. This approach only works with exact matches - in other words what is the same across all examples (like always).

3 questions: how do I change this index at all? How do I change this index to the right value? how do I change this index to the right value while changing others to the right value (or at least not affecting them at all)?

Put in order from shortest fastest path to longest:
  • (3) how do I change all indexes to the right value (is there already an existing chain)? <--- this is the question I already ask.
    • If the answer not found in the database (or not found in a timely manner (later we'll find ways to make this fast by producing maps or something so we don't have to search the whole database)) then we ask a different series of questions:
      • (1) which one of these indexes is most important to getting to the goal?
        • If I can order the indexes I can start with the most important one, such as changing the 100's place rather than the 1's, But if they can't be ordered or their importance cannot be determined then I simply move onto these next question and ask it for each index:
          • () how do I change this index to the correct value? I look in the database for all instances where that index is the correct value.
          • () I also need to ask: how do I get to that index while getting the other indexes closest to their required values?
            • (2) This question makes me ask the question: what is the closest value to the one I want to approximate?
      • (4) And if I can't find a path to fix multiple at once perhaps I can find a path that fixes this one/multiple indexes while putting the rest back where they started - that's a good heuristic for working with many interconnected environments (which is how you can model any environment because each index could be seen as a separate environment) because it works on the rubik's cube.

Ok, so following this line of questioning I need to know certain things:
  1. (WHAT) On an individual, and collective scale what if any is the **closest representation to the goal?** Now, if this is contextual you wont be able to find an answer things are closer to other things based on the state of the rest of the environment then you're screwed. All you can do at that point is go with the statistically best answer which may be misleading in your particular context, if that turns out to be the case after trial and error, you'll have to not care about whats closest at all for now. But if you're lucky you can use sleep for example: 000 -> 123.
    individually:
      0.. -> 1.. well 0 or 2 are the closest values to 1
      .0. -> .2. well 1 or 3 are the closest values to 2
      ..0 -> ..3 well 2 or 4 are the closest values to 3
    collectively:
      00. -> 12. well 11. or 13. are the closest values to 12
      0.0 -> 1.3 well 1.4 or 1.2 are the closest values to 1.3
      .00 -> .23 well .22 or .24 are the closest values to .23
    entirely:
      000 -> 123 well 122 or 124 are the closest values to 123 (hopefully this can be derived from sleep always data. if not it can be derived from main table, which may be full of holes).
  2. (WHAT) On an individual, and collective scale what if any most **important representation (index or collection of indexes) to get right?** for example: 000 -> 123 the 0.. (100's place) is most important. it gets you most of the way to your overall goal. How do we "weight" that index as being most important in the context of a numberline? What about in an environment where the most important index (or set of indexes) change based on context?
    One way to figure this out is to look at all the instances in the database for each index and run some magical analysis on those. I say magical because I don't know what it would entail, perhaps something like counting up how many times it shows up or how many different ways there are to get to that particular index value etc.
  0. META SIDE NOTE: so far with 1 and 2 we're not looking so good. the conclusion is mostly, I don't know how to accomplish either of these naively let alone in an intelligent way. The hope is that these things naturally happen in the right neural net design or HTM or something.
  3. (HOW) How do I change all indexes to the right value (is there already an existing chain)? The way I answer this question right now is simple path finding through a state space. It's brute force, which requires maestro to have explored the environment completely to work correctly. that means maestro has not only seen every state of the system but has also seen every (or imagined (sleep opps)) every state to state transition.   
    Well that's not sustainable so we should re-write this to also take advantage of the sleep data to find what it thinks is a good path to the goal without looking through every state (it could verify if it must, but theoretically it wouldn't have to if sleep data is current). This kind of thing would work on environments that are uniform like a number line or a rubik's cube. but environments that are not a symmetrical, repeating structure, this might not work, well that is to say sleep may not encode enough data or the rules may be too complex for sleep to finish it's analysis in a timely manner. but we're not going to worry about that for this question. Here we're just concerned about how to use the data if its there to produce the same results we would produce if we were using the main table as we are accustomed to doing.
      It would still be a form of path finding through a state space but it would also include some computation to unpack or interpret the rules into specifics. and it wouldn't simply add up the actions but may need to multiply them too. I guess this is the question I was trying to answer above.
        I have made a drawing describing this, but I'm not sure if I can write it out yet with words. so I'll try to include that diagram in the docs folder:
        ![Path Finding](/imgs/rule_path_finding.jpg "rule path findng")
        basically its path finding on the simplest (most underscores) first, then second most etc. etc. Each time you find a step (a single step, not a full path) you jump down to looking for the simplest again, then work your way up.
          Lets go through it in detail: env = 00 -> 01 -> 02 -> 10 -> 11 -> 12 -> 20 -> 21 -> 22 -> 00 actions = A
            entire rules table:             old way of path-find:
            A         available actions     00 A 01 A 02 A 10 A 11 A 12 A 20 A 21 A 22
            A 1	      special effects       ---|----|----|----|-><-|----|----|----|---      
            A {0 1}	  special effects       search from start to finish, and from
            .0 A .1	  general always        finish to start. then once you find a
            .1 A .2	  general always        matching representation take each path
            02 A 10	  general always        to the middle represention and make a list
            12 A 20	  general always        of actions. This path is eight A's.
            22 A 00	  general always

            new way of path finding with rules table:
            find all matching inputs / result respective if we're going forward or backward. keep them in a list just as we do with general path finding. but be sure to substitute for everything that's not exact. Then path-find like above on that data:
            from start to finish:   from finish to start:
            .0 (00)   A   .1 (01)   .1 (21)   A   .2 (22)   general (substitution)
            .1 (01)   A   .2 (02)   .0 (20)   A   .1 (21)   general (substitution)
            02 (02)   A   10 (10)   12 (12)   A   20 (20)   specific (no substitution)
            .0 (10)   A   .1 (11)   .1 (11)   A   .2 (12)   MATCH!
            now, again we end up with 8 A's.

            The benefit to path finding with the rules table is really only cutting out the fat. if we do it on the main table and heaven forbid the predictions table too, we have a huge branching factor. but using this we have far less. Now, we'll need to make a sub command for sleep effects and sleep always called predict so that it'll include the predict table in its analysis. One problem with this is that if the information is highly complex there will be no way to compress it down to 'general always' rules. so the rule table will be as big as the main table filled up with special always rules with a one to one mapping of main. thats no good. we'll have to fix that somehow.

  4. (HOW) How do I come up with a plan for changing one at a time while leaving the rest alone? I need to create a macro plan, that is, this plan has essentially 3 parts, first find behaviors that produce some indexes to be the correct index, directly, not taking into account what happens to the other indexes. perhaps do this with as many as you can without messing things up. Then you need to start looking at larger chains of actions. chains where you fix the most amount of indexes while, during the process, putting most of not all of the original ones you fixed back into place, so on and so forth until the entire thing is fixed.
    Now, during this process of discovery we're going to want to record chains and see if those behaviors work from any other angles. for instance if one action is the opposite of another action, and we do a combination of the two, does the reverse behaviors produce the reverse result? etc. Perhaps the rules we've created above will discover to the agent all the possible things he can do, but I am unsure.
      probably the best thing to do is to make an environment that is pretty simple and test it.


11. CONSTRAINTS ON THE SYSTEM CONSIDERING RULE BASED SYSTEM IN 10.

So, considering the above possible solutions we have realized something. We need a new constraint in addition two our two that we already have.

1. Make the environment 'static' or 'deterministic.'

2. Make the environment 'fully observable.'

3. Make the environment 'uniform.' - meaning since we can only condense the data into rules if the rules are always observed we need the environment to be a uniform structure - repeating substructures like a numberline or at least uniform (even if more highly complex) like a rubik's cube - symmetrical. um... Real environments aren't like this but they could possibly be broken down into these kinds of sub environments (contexts). Our brains do an amazing thing by being able to transfer contexts from one framework to another. which would probably, eventually be very useful but until then maybe we can make a pool/stack/hierarchy of maestro bots to all only care about one type of context and route it accordingly. that'd be cool, but that's down the line if we can even get this micro version working.

12. STACK

Above I stated that it might be a good idea have a pool of different contexts where different rules are learned. Well what if we made it a stack. On each level, data comes in, the most obvious patterns are assessed and pulled out of the data, then (and this is the part I'm not so sure about) we run some pattern recognition on the rest of it, but instead of trying to reduce it to rules here we take our own representation of the more complex data and patterns in the data and pass that up to the next level and let it do the same up and up and up.

Now that I've slept on this concept I have some more things to say about it. First of all what I'm really trying to do is catalogue is the changes and rules from least complex at the root to most complex at the leaves.

  3   3   3       - level 3 - Even more complex patterns, etc.
    2   2         - level 2 - Special Always with constraints
      1           - level 1 - General Always                                

So the idea is that every time we run sleep we create other bots to help us organize this data. We take the first level stuff, which, if its general always stuff has no constraints on it. Then we spin up a new bot that deals with special always and constraints, but since it only deals with data within those constraints it considers them general always. Then if it fines more nuanced patterns within it's stuff it spins up another one and the pattern repeats. So we get a stack of bots (they all share the same main though, that's in a separate db, but their rules are their own). The idea is that when given a path 1.1 looks for it in general always stuff first. if it can't find a path to it, it comes up with a union of plans to find it with the help of number 2, if they can't find it two will recruit the help of the bot 3rd up in the stack. For more and more complex and convoluted ways of finding the solution. Its really just an efficient way to split up the search space into appropriate domains. Like google's search engine. And by having a stack architecture I'm trying to distribute the load of finding a path amongst many bots who can all try to find a path or partial path to the target in their specific domain.

So anyway, this is a naive approach but I'll also have to learn how to define the 'constraints' or parameters for each rule. General always is easy, there are no constraints, but when .09 could lead to .10 or .ab well I'll have to find what all of those have in common and then I'll have a domain that works then I can appropriately graph it out in a tree structure. So in the end the tree structure is one of assumptions about the data that may or may not be true in every case. When they are violated we need to have a process of detection and reconstruction.

so in the case of
00
01
02
10
11
12
20
21
33 <--outlier
22

we get the
.0   .1
.2   .0
02   10 ---
12   20   |
21   33   |-- no compression happening here. Maybe we pass all this up. idk.
33   22   |
22   00 ---

but instead of seeing:
.1   .2

we see 1 can lead to 2 or it can lead to 3 so this is something we'd pass up if not the 02 10 and so on as well. so it would look maybe like this:
.1   .2   (Special) when not 2.
.1   .3   (Special) when     2.

or we could list them all out - but since there is a repeated pattern in the first two instances, maybe not.
01    02
11    12
21    33
Thus we may take .1 .2 (Special) when not 2. as the general case, and pass the .1 .3 up, or just pass it all up. Maybe we take it as the general case in the event that we have no general cases.


13. STACK / TREE RECIPE

I'm not sure what is directly above works well. But I think I can delineate a recipe more generally.
  1. I need a repeatable way to define more and more complex patterns. My strategy so far is to find what's common amongst every observable entry and write those down - what I call my 'general always' rules. Then pass everything else up, being sure to specify their use cases. They way, theoretically, the next level can do the same since it only sees things within it's particular context and thus should be able to find things that are generally always the same.
  2. I need a way to define the patterns and or contexts that these patterns are found in. (regex? or the above notation?)
  3. I need a way that new maestro bots are created and in charge of their respective databases or its all done recursively in the same program.
  4. Lastly, I need a way to path find through this tree structure, asking for this or that.
  5. plus I need meta heuristics: strategies that will probably work on path-finding in many different environments. The one and only strategy I have for this (other than regular breadth-first-search, which will also need to be modified to work withing a tree structure of nodes) is the 'Rubix Cube Heuristic' (at least thats what I call it). The heuristic works like this - you have a complex system of interconnected parts, theres no clear way to get from one state of the entire system to another state of the entire system so you don't try to. You break that down into a series of series of behaviors that tend to be concerned with fixing only one or a few portions of the cube. Thus when you start, you care not what consequences your behaviors have except on just a few cubes, trying to make the cross, for example. Then you're faced with the problem of solving the next cubes. this is something you can only do if you mess up what you already fixed, so you must find ways to mess them up, then fix and solve for the new cubes simultaneously. which increases the problem, but so only as you can find series of moves that have a particular effect (namely, they solve the pieces you need to solve while putting everything (that you've already fixed) back into place). Eventually you end up with a situation where nothing is messed up but the particular set of cubes you can fix all at once, if you know the appropriate set of behaviors, which incidentally is complex, but not exponentially more complex that the other sets of behaviors we've found and used.   


14. BACK BURNER NEXT STEPS

I'm going to put this project on the back burner or just do it on my free time at home while I focus on catching up on my Andrew Ng ai class. So Here are the notes of things I have to do once I come back to this project. I have to make a rich environment to test out and develop the generalizing algorithm. that generalized algorithm must take a run through all the raw data, then pull out the obvious patterns, then pass the rest to the next ai bot, which does the same thing with the smaller amount of data, which, hopefully doesn't have contradictions with simple patterns because stuff has been removed from this data set. So by rich environment I mean not as uniform as a number line, but not entirely chaotic. I want something I can generalize a bit about, but certainly has different contexts, which may be hard to define. speaking of contexts, along with the generalizing algorithm we need to be able to determine the context and represent it some how, a problem I've not tackled at all. lets see...

John coulter said I should learn data structures because data structures help define algorithms. he says if the data structure is right the algorithm will fall into place, it'll be natural. His brother suggested I continue to look into compression, because that's a big part of what the generalizing algorithm is, and he said "Anyway, about trees: they're great for performance, but they're very context-sensitive. It may be a good choice to make them ephemeral: generate them as needed for algorithmic efficiency, but discard them as needed for systemic performance. And use a more flexible format for the underlying durable storage"

if I can get a repeatable generalizing process that takes a list of data and returns a smaller list of data plus rules for the stuff it took out I then have opened the door to be able to make a stack/tree/hierarchy of deeper and deeper understanding of the data. I have compression, generalization and dramatically reduced search space capabilities when path finding. It is the key and so far I've only been able to come up with "what is common amongst everything? ok now generalize that in to a rule."

turns out I have more to say. Context is contextual, its multilevel and inter-level. in other words things are effected, and behave differently based on the big picture, small details, or other details of nearly the same import or reach. Why is this important to consider? idk. Well I think its because I wondered above if I should strictly only take the generalizable for each level, or if I should take the most common patterns and generalize those. I think this is the answer: If I can determine the context then I make the rule in the node I'm at. and push the other contexts down. But because contexts are contextual we may have transitions that are express multiple rules so, not passing them up maybe a problem because the next level may need to see it to come up with a rule. Its more like every transition needs to have a list of rules it matches. Also because contexts are contextual I don't think there is a way to fully generalize without some complex structure like a nearly net that can suss out all these interactions and contexts. but lets see how far this can go anyway.

Example of Generalizing:

state to state transition (only one action in this environment)

CA  ->  AC  ->  CB  ->  AA  ->  AB  ->  BB  ->  JK  ->  JJ  ->  JB  ->  JA  -┐
                                ^--------------------------------------------┘

Node 1 sees:
CA  AC
AC  CB
CB  AA
AA  AB
AB  BB
BB  JK
JK  JJ
JJ  JB
JB  JA
JA  AB

Node 1 rules:
C-  A-
-A  A-
A-  -B
(notice we can't make any rules about J even though there are more than one example of this)

Node 2 sees:
BB  JK
JK  JJ
JJ  JB
JB  JA
(notice it doesn't see JA  AB because that transition already conforms to a rule -A  A-)

Node 2 rules:
J-  J-

Underscore Assumptions / Requirements Defined:
1. This is true for the entire data set we see.
2. it could be anything (could we find a way to delineate what it could be specifically? regex?)
3. It doesn't change from input to result (THIS IS A PROBLEM! take the above example: I didn't even notice that I wasn't making the rules correctly. CA AC and its rule: C- A- isn't correct. this implies CA -> AA. SO this number three may be inaccurate. we may want to introduce one more reserved character that indicates that its not necessarily the same blank digit. like a Dash that says C- means CA -> A[SOMETHING, but I'm not sure what it is]. Not sure if that's helpful or useful. kinda seems like its not. How do I make predictions on that?? well combining multiple rules at once I might be able to make predictions on that. Well Shit. I'm leaving in the errors above because I think this is an important concept to remember. truthfully as I contemplate it I think the dash is the more general case and the underscore, that is including 3 as a requirement is really just a shortcut. I need to probably rely most heavily on the dash concept. but what do I know?)
4. Unilateral from left to right. (C-  A- does not mean any result that starts with A is going to have an input that starts with in C).
5. There is more than one example of this rule.

The theory is that the rules in the lower nodes, nodes that get the data first, supersede the rules created by the higher nodes. Thus consider this portion of the graph: JB  ->  JA  ->  AB. you may assume, if you only looked at the rule from node 2 that if you start with J as in JA you must get J something and therefore theres no way to go from JA to AB. BUT  this is not the case if you consider the rules from node 1 first because -A A- supersedes it. so JA must go to A something, thus AB may be a possibility.

So omitting assumption 3 above lets imagine what would happen if we saw any combination of things we've seen as input. Here are all the combinations and the ones we haven't seen:

AA      BA X    CA      JA      KA X
AB      BB      CB      JB      KB X
AC      BC X    CC X    JC X    KC X
AJ X    BJ X    CJ X    JJ      KJ X
AK X    BK X    CK X    JK      KK X

given:  1st rule    2nd Rule      purposed result
AJ      A- -B                     -B  
AK      A- -B                     -B
BA                  -A A-         A-
BC
BJ
BK
CC      C- A-                     A-  
CJ      C- A-                     A-
CK      C- A-                     A-
JC      J- J-                     J-
KA                  -A A-         A-  
KB                  -B J-         J-
KC
KJ
KK

Thus we have a generalization process. This does mean if we ever see something that goes against the rules we've created we have to reconstruct everything it touches. Notice JC and KB. It didn't find any rule in level 1 so it moved onto level 2 and found rules corresponding to those letters in those places. This, to my mind suggests there is indeed a theoretical upper limit to how many levels there can be. as many different values for each index as you can have. This upper limit suggests to my mind that it cannot encode past a certain complexity. Because if you could encode to infinite complexity, would you not need infinite levels of more and more detailed and niche rules? but anyway its a start. will this help with path finding? idk but who cares. I don't even use join tables at this point and maybe that's all I need practically speaking for any environment that I have time to explore, but for finding paths to states when needing to intuitively feel my way through, this may help because this is generalization and that's what we care about right now.


















15. HIGH NOTES

OK. so this weekend I got high as fk. and I started thinking about this problem from a totally different perspective, made alot of notes and I have no idea if these ideas have any merit whatsoever, or if they're just random, incoherent rantings through and through. but I thought I'd at least record them down so I can develop an opinion on their validity some time in the future.

I started by asking, "could I make a purely probabilistic model instead of the purely logical naive model I've been trying to make?" and I think I imagined a way to kinda do that. In the end however I think I see how the brain approximates a purely probabilistic model by just recording what is actually seen. I see how it melds the two approaches and makes it more efficient. but anyway lets describe this purely probabilistic model:

The approach can be described as "we want to see all the probabilities and sum them." so lets say we have an environment with three indexes. like the numberline. and we start exploring.

000 101
101 333
333 000

say we want to go from 000 to 333 then we have to get all the ways in which each set of indexes for those values are related to all other sets of indexes for the goal values. I think the brain takes it a step further and looks at all those relationships in context to where they stand compared to all possible values at both of those sets of indexes. but enough about the brain. explicitly that means:

0--   ?   3--
-0-   ?   3--
--0   ?   3--
0--   ?   -3-
-0-   ?   -3-
--0   ?   -3-
0--   ?   --3
-0-   ?   --3
--0   ?   --3

00-   ?   3--
0-0   ?   3--
-00   ?   3--
00-   ?   -3-
0-0   ?   -3-
-00   ?   -3-
00-   ?   --3
0-0   ?   --3
-00   ?   --3

0--   ?   33-
-0-   ?   33-
--0   ?   33-
0--   ?   3-3
-0-   ?   3-3
--0   ?   3-3
0--   ?   -33
-0-   ?   -33
--0   ?   -33

00-   ?   33-
0-0   ?   33-
-00   ?   33-
00-   ?   3-3
0-0   ?   3-3
-00   ?   3-3
00-   ?   -33
0-0   ?   -33
-00   ?   -33

0--   ?   333
-0-   ?   333
--0   ?   333
00-   ?   333
0-0   ?   333
-00   ?   333

000   ?   3--
000   ?   -3-
000   ?   --3
000   ?   33-
000   ?   3-3
000   ?   -33

Now this would also be in the list, "000   ?   333" but it would be checked for first, because if that exact thing exists in the db we'd just do that action and get to exactly where we need to go. But if its not we need to check all the indexes of all the combinations. Then we essentially weigh the score of all of actions. for instance if 000 ? -33 has a certain action, it'll count for a lot more than 0-- ? 3-- would. whichever has the highest weighted action count percentage of the group gets is the action that should get us closest to our goal.

And the idea is that this process scales up so we can make levels of abstraction reaching further into the past and further into the future. thats the idea in a nutshell. I'm going to image or scan all my notes and put them in here, along with my audio recorings. This could be pretty bad, and embarrassing but who's to say really?
