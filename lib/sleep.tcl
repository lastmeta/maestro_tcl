# wax is a module for post processing data in order to find hidden structure of
# the data. At this point I'm not sure what that is, but it must correlate
# patterns with each other, realize hierarchy of objects or patterns in the data
# and understand what actions have what effects, both generally and in each
# specific context. It can do this statistically or however you like, but since
# this is a naive system and will only be good at navigating static environments
# it does not have to be too robust. When we find a particular feature that
# might be nice to have the ability to detect we can add it into this wax.tcl
# it is called wax because it is all about discovering the structure.
#
# As an example, if you were playing chess you might fight it very useful to
# have wax tally up all moves of all opponents over time to get a probability
# understanding of what the enemy might do at any given moment.
#
# In 13 I talked about how many actions have an opposite action, going forward
# or back, left or right. etc. if wax started out by detecting this, that would
# probably be best. But like i said lets do it in post processing, so while this
# naisen bot is not busy it can spend its time working on understanding the data
# with the wax modules.

#pkg_mkIndex -verbose [pwd] repo.tcl
#lappend auto_path [pwd]
#package require repo 1.0

namespace eval ::sleep {}
namespace eval ::sleep::find {}
namespace eval ::sleep::find::opposites:: {}
namespace eval ::sleep::update {}

## actions
#
# reviews the database bad and main to try to find a limit to the number of
# actions that do anything. starting at 1 and ending at 999. limit usually < 20.
#
proc ::sleep::find::actions {args} {
  #set min [::repo::get::minAction]
  set max [::repo::get::maxAction]
  set n $max
  incr n
  for {set i 0} {$i < $n} {incr i} {
    lappend actions $i
  }
  ::sleep::update::actions $actions
  return $actions
}

proc ::sleep::update::actions {actions} {
  set actionsid [::repo::get::tableColumnsWhere rules rowid [list type "available actions"]]
  if {$actionsid ne ""} {
    ::repo::update::onId rules rule $actions $actionsid
  } else {
    ::repo::insert rules [list rule $actions type "available actions"]
  }
}


## opposites
#
# searches the database to find the simplest set of moves that produce the
# opposite effect of simple actions. can be thought of as detecting how to undo.
# this is not an exhaustive thing, just samples 100 at random. proof of concept.
#
proc ::sleep::find::opposites {args} {

  set acts [::sleep::find::opposites::getFullMainSample]
  set opps [::sleep::find::opposites::analyzeSample $acts]
  set id [::sleep::find::opposites::recordRule $opps]
  ::sleep::find::opposites::extrapolateRule $opps $id
  return $opps
}

#proc ::sleep::find::opposites::getRandomSample {} {
#  for {set i 0} {$i < 100} {incr i} {
#    set random [::repo::get::randomSet]
#    set input [lindex $random 0]
#    set action [lindex $random 1]
#    set result [lindex $random 2]
#    set opp [::repo::get::actMatch main $result $input]
#    lappend acts [list $action $opp]
#  }
#  return $acts
#}

proc ::sleep::find::opposites::getFullMainSample {} {
  #pull everything from database
  set main [::repo::get::tableColumns main [list input action result]]
  set i 0
  #parse into tripplets
  foreach item $main {
    if {$i == 3} {
      lappend tripplets [list $input $action $result]
      set i 0
    }
    if {$i == 0} {
      set input $item
    } elseif {$i == 1} {
      set action $item
    } elseif {$i == 2} {
      set result $item
    }
    incr i
  }
  #look for opposites.
  foreach tripplet $tripplets {
    set inp [lindex $tripplet 0]
    set act [lindex $tripplet 1]
    set res [lindex $tripplet 2]
    set opp [lsearch -glob $tripplets "$res * $inp"]
    if {$opp ne -1} {
      lappend acts [list $act [lindex [lindex $tripplets $opp] 1]]
    }
  }
  return $acts
}


