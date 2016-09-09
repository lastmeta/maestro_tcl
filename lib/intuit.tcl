namespace eval ::intuit {}
namespace eval ::intuit::set {}
namespace eval ::intuit::get {}
namespace eval ::intuit::worker {}
namespace eval ::intuit::remove {}
namespace eval ::intuit::compile {}
namespace eval ::intuit::order {}

proc ::intuit::get::guess {state} {
  return [::chain::this $state                             \
                  [list ::intuit::get::cellConnections {}] \
                  [list ::intuit::remove::zeros        {}] \
                  [list ::intuit::compile::list        {}] \
                  [list ::intuit::order::list          {}] \ ]
}

# returns a list of cells (the actual connections, not id)
proc ::intuit::get::cellConnections {state} {
  set nodetable [::repo::get::nodeTable                                      ]
  set celltable [::repo::get::connectom                                      ]
  set nodedata  [::intuit::worker::makeNodes        $nodetable               ]
  set nodes     [::intuit::worker::selectNodes      $nodedata                ]
  set cells     [::intuit::worker::makeCells        $nodes                   ]
  set combos    [::intuit::worker::makeCombinations $nodetable $nodes $cells ]
  foreach combo $combos {

  }




}


################################################################################
# Workers ######################################################################
################################################################################


proc ::intuit::worker::makeNodes {nodedata} {
  set nodes     {}
  set node      {}
  set i         0
  foreach item $nodedata {
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
proc ::intuit::worker::selectNodes {nodes} {
  set state [split $state ""]
  set selectnodes {}
  foreach node $nodes {
    if {[lsearch $state $node] eq [lindex $node 2]} {
      lappend selectnodes $node
    }
  }
  return $selectcells
}

# return cell table, formatted correctly: nodeid, cellid, {cell connections}
proc ::intuit::worker::makeCells {nodes} {
  set celldata [::repo::get::connectom]
  set cells     {}
  set cell      {}
  set i         0
  foreach item $celldata {
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


# returns a list of combinations that
# 1. doens't contain state,
# 2. doesn't contain anything in main or if all actions have been used on them bad.
# 3. doesn't contain any combos of the same index nodes.
# nodetable is a list of: nodeid,input,index,type
# nodes     is a list of: node ids that match the state
# cells     is a list of: nodeid, cellid, {cell connections}
proc ::intuit::worker::makeCombinations {nodetable nodes cells} {
  # get a dictionary of all nodes by index
  set nodesbyindex [::intuit::worker::getNodesByIndex $nodetable]
  # make all making combintaions
  set allcombos    [::prepdata::getDictCombos]
  # remove the state from that comvbination.
  set statecombo   [lsearch $allcombos $nodes]
  if {$statecombo ne "-1"} {
    if {$statecombo eq 0} {
      set allcombos    [lrange $allcombos 1 end "" ]
    } elseif {$statecombo eq [llength $allcombos] - 1} {
      set allcombos    [lrange $allcombos 0 end-1 "" ]
    } else {
      set allcombos    [concat [lrange $allcombos 0 [expr $statecombo - 1]] [lrange $allcombos [expr $statecombo + 1] end ]]
    }

  }

  # get a list of all states that have fully been explored
  # remove each of those states from the combination list.
}


proc ::intuit::worker::getNodesByIndex {nodetable} {
  set nodesbyindex {} ;# dictionary: index nodes
  foreach node $nodetable {
    dict lappend nodesbyindex [lindex $node 2] [lindex $node 0]
  }
  return $nodesbyindex
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
