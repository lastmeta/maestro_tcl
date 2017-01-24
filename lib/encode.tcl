# encode is being used now in a prost processing (sleep) manner
# thus we've commented out, or never call, much of it's functionality.
# it doens't use cells at all, just nodes, to help us later create a
# sparsely distributed binary vector for states, used to
# evaluate and create a list of signature representations for regions
# as a generalization / context approximation tool

namespace eval ::encode {}
namespace eval ::encode::set {}
namespace eval ::encode::map {}
namespace eval ::encode::sleep {}
namespace eval ::encode::prune {}
namespace eval ::encode::update {}
namespace eval ::encode::connections {}


################################################################################
# Set ##########################################################################
################################################################################

proc ::encode::set::globals {} {
  set ::encode::cellspernode  1
  set ::encode::cells         0
  set ::encode::active        {}
  set ::encode::lastactive    {}
  set ::encode::predictive    {}
  set ::encode::incre         10
  set ::encode::decre         1
  set ::encode::limit         20
  set ::encode::lastaction    {}
  #::encode::set::actions
}

proc ::encode::set::actions {} {
  set max [::repo::get::maxNode]
  if {$max eq "{}"} {
    set send ""
    set base ""
    for {set i 0} {$i < $::encode::cellspernode } {incr i} {
      set base [concat 0 $base]
    }
    for {set i 1} {$i <= 20 } {incr i} {
      ::repo::insert nodes     [list  node  $i     \
                                      input $i     \
                                      ix    a      \
                                      type  action ]
      set send [concat $base $send]
    }
    set max [::repo::get::maxNode]
    for {set i 0} {$i < ($max * $::encode::cellspernode)} {incr i} {
      ::repo::insert connectom [list  node    [expr $i + 1] \
                                      cellid  $i            \
                                      cell    $send         ]
    }
  }
  set ::encode::cells [expr $max * $::encode::cellspernode]
}

proc ::encode::set::cellspernode {cellspernode} {
  if {$cellspernode > 10} {
    set ::encode::cellspernode 10
  } elseif {$cellspernode < 1} {
    set ::encode::cellspernode 1
  } else {
    set ::encode::cellspernode $cellspernode
  }
}

proc ::encode::set::limit {limit} {
  if {$limit > 100} {
    set ::encode::limit 100
  } elseif {$limit < 1} {
    set ::encode::limit 1
  } else {
    set ::encode::limit $limit
  }
}

proc ::encode::set::incre {incre} {
  if {$incre > 100} {
    set ::encode::incre 100
  } elseif {$incre < $::encode::decre} {
    set ::encode::incre $::encode::decre
  } else {
    set ::encode::incre $incre
  }
}

proc ::encode::set::decre {decre} {
  if {$decre > $::encode::incre} {
    set ::encode::decre $::encode::incre
  } elseif {$decre < 0} {
    set ::encode::decre 0
  } else {
    set ::encode::decre $decre
  }
}

proc ::encode::set::activation {action} {
  # update last cells to be old cells
  set ::encode::lastactive $::encode::active
  set ::encode::active ""
}

################################################################################
# Encode #######################################################################
################################################################################

proc ::encode::this {input} {
  if {$::memorize::encode eq "no"} { return }

  set action $::encode::lastaction

  ::encode::map::input  $input
  ::encode::map::action $action

  ::encode::update::connectom

  ::encode::set::activation $action
  ::encode::connections::activation $input $action
  ::encode::connections::predictions
  ::encode::connections::structure
}

proc ::encode::sleep::this {input} {
  set max [::repo::get::maxNode]
  if {$max eq "{}"} { set max 0 }
  for {set i 0} {$i < [string length $input]} {incr i} {
    if {[::repo::get::nodeMatch [string index $input $i] $i state ] eq ""} { ;# alternatively, get all of node and search through it manually.
      incr max
      ::repo::insert nodes [list node $max input [string index $input $i] ix $i type state]
    }
  }
}

