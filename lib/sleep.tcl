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
namespace eval ::sleep::find::effects:: {}
namespace eval ::sleep::find::always:: {}
namespace eval ::sleep::find::regions:: {}
namespace eval ::sleep::update {}
namespace eval ::sleep::help {}
## actions
#
# reviews the database bad and main to try to find a limit to the number of
# actions that do anything. starting at 1 and ending at 999. limit usually < 20.
#
proc ::sleep::find::actions {args} {
  # this should look at everthing that's in the list already of available actions
  # then take that as a pool of actions. if the rule doesn't exist already it should
  # just consider the pool to be all actions. then it should remove things from the poool
  # based when it sees they have failed to produce results. that way it doesn't miss anything.
  # that would be a subtractive rather than an addititve approach.
  return [::sleep::update::actions [::sleep::help::getListOfActionsInMain]]
}

proc ::sleep::update::actions {actions} {
  ::repo::delete::rowsTableColumnValue rules type "available actions"
  ::repo::insert rules [list rule $actions type "available actions"]
  return $actions
}














################################################################################################################################################################
# opps #########################################################################################################################################################
################################################################################################################################################################



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
  if {$opps ne ""} {
    ::sleep::find::opposites::extrapolateRule $opps $id
  }
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
  if {[info exists acts]} {
    return $acts
  }

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
      ::repo::insert predictions [list input [lindex $prediction 0] action [lindex $prediction 1] result [lindex $prediction 2] ruleid $id]
    }
    #select * from main a Inner Join predictions b on a.input = b.input and a.action = b.action and a.result = b.result
  }
}







################################################################################################################################################################
# effets #########################################################################################################################################################
################################################################################################################################################################









# effects
#
# searches the database to find which index is affected by each action. If more
# than one index can be affected by this action, then it references each effect
# and it's raw input.
#
proc ::sleep::find::effects {predict} {
  ::sleep::find::effects::clear
  set actions [::sleep::help::getListOfActionsInMain]
  ::sleep::find::effects::discover $actions $predict
  return "sleep effects finished"
}


proc ::sleep::find::effects::clear {} {
  ::repo::delete::rowsTableColumnValue rules type "general effects"
  ::repo::delete::rowsTableColumnValue rules type "special effects"
}


proc ::sleep::find::effects::discover {actions predict} {
  foreach action $actions {
    set inputs  [::repo::get::tableColumnsWhere main input  [list action $action]]
    set results [::repo::get::tableColumnsWhere main result [list action $action]]
    set rowids  [::repo::get::tableColumnsWhere main rowid  [list action $action]]

    if {$predict eq yes} {
      lappend inputs  [::repo::get::tableColumnsWhere predictions input  [list action $action]]
      lappend results [::repo::get::tableColumnsWhere predictions result [list action $action]]
      lappend rowids  [::repo::get::tableColumnsWhere predictions rowid  [list action $action]]
    }

    set dictionary ""
    foreach input $inputs result $results id $rowids {
      set n [string length $input]
      set indexes ""
      for {set i 0} {$i < $n} {incr i} {
        if {[string index $input $i] ne [string index $result $i]} {
          lappend indexes $i
        }
      }
      if {[dict exists $dictionary $indexes] eq ""} {
        dict set dictionary $indexes $id
      } else {
        dict lappend dictionary $indexes $id
      }
    }
    if {[llength $dictionary] < 2 } {
      puts "something is wrong"
    } elseif {[llength $dictionary] == 2} { ;# if there is only one make a general rule
      ::repo::insert rules    [list rule [list $action [dict keys $dictionary]] type "general effects"]
    } else {
      # IDEAL:
      # if there are more than one...
      #   find the one with the most ids and make that a general rule
      #   with all the others make a special rule with the ids in the mainid field.
      # PRACTICAL:
      #   make a special rule with the ids in the mainid field for all of them
      foreach key [dict keys $dictionary] {
        ::repo::insert rules [list rule [list $action $key] type "special effects" mainids [dict get $dictionary $key]]
      }
    }
  }
  return $actions
}







################################################################################################################################################################
# always #########################################################################################################################################################
################################################################################################################################################################







# always
#
# searches the database to find which actions always have the same effect on
# indexes and what those same affects are. For example: on a numberline action
# number 3 may always turn the last index to 8 if the last index was 9 and it
# will not effect the rest. Thus __9 --3--> __8 and concretely:
#
#   state   act   newstate  #   state   act   newstate
#   __0     1     __1       #   _10     3     _09
#   __1     1     __2       #   __1     3     __0
#   __2     1     __3       #   __2     3     __1
#   __3     1     __4       #   __3     3     __2
#   __4     1     __5       #   __4     3     __3
#   __5     1     __6       #   __5     3     __4
#   __6     1     __7       #   __6     3     __5
#   __7     1     __8       #   __7     3     __6
#   __8     1     __9       #   __8     3     __7
#   _09     1     _10       #   __9     3     __8
#   ...     ...   ...
#

proc ::sleep::find::always {predict} {
  ::sleep::find::always::clear
  set actions [::sleep::help::getListOfActionsInMain]
  ::sleep::find::always::discover $actions $predict
  return "sleep always finished"
}


proc ::sleep::find::always::clear {} {
  # ::repo::delete::rowsTableColumnValue rules  type "general always"
  # ::repo::delete::rowsTableColumnValue rules  type "special always"
  ::repo::delete::rowsTableColumnValue generals type "general always"
  ::repo::delete::rowsTableColumnValue generals type "special always"
}


