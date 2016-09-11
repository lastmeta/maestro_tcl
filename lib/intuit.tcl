namespace eval ::intuit {}
namespace eval ::intuit::worker {}


# returns a list of cells (the actual connections, not id)
proc ::intuit::guess {state} {
  set celltable [::repo::get::connectom                                             ]
  set cells     [::intuit::worker::makeCells        $celltable                      ]
  set nodetable [::repo::get::nodeTable                                             ]
  set nodelist  [::intuit::worker::makeNodes        $nodetable                      ]
  set nodes     [::intuit::worker::selectNodes      $nodelist  $state               ]
  set combos    [::intuit::worker::makeCombinations $nodelist  $nodes  $cells       ]

  #set combos    [::intuit::worker::orderedCombos    $nodelist  $nodes $cells $combos]
  #puts $combos
  #set best      [::intuit::worker::removeZeros                 $state $cells $combos]
  #set inputact  [::intuit::worker::splitNode                                 $combos]

  return $combos
  #once we have a list of liekly combos starting at the top
  # 1. remove 0s from that list unless its way better than the next one
  # 2. remove ones that have been explored in main and bad already
  # 3. return the top one that passes above
  # 4. you'll have to convert cells back to nodes remember. separate input and action when you return it.
  ###########################################################
  # when recall gets it back it says is this in the db if yes find a path to it if no repeat with new goal as input

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

# returns a list of combinations that
# 1. doens't contain state,
# 2. doesn't contain any combos of the same index nodes.
# nodetable is a list of: nodeid,input,index,type
# nodes     is a list of: node ids that match the state
# cells     is a list of: nodeid, cellid, {cell connections}
proc ::intuit::worker::makeCombinations {nodelist nodes cells} {
  # get a dictionary of all nodes by index
  set nodesbyindex  [::intuit::worker::getNodesByIndex $nodelist]
  # get best option
  set nodesbyindex  [::intuit::worker::getBest $nodesbyindex $nodes $cells]
  # make all making combintaions
  #set allcombos     [::prepdata::getDictCombos $nodesbyindex]
  # remove the state from that comvbination.
  #set allcombos     [::intuit::worker::removeState $nodes $allcombos]
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


proc ::intuit::worker::getBest {nodelist nodes cells} {

  puts $cells
  puts $nodes
  puts $nodelist
  puts #####################################
  foreach key [dict key $nodelist] {
    if {$key ne "a"} {
      set selectcells [dict get $nodelist $key]
      set highestconnection {}
      set connectionsbycell {}
      puts "$selectcells ::"
      foreach selectcell $selectcells {
        puts "$selectcell :"
          #puts " $key : $selectcell"
        set allconnections [lindex [lindex $cells [expr $selectcell - 1]] 2]
        #filter to only include the right connections in a dictionary
        set i 0
        foreach connection $allconnections {
          if {[lsearch $nodes $i] ne "-1"} {
            dict lappend connectionsbycell [expr $i - 1] $connection
          }
          incr i
        }
        puts $connectionsbycell
      }
    }
  }

    #grab a list of cells
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
      set allcombos    [lrange $allcombos 1 end]
    } elseif {$statecombo eq [llength $allcombos] - 1} {
      set allcombos    [lrange $allcombos 0 end-1]
    } else {
      set allcombos    [concat [lrange $allcombos 0 [expr $statecombo - 1]] [lrange $allcombos [expr $statecombo + 1] end]]
    }
  }
  return $allcombos
}

proc ::intuit::worker::orderedCombos {nodelist nodes cells combos} {

  set comboscores   {}
  foreach combo $combos {
    # calculate its score (including actions for now)
    dict lappend comboscores $combo [::intuit::worker::calcScore $nodes $cells $combo]
    after 2000
    #puts $comboscores
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
  #puts " $previouscells"
  #puts "$statecells"
  set scores {}
  foreach prevcell $previouscells {
    foreach statecell $statecells {
      lappend scores [lindex [lindex $cells $prevcell] $statecell]
      #puts " lindex  lindex $cells 2  $prevcell"
      #puts "[lindex [lindex $cells 2] $prevcell]"
      #puts "[lindex [lindex $cells $prevcell] $statecell]"
    }
  }
  # return a score for all the nodes in the cell
  return [::prepdata::lsum $scores]
  # later we need to make this score better by make it weight adjusted based on what it is - action or input.
}


proc ::intuit::worker::removeZeros {cells combos state} {
  # 1. remove 0s from that list unless its way better than the next one
  # 2. remove ones that have been explored in main and bad already
  # 3. return the top one that passes above
  set i 0
  set break false
  foreach combo $combos {
    set ind 0
    set found0 false
    foreach index $combo {
      if {[lindex [lindex $cells [lindex $combo 1]] [expr $ind]] == 0} {
        set found0 true
      }
    }
    if {!$found0} {
      if {[::intuit::worker::alreadyBeenTried? $combo]} {
      } else {
        break
      }
    }
  }
  return [lindex $combos $i]
}

proc ::intuit::worker::alreadyBeenTried? {cells combo state} {

# go through the node table - find the index of every action.
# go through the combo?     - find which index matches index of action???
# go through the instances  - if lindex 1 of this instance includes eq the action return true


  # get this action from combo
  set i 0
  foreach connection $combo {
    if {[lindex $nodetable [lindex [lindex $cells [lindex $combo 1]] [expr $i]] eq "Action"} {

    }

  }

  set actions
  #get all instances of input state and actions from the db main and bad
  set inputs  [::repo::get::allInstances $state]
  #go through all instances, if the actions are all acounted for
  set didallactions false
  foreach input $inputs {
    if {[lindex $input 1] eq } {

    }
  }

  #return true
  #else return false

  return true
}

proc ::intuit::worker::splitNode {combo} {
  # 4. you'll have to convert cells back to nodes remember. separate input and action when you return it.


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