proc ::sleep::find::opposites::analyzeSample {acts} {
  set opps {}
  set bad {}
  foreach actpair $acts {
    if {![dict exists $opps [lindex $actpair 0]]} {
      dict set opps [lindex $actpair 0] [lindex $actpair 1]
    } elseif {[lsearch $bad [lindex $actpair 0]] ne -1} {
      dict set opps [lindex $actpair 0] {}
    } elseif {[dict get $opps [lindex $actpair 0]] ne [lindex $actpair 1]} {
      lappend bad [lindex $actpair 0]
    }
  }
  return $opps
}

proc ::sleep::find::opposites::recordRule {opps} {
  set id [::repo::get::tableColumnsWhere rules rowid [list type "opposite actions"]]
  if {$id ne ""} {
    ::repo::update::onId rules rule $opps $id
    ::repo::delete::rowsTableColumnValue predictions ruleid $id
  } else {
    ::repo::insert rules [list rule $opps type "opposite actions"]
    set id [::repo::get::tableColumnsWhere rules rowid [list type "opposite actions"]]
  }
  return $id
}

proc ::sleep::find::opposites::extrapolateRule {opps id} {
  #pull everything from database
  set main [::repo::get::tableColumns main [list input action result]]
  set i 0
  #go through everthing one record at a time.
  foreach item $main {
    if {$i == 3} {
      #make a new record in predictions
      if [dict exists $opps $action] {
        lappend predictions [list $result [dict get $opps $action] $input]
        lappend mains [list $input $action $result]
      }
      set i 0
    }
    if {$i == 0} {
      set input $item
    } elseif {$i == 1} {
      set action $item
    } elseif {$i == 2} {
      set result $item
    }
    incr i
  }

  foreach prediction $predictions {
    set search [lsearch $mains [list [lindex $prediction 0] [lindex $prediction 1] [lindex $prediction 2]]]
    if {$search eq -1} {
      puts $search
      ::repo::insert predictions [list input [lindex $prediction 0] action [lindex $prediction 1] result [lindex $prediction 2] ruleid $id]
    }
    #select * from main a Inner Join predictions b on a.input = b.input and a.action = b.action and a.result = b.result
  }
}







## monkey
#
# Learn by watching. Monkey see monkey do. When in this mode the system watches
# the actions of the user and the results of those actions. It records this as
# if its doing the actions itself through the exploritory process.
#
proc ::sleep::find::monkey {args} {

}

## assume
#
# makes assumptions about outcomes of moves it has not made based upon how what
# result similar moves in similar locations have produced. If its in a square,
# for example, it should begin to make assumptions about a straight wall once it
# has bumped into it a few times. And it should assume it will not hit any walls
# but that it's a possibility until it does. If a held assumption is violated it
# should all into question or invalidate all related assumptions. This can be
# thought of then as an edge detection in any abstract space.
# This would require the ability to correlate certain values and patterns to
# certain outcomes which is not naive.
#
proc ::sleep::find::assume {args} {

}



## statistics
#
# searches the database to find out the statistics of noise behaviors and the
# statistics of what outcome each actions produces. Espeically considering
# situations where the state looks the same but the action produces multiple
# states. this is aggregate so its naive, lets do this one.
#
proc ::sleep::find::statistics {args} {

  # process it by by taking an input which is its current location.
  # then you look at where you want to go. then you look at the action that has
  # gotten you the closest to that goal from where the closest place you're at
  # the most amount of time, and do that.

  #
}

## correlations
#
# searches the database to find correlations in the data.
#
proc ::sleep::find::correlations {args} {

}


## causation
#
# searches the database to find causation in the data.
#
proc ::sleep::find::causation {args} {

}


## patterns
#
# searches the database to find patterns in the data.
#
proc ::sleep::find::patterns {args} {

}

## anomalies
#
# searches the database to find anomalies in the data.
#
proc ::sleep::find::anomalies {args} {

}