proc ::sleep::find::always::discover {actions predict} {
  foreach action $actions {

    set inputs  [::repo::get::tableColumnsWhere main input  [list action $action]]
    set results [::repo::get::tableColumnsWhere main result [list action $action]]

    if {$predict eq yes} {
      lappend inputs  [::repo::get::tableColumnsWhere predictions input  [list action $action]]
      lappend results [::repo::get::tableColumnsWhere predictions result [list action $action]]
    }

    set dictionary ""
    foreach input $inputs result $results {
      set n [string length $input]
      set instr  ""
      set restr  ""
      for {set i 0} {$i < $n} {incr i} {
        if {[string index $input $i] eq [string index $result $i]} {
          set instr $instr\_
          set restr $restr\_
        } else {
          set instr $instr[string index $input  $i]
          set restr $restr[string index $result $i]
        }
      }
      if {[dict exists $dictionary $instr] eq "0"} {
        dict set dictionary $instr $restr
      } elseif {[lsearch [dict get $dictionary $instr] $restr] eq "-1"} {
        dict lappend dictionary $instr $restr
      }
    }
    puts $dictionary
    foreach key [dict keys $dictionary] {
      set value [dict get $dictionary $key]
      if {[llength $value] == 1} {
        # ::repo::insert rules  [list rule [list $key        $action        $value] type "general always"]
        ::repo::insert generals [list input      $key action $action result $value  type "general always"]
      } elseif {[llength $value] > 1} {
        foreach item $value {
          # ::repo::insert rules  [list rule [list $key        $action        $item] type "special always"]
          ::repo::insert generals [list input      $key action $action result $item  type "special always"]
        }
      }
    }
  }
}










################################################################################################################################################################
# regions #########################################################################################################################################################
################################################################################################################################################################







# regions
#
# creates regions and levels according to the data.
#
#   state   act   newstate  #   state   act   newstate
#   __0     1     __1       #   _10     3     _09
#   __1     1     __2       #   __1     3     __0
#   __2     1     __3       #   __2     3     __1
#   __3     1     __4       #   __3     3     __2
#   __4     1     __5       #   __4     3     __3
#   __5     1     __6       #   __5     3     __4
#   __6     1     __7       #   __6     3     __5
#   __7     1     __8       #   __7     3     __6
#   __8     1     __9       #   __8     3     __7
#   _09     1     _10       #   __9     3     __8
#   ...     ...   ...
#

proc ::sleep::find::regions {} {
  ::sleep::find::regions::clear
  ::sleep::find::regions::discover 0
  return "sleep regions finished"
}


proc ::sleep::find::regions::clear {} {
  ::repo::delete::clear regions
  ::repo::delete::clear roots
}


proc ::sleep::find::regions::discover {thislevel} {
  #init vars
  set mainid 1
  set origin [::repo::get::tableColumnsWhere main input [list rowid $mainid]]
  set oldresults origin
  set next 1
  set rcount 0

  #put origin in roots table
  ::repo::insert roots [list level $thislevel region $rcount state $origin ]
  incr rcount

  set root [::sleep::find::regions::roots $next]

  #for each item in roots table
  while {$root ne "none left"} {
    set level  [lindex $root 0]
    set region [lindex $root 1]
    set state  [lindex $root 2]

    #get a list of results from main concerning the state.
    set results [::repo::get::tableColumnsWhere main result [list input $state]]

    #get a list of results from main concerning the each result in results
    set seconds [::repo::get::chainMatchResults main input $results]

    foreach item $seconds {
      if {[lsearch $results    $item] eq "-1"
      &&  [lsearch $oldresults $item] eq "-1"
      } then {
        #put in roots
        ::repo::insert roots [list level $level region $rcount state $origin ]
        incr rcount

        #make a region to region with main id in middle
        ::repo::insert regions [list level $level region $region mainid $mainid reg_to $rcount]

      } elseif {[lsearch $results $item] eq "-1"} {
        #find correct region of for reg_to
        set findroot [::repo::get::tableColumnsWhere roots region [list state $item]]
        if {$findroot ne ""} {
          #make a region to region with main id in middle
          ::repo::insert regions [list level $level region $region mainid $mainid reg_to $findroot]

        #if its not a root of a region
        } else {
          #its possible to belong to more than one region so we have to make connections between all of them.
          set inputs [::repo::get::tableColumnsWhere main input [list result $item]]
          foreach thing $inputs {
            set findroot [::repo::get::tableColumnsWhere roots region [list state $thing]]
            if {$findroot ne ""} {
              ::repo::insert regions [list level $level region $region mainid $mainid reg_to $findroot]
            }
          }
        }
      }
    }
    incr next
    set root [::sleep::find::regions::roots $next]
  }
}

proc ::sleep::find::regions::roots {next} {
  set return [::repo::get::tableColumnsWhere roots [list level region state] [list rowid $next]]
  if {$return eq ""} {
    set return "none left"
  }
  return $return
}


################################################################################################################################################################
# others #########################################################################################################################################################
################################################################################################################################################################







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



























################################################################################################################################################################
# help #########################################################################################################################################################
################################################################################################################################################################


proc ::sleep::help::getListOfActionsInMain {} {
  set actions ""
  for {set i 1} {$i < 100} {incr i} {
    if {[::repo::get::tableColumnsWhere main result [list action $i]] ne ""} {
      lappend actions $i
    }
  }
  return $actions
}
