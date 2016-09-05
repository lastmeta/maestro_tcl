namespace eval ::encode {}
namespace eval ::encode::set {}
namespace eval ::encode::map {}
namespace eval ::encode::update {}
namespace eval ::encode::connections {}

################################################################################
# Set ##########################################################################
################################################################################

proc ::encode::set::globals {} {
  set ::encode::cellspernode  4
  set ::encode::cells         0
  set ::encode::lastactive    {}
  set ::encode::active        {}
  set ::encode::predictive    {}
  set ::encode::incre         10
  set ::encode::decre         1
  set ::encode::limit         {}
  ::encode::set::actions
}

proc ::encode::set::actions {} {
  set max [::repo::get::maxNode]
  if {$max eq "{}"} {
    set send ""
    set base ""
    for {set i 0} {$i < $::encode::cellspernode } {incr i} {
      set base [concat 0 $base]
    }
    for {set i 1} {$i < 100 } {incr i} {
      ::repo::insert nodes     [list node   $i input $i ix a type action]
      set send [concat $base $send]
    }
    set max [::repo::get::maxNode]
    for {set i 0} {$i < ($max * $::encode::cellspernode)} {incr i} {
      ::repo::insert connectom [list cellid $i cell $send]
    }
  }
  set ::encode::cells [expr $max * $::encode::cellspernode]
}

proc ::encode::set::cellspernode {cellspernode} {
  if {$cellspernode > 10} {
    set ::encode::cellspernode 10
  } elseif {$cellspernode < 2} {
    set ::encode::cellspernode 2
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

proc ::encode::set::activation {} {
  set ::encode::lastactive $::encode::active
  set ::encode::active ""
}

################################################################################
# Encode #######################################################################
################################################################################

proc ::encode::this {input action} {
  if {$::memorize::learn eq "no"} { return }

  ::encode::map::input  $input
  ::encode::map::action $action

  ::encode::update::connectom

  # update last cells to be old cells
  ::encode::set::activation

  #::encode::connections::activation $input $action
  #::encode::connections::predictions
  #::encode::connections::structure
}


################################################################################
# map ##########################################################################
################################################################################


proc ::encode::map::input {input} {
  set max [::repo::get::maxNode]
  for {set i 0} {$i < [string length $input]} {incr i} {
    if {[::repo::get::nodeMatch [string index $input $i] $i state ] eq ""} { ;# alternatively, get all of node and search through it manually.
      incr max
      ::repo::insert nodes [list  node   $max  input [string index $input $i]  ix $i   type state]
      ::encode::map::cells $max
    }
  }
}

proc ::encode::map::action {action} {
  if {$action ne ""} {
    set max [::repo::get::maxNode]
    if {[::repo::get::nodeMatch $action a action ] eq ""} {
      incr max
      ::repo::insert nodes [list node $max input $action ix a type action]
      ::encode::map::cells $max
    }
  } else {
      #debug purposes try __ yeilds:
      #puts [::repo::get::nodeTable]
  }
}

proc ::encode::map::cells {max} {
  for {set j 0} {$j < $::encode::cellspernode} {incr j} {
    ::repo::insert connectom [list cellid [expr $j + ($max * $::encode::cellspernode)] cell 0]
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

    # get change and reset number of cells to max
    set dif [expr $max - $::encode::cells]
    set ::encode::cells $max

    # filter through every cell
    for {set i 0} {$i <= $max} {incr i} {

      # get all the connections this cell has.
      set cell [::repo::get::cell $i]
      puts "cell length: [llength [lindex $cell 0]]"

      # add on 0's for new connections to new cells.
      #for {set j [llength $cell]} {$j <= $max} {incr j} {
      #  set cell [concat $cell 0]
      #}
      set newcell ""
      for {set j 0} {$j < $max} {incr j} {
        if {$j <= [llength [lindex $cell 0]]} {
          set newcell "$newcell [lindex [lindex $cell 0] $j]"
        } else {
          set newcell "$newcell 0"
        }

      # update database
      ::repo::update::cell $i $cell
    }
  }
}


################################################################################
# connections ##################################################################
################################################################################


proc ::encode::connections::each {input index type} {

  # find the approapriate node number
  set node [::repo::get::nodeMatch $input $index $type]
  if {$node eq ""} { puts "error cell not found" ; exit }

  # figure out which cells in that node are predictive
  set predicted {}
  set count     {}
  for {set j 0} {$j < $::encode::cellspernode} {incr j} {
    set cell [expr ($node * $::encode::cellspernode) + $j]
    set found [lsearch -all $::encode::lastactive $cell]
    if {$found ne "-1"} {
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
    return [lindex $predicted [lsearch $count $maxcount]]
  }
}


proc ::encode::connections::activation {input action} {

  # foreach index in input
  for {set i 0} {$i < [string length $input]} {incr i} {
    lappend ::encode::active [::encode::connections::each [string index $input $i] $i state]
  }
  lappend ::encode::active [::encode::connections::each $action a action]
}

# make new predictions
proc ::encode::connections::predictions {} {

  set ::encode::predictive {}

  # every active cell
  foreach cellid $::encode::active {
    set connections [::repo::get::cell $cellid]

    # every connection
    set i 0
    foreach connection $connections {

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

  # get every previously active.
  foreach cellid $::encode::lastactive {
    set connections [::repo::get::cell $cellid]
    set newconnections {}
    set i 0

    # go through each list.
    foreach connection $connections {

      # if active @ active index
      if {[lsearch $::encode::acitve $i] } {

        # increase by 10
        set add [expr $connection + $::encode::incre]
        if {$add > 100} { set add 100 }
        lappend newconnections $add

      # else if it was a prediction that didn't get fulfilled
      } else {

        # decrease by 1
        set sub [expr $connection - $::encode::decre]
        if {$sub < 0} { set sub 0 }
        lappend newconnections $sub
      }
      incr i
    }
    ::repo::update::cell $cellid $newconnections
  }
}
