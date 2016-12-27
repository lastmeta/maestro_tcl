If we ever want to use a graphing db things could be sped up a lot faster.

Not only would path finding be automatic and ez, but storing the data as a graph in the first place may help us understand it better.

For instance right now I have no way of knowing where 9__ states are located, if they're dispersed or clustered. In order to find out I have to go look at all the things that lead to 9__ states, then those, then those. basically we'd have to recreate a graph every time anyway.

We could implement neo4j graph creation db as a sleep command if we want.

some helpful commands if I decide to do this:

CREATE:
create (n :User {title:"name"}) return n

MATCH:
match (n) return n

DELETE:
match (n) detach delete n

CREATE TWO NODES WITH A RELATIONSHIP:
create (os :State {name: '000'})-[r :A1]->(ns :State {name: '001'})
return os,r,ns

MATCH TWO NODES:
match (os :State {name: '000'}), (ns :State {name: '001'}) return os, ns

CREATE A RELATIONSHIP ON ALREADY EXISTING NODES
match (os :State {name: '000'})-[r :A1]->(ns :State {name: '001'})
match (os :State {name: '000'}), (ns :State {name: '001'}) create (os)-[:A1]->(ns) return os, ns
return os,r,ns

FIND SHORTEST PATH: (let :A1 be an asterisks)
MATCH p=shortestPath(
  (os:State {name:"000"})-[:A1]-(ns:State {name:"002"})
)
RETURN p
