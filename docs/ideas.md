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

So here's how it would work from the top down? With 2 levels we would necessarily have 3 agents. you would send a state representation to the top. It would ask the lower ones which nodes correspond to the state index it knows belongs to the agents. Then it would try to figure out how to get to those nodes. and send down the names of the learned paths for the lower agents to do at the same time.

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
