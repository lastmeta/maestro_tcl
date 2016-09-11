namespace eval ::intuit {}
namespace eval ::intuit::worker {}


# returns a list of cells (the actual connections, not id)
proc ::intuit::guess {state} {
  set celltable [::repo::get::connectom                                       ]
  set cells     [::intuit::worker::makeCells        $celltable                ]
  set nodetable [::repo::get::nodeTable                                       ]
  set nodelist  [::intuit::worker::makeNodes        $nodetable                ]
  set nodes     [::intuit::worker::selectNodes      $nodelist  $state         ]
  set combos    [::intuit::worker::makeCombinations $nodelist  $nodes  $cells ]
  set nodesbyix [::intuit::worker::getNodesByIndex  $nodelist                 ]
  set bestnodes [::intuit::worker::getBestNodes     $nodesbyix $nodes  $cells ]
  set beststate [::intuit::worker::getStateFrom     $nodelist  $bestnodes     ]
  set bestact   [::intuit::worker::getBestAction    $nodelist  $nodes         ]

  return [list $beststate $bestact]

}


################################################################################
# Workers ######################################################################
################################################################################


# return cell table, formatted correctly: nodeid, cellid, {cell connections}
proc ::intuit::worker::makeCells {celltable} {
  set cells     {}
  set cell      {}
  set i         -1
  foreach item $celltable {
    if {$i == 2} {
      lappend cells $cell
      set cell $item
      set i 0
    } else {
      lappend cell $item
      incr i
    }
  }
  return $cells
}

# return node table, formatted correctly: nodeid,input,index,type
proc ::intuit::worker::makeNodes {nodetable} {
  set nodes     {}
  set node      {}
  set i         -1
  foreach item $nodetable {
    if {$i == 3 } {
      lappend nodes $node
      set node $item
      set i 0
    } else {
      lappend node $item
      incr i
    }
  }
  return $nodes
}

# returns a list of nodeids that match the input of the state
proc ::intuit::worker::selectNodes {nodeslist state} {
  set state [split $state ""]
  set selectnodes {}
  set i 0
  foreach s $state {
    foreach node $nodeslist {
      if {[lindex $node 2] eq $i} {
        if {[lindex $node 1] eq $s} {
          lappend selectnodes [lindex $node 0]
        }
      }
    }
    incr i
  }
  return $selectnodes
}

proc ::intuit::worker::getNodesByIndex {nodelist} {
  set nodesbyindex {} ;# dictionary: index nodes
  foreach node $nodelist {
    dict lappend nodesbyindex [lindex $node 2] [lindex $node 0]
  }
  return $nodesbyindex
}


proc ::intuit::worker::getBestNodes {nodelist nodes cells} {
  set returnnodes {}
  foreach key [dict key $nodelist] {
    if {$key ne "a"} {
      set scorebycells     {}
      set selectcells [dict get $nodelist $key]
      set highestconnection {}
      foreach selectcell $selectcells {
        set allconnections [lindex [lindex $cells [expr $selectcell - 1]] 2]
        # filter to only include the right connections in a dictionary
        set i 0
        set connectionsofcell {}
        foreach connection $allconnections {
          if {[lsearch $nodes [expr $i + 1]] ne "-1"} {
            lappend connectionsofcell $connection
          }
          incr i
        }
        dict lappend scorebycells $selectcell [::prepdata::lsum $connectionsofcell]
      }
      # get the cell of the largest score.
      lappend returnnodes [lindex [lsort -real -decreasing -stride 2 -index 1 $scorebycells] 0]
      # this would be the place to make sure its not a duplicate of the input nodes, but I don't know how to do that in a simple way.
      # you could save these lists for later then do the check when you're done with this loop process. that's probably best,
      # but I'm not going to take the time to write that now.
    }
  }
  return $returnnodes
}


proc ::intuit::worker::getBestState {nodeslist bestnodes} {
  # converts bestnodes into a state to send back to recall.
}


proc ::intuit::worker::getBestAction {nodes nodeslist} {
  # looks a lot like ::intuit::worker::getBestNodes but only cares about actions, so much simpler.
  # also converts that action into a state by consulting the nodestable
}
