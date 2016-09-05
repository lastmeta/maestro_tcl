# Maestro - a Naive Sensory Motor Inference Engine #
--------------------------------

Maestro is an simplified and unoptimized attempt at generalized AI. It is a prototype. It performs sensory-motor inference to discover the causal structure of the environment in which it is placed. The hope is that once it has explored an environment it can then use what it has learned to intuitively achieve any arrangement of that environment.


## Setup ##

Run each of the following tcl scripts in order from a command line:

- **server**.tcl
	- (must run first)
- **naisen**.tcl
	- (must run before simulation scripts)
- /simulations/**numberline**.tcl (demo simulation)
	- (must run after all naisen.tcl)
- **user**.tcl

In this demo Maestro will explore the numberline learning how to traverse it using four motor commands.

To use Maestro with other things at this point one must build an interface to their environment using numberline.tcl as an guide. Maestro will communicate actions to the environment. It has 99 actions ranging from 1 to 99. action 0 is reserved for an error message and is currently not used.


## User Commands ##

The user can communicate with the running Maestro Bot using the following commands:

**help** / **?** / **man** - Displays a help screen containing a list of commands.

**can** {subcommand} - Tells Maestro to imagine how it could achieve a certain state of the environment defined by {subcommand} and report if it thinks it can achieve that state from the environments current state. For example: **can 999**

**try** {subcommand} - Tells Maestro to try to take action to achieve a certain state of the environment defined by {subcommand}. For example: **try 999**

**try _** - The underscore subcommand indicates that Maestro is to explore the environment.

**try __** - The double underscore subcommand indicates that Maestro is to stop all behavior.

**sleep acts** - Tells Maestro to determine which of its default 100 actions have produced results. Once the list of viable actions is determined Maestro will only use those actions to affect the environment.

**sleep opps** - Tells Maestro to find behaviors that have consistently produced the opposite result in the change of state of the environment. Once found, Maestro will extrapolate those opposite actions into a list of new, predicted, but not necessarily ever seen before states that it can reference to learn more about its environment.

**sleep react** - Tells Maestro to reset its available actions (for instance "1 2 3 4") to the default available actions (which is "1 2 3 ... 97 98 99").

**learn** {on/off} - Tells Maestro to memorize and encode data while it interacts with the environment or not. Default is always on. For example: **learn off**

**acts** {actions} - Tells Maestro to use this list of actions to affect the environment. This command can be used before Maestro explores the environment and makes its exploration more efficient. The fewer the actions Maestro has to choose from the more efficient Maestro can be. The possible list of acts is 1 through 100, but default is only 1 through 20. For example: **acts 1 2 3 4**

**cells** {integer} - Tells Maestro to set the number of cells per node in its internal neural network. The higher the number the slower its Maestro is able to process data, but the more subtle relationships it can detect. The rate of change is exponential. This is a parameter of the internal neural network and should not normally be changed. This command can only be run before the Maestro explores the environment as it cannot reorganize its internal neural network so dramatically after it has been created. Default is 4; {integer} may be 1 - 10. For example: **cells 6**

**limit** {integer} - Tells Maestro to use a threshold other than the default (20) to determine how quickly it learns things. This is a parameter of the internal neural network and should not normally be changed. {integer} may be 1 - 100. For example: **limit 50**

**incre** {integer} - Tells Maestro that when an assumption is verified to increase its belief in said assumption by the integer amount. Default is 10. This affects how quickly it learns things. This is a parameter of the internal neural network and should not normally be changed. {integer} may be 1 - 100. For example: **incre 21**

**decre** {integer} - Tells Maestro that when an assumption is not verified to decrease its belief in said assumption by the integer amount. Default is 1. This affects how quickly it forgets things. This is a parameter of the internal neural network and should not normally be changed. {integer} may be 0 - 100. Setting decr to 0 will restrict the neural network from forgetting anything, even beliefs that are incorrect. For example: **decre 10**

**from user to s.1 message _** - Using this format the user can send messages to anything on the Maestro network, including, (as in this example) the simulation script.


## Limitations ##

Maestro requires the data its given to always have the exact same number of digits. For example **0** in an environment that can also be **999** should be represented as **000**.

Maestro requires the data its given to be void of particular characters: the underscore, the backslash, quotation marks, and the space. All other numbers, letters and symbols are fine to use in representations of the environment's state.

Maestro is not well equipped for "social" environments. For example, environments where separate actors have an influence on the environment it is in (such as other drivers).

Maestro is not well equipped for time series environments; environments where the passage of time occurs without its input. That is to say when aspects of the environment can change zero or multiple times before it reacts to a particular arrangement of the environment at a particular time. For instance it may be able to solve a rubix cube because it does nothing when it is not perturbed, but playing the game 'snake' may be difficult because the snake constantly moves forward even if the player doesn't take any action.

Maestro is as of yet not optimized. Its neural net is not hardware accelerated. It is not written in C; it is written in Tcl. It is not fast. It is merely a prototype.

In short Maestro is best equipped to learn and engage in static environments, even highly complex ones. Its performance in other types of environments will vary from 'very well' to 'unacceptable.'

## Conventions ##

The design of the Maestro network allows for multiple Maestro agents to interact, though this is not yet implemented. A hierarchy of Maestro agents may someday work together in to accomplish complex tasks or manage complex environments. For this reason it is conventional to name Maestro agents with numbers as an address. **1.1** is considered the first Maestro agent on the first (bottom) level of a (as of yet theoretical) Maestro Hierarchy. **s.1** or **e.1** then is considered the portion of the simulation or the environment that communicates with Maestro **1.1**. These are naming conventions; not naming rules. As of yet no functional logic relies on these conventions.
