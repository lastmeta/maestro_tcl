# Maestro - a Naive Sensory Motor Inference Engine #
--------------------------------

Maestro is an simplified and unoptimized attempt at generalized AI. It is a prototype. It performs sensory-motor inference to discover the causal structure of the environment in which it is placed. The hope is that once it has explored an environment it can then use what it has learned to intuitively achieve any arrangement of that environment.

The learning task of Maestro is simple: learn what each action does in every situation. This is an impossible task to do naively thus simple AI techniques are employed to help simplify or limit the search space: to give Maestro intuition.  


## Setup ##

Run each of the following tcl scripts in order from a command line:

- **server**.tcl
	- (must run first)
- **maestro**.tcl
	- (must run before simulation scripts)
- /simulations/**numberline**.tcl (demo simulation)
	- (must run after all naisen.tcl)
- **user**.tcl

In this demo Maestro will explore a numberline from 000 to 999 learning how to traverse it using four motor commands.

To use Maestro with systems other than the included simulation one must build an interface to their environment, connecting it to the server on port 9900 (use numberline.tcl as a guide). Maestro will send actions to and get states (or input) from the environment. It has unlimited actions, but defaults at 4. The more actions Maestro has available to it, the less efficient it is at exploring its environment. Actions are mere numbers such as 1 or 2 or 3 or 4.


## User Commands - Behavior ##

The user can communicate with the running Maestro Bot using the following commands:

**help** / **?** / **man** - Displays a help screen containing a list of commands.

**explore** {random/curious} - Tells Maestro is to explore the environment. Default is curious. Random chooses a random action at every time-step. Curious tries to explore areas of the environment that are less explored than others. For example: **explore random**

**can** {environment} - Tells Maestro to imagine how it could achieve a certain state of the environment defined by {environment} and report if it thinks it can achieve that state from the environments current state. For example: **can 999**

**try** {environment} - Tells Maestro to try to take action to achieve a certain state of the environment defined by {environment}. Default is nothing and will tell Maestro to try nothing, and has the same result as the **stop** command. For example: **try 999**

**stop** - Indicates that Maestro is to stop all behavior, exploratory or otherwise.

**do** {action} - Tells Maestro to do a particular action right now. For example: **do 2**

**do list** {actions} - Tells Maestro to do a list of actions right now. For example: **do 4 3 2 1 2 4 3**

**do repeat** {action} {number of repeats} - Tells Maestro to do a particular action a specified number of times. For example: **do 4 27**

**sleep acts** - Tells Maestro to determine which of its default 100 actions have produced results. Once the list of viable actions is determined Maestro will only use those actions to affect the environment.

**sleep opps** - Tells Maestro to find behaviors that have consistently produced the opposite result in the change of state of the environment. Once found, Maestro will extrapolate those opposite actions into a list of new, predicted, but not necessarily ever seen before states that it can reference to learn more about its environment.

**sleep react** - Tells Maestro to reset its available actions (for instance "1 2 3 4") to the default available actions (which is "1 2 3 ... 18 19 20").

**from user to s.1 message _** - Using this format the user can send messages to anything on the Maestro network, including, (as in this example) the simulation script.


## User Commands - Parameters ##

**learn** {on/off} - Tells Maestro to memorize and encode data while it interacts with the environment or not. Default is always on. For example: **learn off**

**acts** {actions} - Tells Maestro to use this list of actions to affect the environment. This command can be used before Maestro explores the environment and makes its exploration more efficient. The fewer the actions Maestro has to choose from the more efficient Maestro can be. The possible list of acts is 1 through 100, but default is only 1 through 20. For example: **acts 1 2 3 4**

**cells** {integer} - Tells Maestro to set the number of cells per node in its internal neural network. The higher the number the slower its Maestro is able to process data, but the more subtle relationships it can detect. The rate of change is exponential. This is a parameter of the internal neural network and should not normally be changed. This command can only be run before the Maestro explores the environment as it cannot reorganize its internal neural network so dramatically after it has been created. Default is 4; {integer} may be 1 - 10. For example: **cells 6**

**limit** {integer} - Tells Maestro to use a threshold other than the default (20) to determine how quickly it learns things. This is a parameter of the internal neural network and should not normally be changed. {integer} may be 1 - 100. For example: **limit 50**

**incre** {integer} - Tells Maestro that when an assumption is verified to increase its belief in said assumption by the integer amount. Default is 10. This affects how quickly it learns things. This is a parameter of the internal neural network and should not normally be changed. {integer} may be 1 - 100. For example: **incre 21**

**decre** {integer} - Tells Maestro that when an assumption is not verified to decrease its belief in said assumption by the integer amount. Default is 1. This affects how quickly it forgets things. This is a parameter of the internal neural network and should not normally be changed. {integer} may be 0 - 100. Setting decr to 0 will restrict the neural network from forgetting anything, even beliefs that are incorrect. For example: **decre 10**


## Limitations ##

Maestro requires the data its given to always have the exact same number of digits. For example **0** in an environment that can also be **999** should be represented as **000**.

Maestro requires the data its given to be void of particular characters: the underscore, the backslash, quotation marks, and the space. All other numbers, letters and symbols are fine to use in representations of the environment's state.

Maestro is not well equipped for "social" environments. For example, environments where separate actors have an influence on the environment it is in (such as other drivers).

Maestro is not well equipped for time series environments; environments where the passage of time occurs without its input. That is to say when aspects of the environment can change zero or multiple times before it reacts to a particular arrangement of the environment at a particular time. For instance it may be able to solve a rubix cube because it does nothing when it is not perturbed, but playing the game 'snake' may be difficult because the snake constantly moves forward even if the player doesn't take any action.

Maestro is as of yet not optimized. Its neural net is not hardware accelerated. It is not written in C; it is written in Tcl. It is not fast. It is merely a prototype.

In short Maestro is best equipped to learn and engage in static environments, even highly complex ones. Its performance in other types of environments will vary from 'very well' to 'unacceptable.'


## Convention ##

The design of the Maestro network allows for multiple Maestro agents to interact, though this is not yet implemented. A hierarchy of Maestro agents may someday work together in to accomplish complex tasks or manage complex environments. For this reason it is conventional to name Maestro agents with numbers as an address. **1.1** is considered the first Maestro agent on the first (bottom) level of a (as of yet theoretical) Maestro Hierarchy. **s.1** or **e.1** then is considered the portion of the simulation or the environment that communicates with Maestro **1.1**. These are naming conventions; not naming rules. As of yet no functional logic relies on these conventions.


## what to do next ##

Curious isn't great, but it works ok.
found glitch in chain - stops short or something.
also doesn't save chains in chain table.
add simple query to intuit.