proc ::encode::sleep::sdr {input} {
  set max   [::repo::get::maxNode]
  set nodes ""
  set sdr ""
  for {set i 0} {$i < [string length $input]} {incr i} {
    set match [::repo::get::nodeMatch [string index $input $i] $i state]
    if {$match eq "" || $match eq "{}"} {
      return "" ;# redo sleep regions
    }
    lappend nodes $match
  }

  for {set i 0} {$i < $max} {incr i} {
    if {[lsearch $nodes $i] eq "-1"} {
      lappend sdr 0.0
    } else {
      lappend sdr 1.0
    }
  }
  return [list $nodes $sdr]
}

################################################################################
# map ##########################################################################
################################################################################

# is this input new? then make a new node
proc ::encode::map::input {input} {
  set max [::repo::get::maxNode]
  for {set i 0} {$i < [string length $input]} {incr i} {
    if {[::repo::get::nodeMatch [string index $input $i] $i state ] eq ""} { ;# alternatively, get all of node and search through it manually.
      ::encode::map::cells $max
      incr max
      ::repo::insert nodes [list  node   $max  input [string index $input $i]  ix $i   type state]
    }
  }
}

proc ::encode::map::action {action} {
  if {$action ne ""} {
    set max [::repo::get::maxNode]
    if {[::repo::get::nodeMatch $action a action ] eq ""} {
      ::encode::map::cells $max
      incr max
      ::repo::insert nodes [list node $max input $action ix a type action]
    }
  } else {
      #debug purposes try __ yeilds:
      #puts [::repo::get::nodeTable]
  }
}

proc ::encode::map::cells {max} {
  for {set j 0} {$j < $::encode::cellspernode} {incr j} {
    ::repo::insert connectom [list node   [expr  $max                            + 1  ] \
                                   cellid [expr ($max * $::encode::cellspernode) + $j ] \
                                   cell   0                                             ]
  }
}

################################################################################
# update #######################################################################
################################################################################

proc ::encode::update::connectom {} {
  # get the number of cells we should have
  set max [::repo::get::maxNode]
  set max [expr $max * $::encode::cellspernode]

  # only do something if that number has changed
  if {$max > $::encode::cells} {

    # reset number of cells to max
    set ::encode::cells $max

    # filter through every cell
    for {set i 0} {$i <= $max} {incr i} {

      # get all the connections this cell has.
      set cell [::repo::get::cell $i]

      # add on 0's for new connections to new cells.
      set newcell ""
      for {set j 0} {$j < $max} {incr j} {
        if {$j < [llength [lindex $cell 0]]} {
          set newcell "$newcell [lindex [lindex $cell 0] $j]"
        } else {
          set newcell "$newcell 0"
        }
      }

      # update database
      ::repo::update::cell $i $newcell
    }
  }
}


################################################################################
# connections ##################################################################
################################################################################


proc ::encode::connections::each {input index type} {

  # find the approapriate node number
  set node [::repo::get::nodeMatch $input $index $type]
  if {$node eq ""} { puts "error cell not found $input $index $type" ; exit }
  set node [expr $node - 1]

  # figure out which cells in that node are predictive
  set predicted {}
  set count     {}
  for {set j 0} {$j < $::encode::cellspernode} {incr j} {
    set cell [expr ($node * $::encode::cellspernode) + $j]
    set found [lsearch -all $::encode::predictive $cell]
    if {$found ne "-1" && $found ne ""} {
      lappend predicted $cell
      lappend count     [llength $found]
    }
  }

  # if no predictive cells are found in the node
  if {$predicted eq ""} {

    # set all cells in node to be active:
    for {set j 0} {$j < $::encode::cellspernode} {incr j} {
      lappend ::encode::active [expr ($node * $::encode::cellspernode) + $j]
    }

  # elseif there are predictive cells
  } else {

    # set the most predicted cell to active
    set maxcount 0
    foreach number $count {
      if {$number > $maxcount} {
        set maxcount $number
      }
    }

    # if there are more than one with the most predicted score, choose a random one.
    set potentialactivelist [lsearch -all $count $maxcount]
    lappend ::encode::active [lindex $predicted [::prepdata::randompick $potentialactivelist]]
  }
}


