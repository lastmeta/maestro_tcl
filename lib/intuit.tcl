namespace eval ::intuit {}
namespace eval ::intuit::worker {}


# returns a list of cells (the actual connections, not id)
proc ::intuit::guess {inputstate state {badstates ""}} {
  set celltable [::repo::get::connectom                         ]
  set cells     [::intuit::worker::makeCells        $celltable  ]
  set nodetable [::repo::get::nodeTable                         ]
  set nodelist  [::intuit::worker::makeNodes        $nodetable  ]
  set nodes     [::intuit::worker::selectNodes      $nodelist   \
                                                    $state      ]
  set nodesbyix [::intuit::worker::getNodesByIndex  $nodelist   ]
  set bestnodes [::intuit::worker::getBestNodes     $nodelist   \
                                                    $nodes      \
                                                    $cells      \
                                                    $nodesbyix  \
                                                    $state      \
                                                    $inputstate \
                                                    $badstates  ]
  set beststate [::intuit::worker::getStateFrom     $nodelist   \
                                                    $bestnodes  ]
  set bestact   [::intuit::worker::getBestAction    $nodesbyix  \
                                                    $nodes      \
                                                    $cells      \
                                                    $beststate  ]
  set bestact   [::intuit::worker::getStateFrom     $nodelist   \
                                                    $bestact    ]
  puts "return [list $beststate $bestact]"
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


proc ::intuit::worker::getBestNodes {nodelist nodes cells nodesbyix originalstate inputstate badstates} {
  set returnnodes {}
  set bestnodesbyix {}
  foreach key [dict key $nodesbyix] {
    if {$key ne "a"} {
      set scorebycells     {}
      set selectcells [dict get $nodesbyix $key]
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
        # filter out zeros and score cells
        if {[lsearch $connectionsofcell 0] eq "-1"} {
          dict lappend scorebycells $selectcell [::prepdata::lsum $connectionsofcell]
        }
      }
      # get the cell of the largest score.
      set returnlist [lsort -real -decreasing -stride 2 -index 1 $scorebycells]
      lappend returnnodes [lindex $returnlist 0]
      lappend bestnodesbyix $key [dict keys $returnlist]
    }
  }


  # this would be the place to make sure its not a duplicate of the input nodes, but I don't know how to do that in a simple way.
  # you could save these lists for later then do the check when you're done with this loop process. that's probably best,
  # but I'm not going to take the time to write that now.
  set returnlist [::prepdata::getDictCombos $bestnodesbyix]
  set x 0
  set foundone false
  while {$x < [llength $returnlist] && !$foundone} {
    set state [::intuit::worker::getStateFrom $nodelist $returnnodes]
    set actsarefree false
    set doneacts [::repo::get::actsDoneHere $state]
    foreach action $::decide::acts {
      if {[lsearch $doneacts $action] eq "-1"} {
        set actsarefree true
      }
    }
    if {$state                      ne $originalstate
    &&  $state                      ne $inputstate
    &&  $actsarefree
    &&  [lsearch $badstates $state] eq "-1"
    } then {
      set foundone true
    } else {
      set returnnodes [lindex $returnlist $x]
    }
    incr x
  }
  return $returnnodes
}


proc ::intuit::worker::getStateFrom {nodelist bestnodes} {
  # converts bestnodes into a state to send back to recall.
  set nodes {}
  foreach bestnode $bestnodes {
    dict set nodes [lindex [lindex $nodelist [expr $bestnode - 1]] 2] [lindex [lindex $nodelist [expr $bestnode - 1]] 1]
  }
  set nodes [lsort -increasing -stride 2 -index 0 $nodes]
  return [string map {" " ""} [dict values $nodes]]
}


proc ::intuit::worker::getBestAction {nodesbyix nodes cells beststate} {
  # looks a lot like ::intuit::worker::getBestNodes but only cares about actions, so much simpler.
  set returnnodes {}
  foreach key [dict key $nodesbyix] {
    if {$key eq "a"} {
      set scorebycells     {}
      set selectcells [dict get $nodesbyix $key]
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
        # filter out zeros and score cells
        if {[lsearch $connectionsofcell 0] eq "-1"} {
          dict lappend scorebycells $selectcell [::prepdata::lsum $connectionsofcell]
        }
      }
      # get the cell of the largest score.
      set returnlist [lsort -real -decreasing -stride 2 -index 1 $scorebycells]
      lappend returnnodes [lindex $returnlist 0]
    }
  }
  # this would be the place to make sure its returning an answer that hasn't been done at this location before.
  set x 0
  set foundone false
  set actsdonehere [::repo::get::actsDoneHere $beststate]
  puts actsdonehere$actsdonehere
  puts returnnodes$returnnodes
  while {!$foundone} {
    if {[lsearch $actsdonehere $returnnodes] eq "-1"} {
      set foundone true
    } else {
      set returnnodes [lindex [dict keys $returnlist] $x]
    }
    if {$x < [llength $::decide::acts]} {
      incr x
    } else {
      set foundone true
    }
  }
  return $returnnodes
}

# one idea I had was to score everything based on weights.
# for instace if we have ever only once seen 3__ then
# the thing that lead us to that is quite important,
# and should be weighted accordingly?

# what I am not happy about is this system doesn't reason by analogy.
# for instance: it doesn't say, "oh I notice __8 is followed by __9 and
# these bits seem to follow the same patterns so maybe _8_ is also followed
# by _9_." That's the kind of stuff it needs to be able to do.
