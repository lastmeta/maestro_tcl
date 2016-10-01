I've been playing with this idea of an *ultra simplified* sensory-motor engine. This has most likely been done before. If anyone has any input about my thoughts on this idea I'd love to hear it, especially if you can point me to a similar sounding project.

We all know the brain does sensorimotor inference, but I'm not proposing building a robust agent like the one HTM will eventually give us. I'd actually like to build an ultra simplified one as an exercise - to get a feel for all the basic components that go into something like this. Perhaps HTM is really the most simplified way to create any useful sensorimotor inference engine, I don't know, but in that case this idea is mute.

So anyway, I'll describe what I've thought about from the ground up. I'll assume the reader has no prior knowledge of HTM theory, machine learning technologies or neuroscience:

The goal is to create a computer program (we'll call it an agent because it has behaviors) that can learn an environment's structure through experimentation. You would place this agent in the environment (perhaps you let it interact with a script simulating a puzzle for instance), and it would record what it sees and what it does so that later it can navigate the environment purposefully. That is to say, by its behavior it can recreate specific states of that environment. In other words, it learns how to manipulate its environment. In other words, it learns how its motor commands affect what it senses: a sensorimotor engine.

Simply recording the raw input and raw actions is of course the most naïve program that could be considered, in anyway, a "sensorimotor inference engine." And if you were to do that you'd have a agent that could learn and navigate very simple environments: so simple that it could have time to explore every possible way to get from one state of the environment to another state of the environment. For example, given a number line from 1 to 1,000, and given the behavior abilities to move up by 1 or down by 1, the agent could learn a every possible way to get to every number in a short amount of time. To go from 5 to 8 the engine would produce this list of actions: +1, +1, +1.

The database might look something like this:
state action new_state
1     +1     2
2     +1     3
3     -1     2
...   ...    ...

This method is simply path-finding in a state-space. Its ai research that started before computers even existed. Its easy to do.

The problem occurs when you have complex environments. This method of fully exploring an environment breaks down as soon as you start introducing complexity. The time it takes to explore the environment exponentially explodes. For example, with one number line we had 1,000 states and only 2,000 state transitions (up or down), but if we add another number line to that first one and make a grid instead, we can go up, down, left or right at every state. This results in 1,000 * 1,000 states and the transitions between states become 4 * 1,000,000. That's simply twice as complex as a very, very simple environment but the number of transitions between states has gone up 2,000 times.

So what method can it use to 'learn' an environment it can't possibly have time to explore fully? How can it learn a lot by doing a little?

In the broadest possible terms, we need to start "generalizing;" which, incidentally, is the main goal of the entire machine learning industry. We want to effectively reduce the space we have to search in order to come up with the right answers. We want it to be able to have good guesses about areas of the environment it has never seen before.

Now, HTM is hot on the trail of solving this problem in biologically inspired ways. And a fully implemented HTM will be able to "generalize" in many if not all the same ways the human brain can "generalize." An audacious goal indeed, but a possible one. Our ultra simplified version of a sensorimotor engine need not be so capable. The aim for the ultra simplified version is to discover and achieve the bare-minimum requirements for a sensorimotor engine to be useful in anyway above the naïve approach expressed above.

The first goal in designing such a system would be to format and simplify the data as much as possible before this agent even gets it. This will place some heavy constraints on the system, but may not make it entirely useless. I've come up with three constraints that may help:

1. Make the environment static - that is to say, deterministic. No other actors can be in the environment mucking about unless they too are fully represented in the environment state as being part of the agent's environment. Bottom line: if the agent does an action at a certain state and gets a new state, that behavior must be duplicable to make prediction easy. This also means nothing changes if our agent doesn't act.

2. Make the environment fully observable. Everything in the environment that can change must be observed by the agent in every time-step. That way it can have an easier time figuring out the relationships between elements of the environment and its actions.

3. Make the representation of the environment only include what the program can possibly control - don't include any erroneous data (this is really an extrapolation of constraint 2, I think).

The hope is that by giving it's environment some serious constraints we can produce something a little more useful than the naïve raw-data example we looked at above. Formatting the environment's representation according to these constraints may simplify the way it approaches the exponential combinatorial complexity problem, but these constraints alone don't do anything to solve that problem and they don't say anything about how it should generalize. For instance human perception is noisy, and partial in nature (we can't see the whole universe at every moment), and its a massive amount of data (billions of sensors throughout the body). None of these features would be present if the environment's representation is formatted according to these constraints. That simplifies the problem our agent must solve without (hopefully) making it entirely useless. We're trying to isolate the generalization problem without needing to understand how our actual brain solves these ancillary issues.

At this point, we need to decide how to best and most simply solve the "generalization" problem. By breaking the problem down into its constituent parts we will be reinventing the wheel, but since this is an exercise that's ok.

An intuitive approach to generalization gives us a general solution: the world the agent is in has structure which determines how things behave. If we can recreate that structure in some virtual form in the mind of the agent, it will be able to make predictions that match the behavior of the actual world. It needs to somehow build a model of the structure of it's environment.

Can an agent produce useful action without a model? Of course it can: single celled organisms don't produce a model of their world because they have no memory to create a model in. Yet they navigate it effectively. How? By evolution they have developed heuristic rules (fundamentally encoded in their DNA) that guide their behaviors to obtain food and reproduce; thus they exist. But how far can heuristics take you? How complex of an environment can you navigate by using heuristics alone? I don't think they're enough on their own to produce a useful sensorimotor inference engine. It'll have to make a model mirroring the structure of its environment.

Structure in the world produces patterns, so the most intuitive way to making a model of the world is to convert patterns back into some kind of structure. First we must recognize those patterns. Lets return to our simple number line example. Now this example is highly uniform, so it should serve as a good introductory example. The agent might recognize that the +1 action seems to always effect the last digit of the state. That's a pattern that it can use to create a guess at what the structure of the number line is.

Model creation can be seen as a form of compression. It necessarily has to compress the representation of the environment, including all those states of the environment we have not seen. For an intuitive example lets make a table of rules that we'll call the model, or the function. This table will tell us, given a state and an action, what new state we should expect to see. Notice that instead of a instead of a one-to-one mapping like we described above we'll create a series of rules to apply to the state-action pair to determine what new state we will see.

Here's what the database may look like if we condensed those records of raw data down to fundamental rules:
state action new_state
\*0   +1     \*1
\*1   +1     \*2
\*2   +1     \*3
...   ...    ...
\*9   +1     \*10

Now instead of recording every +1 action for every number from 1 to 1000 we've made 10 rules that cover all the +1 actions. This list of rules is a compressed version of the environment's states. You can do the same for the 10's place and the 100's place and so on. And you can reduce those rules down further if you want. This hypothetical set of rules can be seen as a model of the structure of the number line, because it describes all the ways in which the a base-10 number line behaves.

This model can actually be seen as a set of heuristic rules to be pattern matched against the real data. If you wanted to get from one state of the number line to another state of the number line you could easily path-find your way there by iterating through this structure recursively.

True generalization includes not only a way to compress the expression of the environment, but also includes a better way to use the created model. We want to be able to see the whole structure at once rather than searching through one predicted state at a time. If that isn't intuitive, allow me to give you an example:

You are given an address, "426 N Wall Street, Salt Lake City, Utah 84103, USA." Pretend, if you must, that you don't know where this address is at all. Given a list of countries on earth you could very quickly find the right one, given a list of states or provinces in that country you could match the "Utah" portion. given a list of cities in Utah you can quickly find "Salt Lake City" and given a list of street addresses in Salt Lake City you can find "426 N Wall Street." If you have programming experience you'll recognize this as a hash tree.

The address of the house, which could be used as the 'name' of the house describes it's location relative to the entire structure, or relative to every other node of the structure by cutting up the structure into many layers of sections. Its a hierarchy. The rule-table we created above as a heuristic model is not a hierarchy, its flat like the naïve recording of the raw data; it's hard to make use of that generalization because a particular state is not addressed so it can't be found efficiently.

Another problem with this heuristic rule-table example is the problem of environment with more complex relationships between data. If I had a state, say "000" and an action produces this result "457" then the same action produces this result "K3M" how would you make a rule-table for something that has complex and subtle patterns instead of obvious ones? This is the same problem your brain faces when trying to recognize a face in changing lighting, and at changing angles. A dramatically different pattern falls on the retinas at each moment yet you are able know that you're speaking to the same person the whole time. Generalization requires a hierarchy for this fact to: so that higher layers can understand "the big picture," and lower layers can understand "the details." A corporation works the same way, with upper management making broad plans far into the future, down to the lowest layers dealing with day to day operations.

Some kinds of Neural Nets can encode nonlinear data. Neural nets learn the appropriate weights of connections between elements in the data; it learns what is correlated with what. Neural nets could be a viable substitute to the conceptual rule-table we made above to help the agent be able to predict complicated interactions within environments. They are still flat though. A hierarchy of neural nets could possibly match the memory structure we're looking for, but Neural nets have other problems too. To effectively learn via back propagation the neural net may need thousand or 10's of thousands of examples. While exploring an environment it may be possible to never see the same state twice let alone thousands of times.  

So the question becomes - what kind of patterns must we find in the raw data in order to build an adequate model?

we're trying to model nonlinear functions

Now a meta-question we may ask at this point is, what is the best way to make a model?
-nonlinear, neural nets etc.
-mathematical models
-rule sets models (conjunction of heuristics)
-scientific method
-nature makes parallel models of the world and lets them compete with each other. The brain makes parallel models that compete and vote. scientists make theories that compete with each other and eventually get solidified into the consensus in their respective fields.
-market does the same thing.
-Parallelism, competition, cooperation, emulation (reason by analogy to other models) are some of the principles that seem to produce the best models or the most success.
