namespace eval ::intuit {}
namespace eval ::intuit::worker {}


# returns a list of cells (the actual connections, not id)
proc ::intuit::guess {state} {
  set celltable [::repo::get::connectom                                             ]
  set cells     [::intuit::worker::makeCells        $celltable                      ]
  set nodetable [::repo::get::nodeTable                                             ]
  set nodelist  [::intuit::worker::makeNodes        $nodetable                      ]
  set nodes     [::intuit::worker::selectNodes      $nodelist  $state               ]
  set combos    [::intuit::worker::makeCombinations $nodelist  $nodes               ]
  set combos    [::intuit::worker::orderedCombos    $nodelist  $nodes $cells $combos]
  set best
}


################################################################################
# Workers ######################################################################
################################################################################


# return cell table, formatted correctly: nodeid, cellid, {cell connections}
proc ::intuit::worker::makeCells {celltable} {
  set cells     {}
  set cell      {}
  set i         0
  foreach item $celltable {
    if {$i > 2} {
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
  set i         0
  foreach item $nodetable {
    if {$i == 4 } {
      lappend nodes $node
      set node $item
      set i -1
    } else {
      lappend node $item
    }
    incr i
  }
  return $nodes
}

# returns a list of nodeids that match the input of the state
proc ::intuit::worker::selectNodes {nodeslist state} {
  set state [split $state ""]
  set selectnodes {}
  foreach node $nodeslist {
    if {[lsearch $state $node] eq [lindex $node 2]} {
      lappend selectnodes $node
    }
  }
  return $selectcells
}

# returns a list of combinations that
# 1. doens't contain state,
# 2. doesn't contain any combos of the same index nodes.
# nodetable is a list of: nodeid,input,index,type
# nodes     is a list of: node ids that match the state
# cells     is a list of: nodeid, cellid, {cell connections}
proc ::intuit::worker::makeCombinations {nodelist nodes cells} {
  # get a dictionary of all nodes by index
  set nodesbyindex  [::intuit::worker::getNodesByIndex $nodelist]
  # make all making combintaions
  set allcombos     [::prepdata::getDictCombos]
  # remove the state from that comvbination.
  set allcombos     [::intuit::worker::removeState $nodes $allcombos]
  # don't remove all states that have fully been explored at this point.
  # not worth the effort.
}

proc ::intuit::worker::getNodesByIndex {nodelist} {
  set nodesbyindex {} ;# dictionary: index nodes
  foreach node $nodelist {
    dict lappend nodesbyindex [lindex $node 2] [lindex $node 0]
  }
  return $nodesbyindex
}

# untested.
proc ::intuit::worker::removeState {nodes allcombos} {
  set statecombo [lsearch $allcombos $nodes]
  if {$statecombo ne "-1"} {
    if {$statecombo eq 0} {
      set allcombos    [lrange $allcombos 1 end "" ]
    } elseif {$statecombo eq [llength $allcombos] - 1} {
      set allcombos    [lrange $allcombos 0 end-1 "" ]
    } else {
      set allcombos    [concat [lrange $allcombos 0 [expr $statecombo - 1]] [lrange $allcombos [expr $statecombo + 1] end ]]
    }
  }
  return $allcombos
}

proc ::intuit::worker::orderedCombos {nodelist ndoes cells combos} {
  set comboscores   {}
  foreach combo $combos {
    # calculate its score (including actions for now)
    dict lappend comboscores $combo [::intuit::worker::calcScore $nodes $cells $combo]
  }
  # sort combos based upon score. return the highest one.
  return [dict keys [lsort -decreasing -stride 2 -index 1 $comboscores]]
}

proc ::intuit::worker::calcScore {nodes cells combo} {
  # minus one from each of the combos and you have a list of cells.
  set previouscells {}
  foreach index $combo {
    lappend previouscells [expr $index - 1]
  }
  set statecells {}
  foreach index $nodes {
    lappend statecells [expr $index - 1]
  }
  # go through that list and calculate a score using cells looking at nodes columns.
  set scores {}
  foreach prevcell $previouscells {
    foreach statecell $statecells {
      lappend scores [lindex [lindex $cells $prevcell] $statecell]
    }
  }
  # return a score for all the nodes in the cell
  return [::prepdata::lsum $score]
  # later we need to make this score better by make it weight adjusted based on what it is - action or input.
}


################################################################################
# useless ######################################################################
################################################################################


#proc ::intuit::worker::selectCells {selectnodes} {
#  set cells {}
#  foreach node $selectnodes {
#    for {set i 0} {$i < $::encode::cellspernode} {incr i} {
#      lappend cells [expr ([lindex $node 0] * $::encode::cellspernode) + $i]
#    }
#  }
#  return $nodecells
#}

#filter out connections not matching nodes list.
#This is not needed because I can just reference by nodeid
#proc ::intuit::worker::selectColumns {cells nodes} {
#  set newcell {}
#  set newcells {}
#  set nodeid {}
#  set cellid {}
#  foreach cell $cells {
#    set i 0
#    foreach item $cell {
#      set nodeid {}
#      set cellid {}
#      set newcell {}
#      if       {$i == 0} {
#        set nodeid $item
#      } elseif {$i == 1} {
#        set cellid $item
#      } elseif {$i == 2} {
#        set k 1
#        lappend newcell $nodeid
#        lappend newcell $cellid
#        foreach connection $item {
#          if {[lsearch $nodes $k] ne "-1"} {
#            lappend newcell $connection
#          }
#        }
#        lappend newcells $newcell
#      }
#      incr i
#    }
#  }
#  return $newcells
#}
