namespace eval ::encode {}
namespace eval ::encode::set {}
namespace eval ::encode::map {}
namespace eval ::encode::update {}
namespace eval ::encode::connections {}

################################################################################
# Set ##########################################################################
################################################################################

proc ::encode::set::globals {} {
  set ::encode::cellspernode 4
  set ::encode::cells 0
  set ::encode::predictive {}
  set ::encode::active {}
  set ::encode::prevactive {}
  ::encode::set::actions
}

proc ::encode::set::actions {} {
  set max [::repo::get::maxNode]
  if {$max eq "{}"} {
    for {set i 0} {$i < 100} {incr i} {
      ::repo::insert nodes     [list node   $i input $i ix a type action]
      ::repo::insert connectom [list cellid $i cell  0]
      set max $i
    }
  }
  set ::encode::cells [expr $max * $::encode::cellspernode]
}

################################################################################
# Encode #######################################################################
################################################################################

proc ::encode::this {input action} {
  if {$::memorize::learn eq "no"} { return }

  ::encode::map::input  $input
  ::encode::map::action $action

  ::encode::update::connectom

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
      for {set j 0} {$j < $::encode::cellspernode} {incr j} {
        ::repo::insert connectom [list cellid $j cell 0]
      }
    }
  }
}

proc ::encode::map::action {action} {
  if {$action ne ""} {
    set max [::repo::get::maxNode]
    if {[::repo::get::nodeMatch $action a action ] eq ""} {
      incr max
      ::repo::insert nodes [list node $max input $action ix a type action]
    }
  } else {
      puts [::repo::get::nodeTable]
  }
}

################################################################################
# update #######################################################################
################################################################################

proc ::encode::update::connectom {} {
  set max [::repo::get::maxNode]
  set max [expr $max * $::encode::cellspernode]
  if {$max > $::encode::cells} {
    set ::encode::cells $max
    for {set i 0} {$i <= $max} {incr i} {
      set cell [::repo::get::cell $i]
      for {set j [llength $cell]} {$j <= $max} {incr j} {
        lappend cell 0
      }
      ::repo::update::cell $i $cell
    }
  }
}


################################################################################
# connections ##################################################################
################################################################################



proc ::encode::connections::activation {input} {
  # steps:
    # set ::encode::prevactive $::encode::active
    # foreach index in input
      # find the approapriate node number
      # if no predictive cells are found in the node
        # set all cells in node to be active:
        # foreach cell in node
          # set to active
      # elseif there are predictive cells
        # set the most predicted cell to active
    # modify connections of predicted failures  by 1
    # make new predictions - every connection over connection limit of every active cell
    # update connections:
    # get every previously active. go through each list.
      # if active @ active index
        # increase by 10
  set max [::repo::get::maxNode]
  set max [expr $max * $::encode::cellspernode]
  if {$max > $::encode::cells} {
    set ::encode::cells $max
    for {set i 0} {$i <= $max} {incr i} {
      set cell [::repo::get::cell $i]
      for {set j [llength $cell]} {$j <= $max} {incr j} {
        lappend cell 0
      }
      ::repo::update::cell $i $cell
    }
  }
}