proc ::encode::connections::activation {input action} {

  # foreach index in input
  for {set i 0} {$i < [string length $input]} {incr i} {
    ::encode::connections::each [string index $input $i] $i state
  }
  if {$action ne ""} {
    ::encode::connections::each $action a action
  }

}

# make new predictions
proc ::encode::connections::predictions {} {

  set ::encode::predictive {}

  # every active cell
  foreach cellid $::encode::active {
    set connections [::repo::get::cell $cellid]

    # every connection
    set i 0
    foreach connection [lindex $connections 0] {

      # over connection limit of 20
      if {$connection > $::encode::limit} {
        lappend ::encode::predictive $i
      }

      incr i
    }
  }
}

# update structure:
proc ::encode::connections::structure {} {
  #puts "STRUCTURE:[lindex [lindex [::repo::get::cell 4] 0] 17]"
  # get every previously active.
  foreach cellid $::encode::lastactive {
    set connections [::repo::get::cell $cellid]
    set newconnections {}
    set i 0

    # go through each list.
    foreach connection [lindex $connections 0] {

      # if active @ active index... and this cell is not an action cell?
      if {[lsearch $::encode::active $i] ne "-1"} {

        # increase by 10
        set add [expr $connection + $::encode::incre]
        if {$add > 1000000000} { set add 1000000000 }
        set newconnections "$newconnections $add"

      # else if it was a prediction that didn't get fulfilled
      } else {

        # decrease by 1 but not less than 1
        if {$connection > 0} {
          set sub [expr $connection - $::encode::decre]
          if {$sub < 1} { set sub 1 }
          set newconnections "$newconnections $sub"
        } else {
          set newconnections "$newconnections 0"
        }
      }
      incr i
    }
    ::repo::update::cell $cellid $newconnections
  }
}




################################################################################
# prune ########################################################################
################################################################################


proc ::encode::prune::node {input index type} {

  # get node id
  set originalmax [::repo::get::maxNode]
  set node [::repo::get::nodeMatch $input $index $type]
  if {$node eq ""} { puts "error cell not found: input;$input index;$index type;$type" ; exit }

  # delete node
  ::repo::delete::rowsTableColumnValue nodes node $node

  # rename each node of higher value.
  set max [::repo::get::maxNode]
  for {set i [expr $node + 1]} {$i <= $max} {incr i} {
    ::repo::update::node node [expr $i - 1] $i
  }

  #delete corresponding cells
  ::encode::prune::cells $node $originalmax

}


proc ::encode::prune::cells {node maxnode} {

  # delete all indexes of those cells in all other cells
  set start [expr ($node * $::encode::cellspernode) - $::encode::cellspernode]
  set max [expr $maxnode * $::encode::cellspernode]
  for {set i 0} {$i <= $max} {incr i} {
    set cell [::repo::get::cell $i]
    set newcell ""
    for {set j 0} {$j < $max} {incr j} {
      if {$j < $start || $j >= [expr $start + $::encode::cellspernode] } {
        set newcell "$newcell [lindex [lindex $cell 0] $j]"
      }
    }
    ::repo::update::cell $i $newcell
  }

  # delete cells of that node
  for {set i 0} {$i < $::encode::cellspernode} {incr i} {
    ::repo::delete::rowsTableColumnValue connectom cellid [expr ($node * $::encode::cellspernode) - $::encode::cellspernode + $i]
  }

  # rename each cell of higher value than the lowest cell
  for {set i [expr $start + $::encode::cellspernode]} {$i < $max} {incr i} {
    ::repo::update::cellid [expr $i - $::encode::cellspernode] $i
  }

  # set max cells variable
  set max [::repo::get::maxNode]
  set max [expr $max * $::encode::cellspernode]
  set ::encode::cells $max ;# set it to $i - 1 - $::encode::cellspernode should be the same thing
}
