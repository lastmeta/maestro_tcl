#pkg_mkIndex -verbose [pwd] repo.tcl
#lappend auto_path [pwd]
#package require repo 1.0

#pkg_mkIndex -verbose [pwd]/prep prepdata.tcl
#lappend auto_path [pwd]/prep
#package require prepdata 1.0

namespace eval ::recall {}
namespace eval ::candle::record {}
namespace eval ::candle::helpers {}
#testing:
#::repo::create 1.1

## main input as word, goal as word
#
# Takes input and goal, returns a list of actions to get to the goal, or to get
# as close as it can.
#
# example:  000 123
# returns:  0 1 2
#
proc ::candle::main {input goals} {
  puts "going from $input to $goals."
  if {$input                  eq $goals } { return "$input __" }
  if {[lsearch $goals $input] >= 0      } { return "$input __" }
  if {$input eq {} || $goals eq {}      } { return "" }

  if {[llength $goals] > 1} {
    set $goals [::candle::orderGoals $input $goals]
  }

  foreach goal $goals {
    set chain [::candle::helpers::savedChain $input $goal]
    if { $chain ne ""} {
      return $chain
    }

    set actions ""
    set newgoal [getBestGoal $goal]
    set actions [getActionsPathWithPrediction $input $newgoal]

    set Comment "\
      this is how we set the actions if we are only using the main table:\
      set actions [getActionsPath $input $newgoal]"

    if { [lindex $actions 0] eq "_"} {
      #its a suggestion because we couldn't find the exact answer.
      #lindex $actions 1 = suggested action
      #lindex $actions 2 to last=list of inputs having direct connection to goal
      #how to proceed: if this is a new input we've never seen before
      # random movement until we find a path to something we have seen?
      # - look for a path to each of the list, if none found, do random
      #50/50 chance of taking the advice or doing something random.
    } elseif {$actions eq "" } {
      #do nothing
    } else {
      return [concat $newgoal $actions] ;# its some legit actions
    }
  }
}

## orderGoals goals as list
#
# takes a list of potential goals and orders them based upon which goal is
# closest looking to our current input. then takes that list and reorders them
# based upon whats in the database, if there is a match it gets moved to the
# front.
#
# example:  100 {925 310 101 020}
# returns:  {101 310 020 925}
#
proc ::candle::orderGoals {input goals} {
  set goals [::prepdata::helpers::reorderByMatch $input $goals]
  set a ""
  set b ""
  foreach goal $goals {
    if {[::repo::get::exactResult main $goal] ne ""} {
      lappend a $goal
    } else {
      lappend b $goal
    }
  }
  return [concat $a $b]
}

## getBestGoal goal as word
#
# looks for the goal in the database. If it is found, returns goal. else returns
# the goal with the most matching bits. This is why its important that the state
# of the system be represented with the most semantically accurate encoding as
# possible. Could also return a list of best matches for others to choose.
#
# example:  134
# returns:  104
#
proc ::candle::getBestGoal {goal} {
  set c 0
  set combos [::prepdata::combinations $goal]
  set newresults ""
  foreach combo $combos {
    lappend newresults [::repo::get::byResultsLike main [lindex $combos $c]]
    lappend newresults [::repo::get::byResultsLike predictions [lindex $combos $c]]
    incr c
  }
  return [::candle::getBestMatch $goal $newresults]
}

## getBestMatch goal as word, newresults as list
#
# looks for the goal the list you give it. returns the closest match.
#
# example:  000 {134 032 104}
# returns:  032
#
proc ::candle::getBestMatch {goal newresults} {

  set bestscore 0
  set bestresult ""
  set bestresults ""
  foreach newresult $newresults {
    set newscore [::prepdata::helpers::scoreByMatch $goal $newresult]
    if {$newscore > $bestscore} {
      set bestresult $newresult
      set bestresults $newresult
      set bestscore $newscore
    } elseif {$newscore == $bestscore} {
      lappend bestresults $newresult
    }
  }
  set bestresults [lsort -unique $bestresults]
  return $bestresult
}

## getCombos word as word, changebits as list
#
# takes a dense representation. Returns a dictionary of all possible
# combinations of changed bits and unchanged bits.
#
# example:  abc {0 2}
# returns:  0 {a__ a_c ab_ abc} 2 {__c a_c _bc abc}
#
proc ::candle::getCombos {word changebits} {
  set wordcombos ""
  foreach bit $changebits {
    lappend wordcombos $bit [::prepdata::combinations $word $bit $changebits]
  }
  return $wordcombos
}
## getActionsPathWithPrediction input as word, goal as word
#
# Takes an input and a goal. Searches two locations: the main and the prediction
# tables in the database to find a path from the goal, back to the input, while
# at the same time it looks for the goal starting at the input. As soon as it
# finds a place where the two intersect it finds the path and compiles the list
# of actions that must be taken to get there. Finds the shortest possible path.
# Returns the list of actions if one is found. If one is not found it finds the
# input in the list that is closest to the input passed to it and returns that.
#
# example:  000 002
# returns:  +1 +1
#
proc ::candle::getActionsPathWithPrediction {input goal} {
  set ::actionslist ""
  #initialize everything
  set tiloc "" ;#temporary input location
  set tiact ""
  set tires ""

  set tgloc ""
  set tgact ""
  set tgres ""

  set iloc "" ;#large list input location
  set iact ""
  set ires ""

  set gloc ""
  set gact ""
  set gres ""

  set go $goal
  set in $input
  set temp ""
  set match ""

  while {($go ne "" || $in ne "") && $match eq ""} {
    #get all the goals

    set temp ""
    if {$go ne ""} {
      set temp [concat [::repo::get::chainMatch main result $go] \
                       [::repo::get::chainMatch predictions result $go]]
    }
    set c 0
    set tgloc ""
    set tgact ""
    set tgres ""
    set go ""
    foreach item $temp {
      if {$c == 0} {
        if {[lsearch [concat $gloc $tgloc] $item] == -1} {
          lappend tgloc $item
          lappend go $item
        } else {
          set c -3
        }
      } elseif {$c == 1} {
        lappend tgact $item
      } elseif {$c == 2} {
        lappend tgres $item
        set c -1
      }
      incr c
    }

    #fill the temporary inputs out.
    set temp ""
    if {$in ne ""} {
      set temp [concat [::repo::get::chainMatch main input $in] \
                       [::repo::get::chainMatch predictions input $in]]
    }
    set c 0
    set tiloc ""
    set tiact ""
    set tires ""
    set in ""
    foreach item $temp {
      if {$c == 0} {
          lappend tiloc $item
      } elseif {$c == 1} {
        lappend tiact $item
      } elseif {$c == 2} {
        if {[lsearch [concat $ires $tires] $item] == -1} {
          lappend tires $item
          lappend in $item
        } else {
          set tiloc [lrange $tiloc 0 [expr [llength $tiloc]-2]]
          set tiact [lrange $tiact 0 [expr [llength $tiact]-2]]
        }
        set c -1
      }
      incr c
    }

    #fill the long lists with what we found
    set iloc [concat $iloc $tiloc]
    set iact [concat $iact $tiact]
    set ires [concat $ires $tires]

    set gloc [concat $gloc $tgloc]
    set gact [concat $gact $tgact]
    set gres [concat $gres $tgres]

    #check for match
    set match [::candle::helpers::findMatch [concat $tires $input] $gloc]
    if {$match eq ""} { set match [::candle::helpers::findMatch $ires [concat $tgloc $goal]] }
  }

  #compile actions
  set actions ""
  if {$match ne ""} {
    set tempinput $match
    while {$tempinput != $input} {
      set tiindex [lsearch $ires $tempinput]
      set actions "[lindex $iact $tiindex] $actions"
      set tempinput [lindex $iloc $tiindex]
    }
    set tempgoal $match
    while {$tempgoal != $goal} {
      set tgindex [lsearch $gloc $tempgoal]
      lappend actions [lindex $gact $tgindex]
      set tempgoal [lindex $gres $tgindex]
    }
  } else {
    #If no match, return 3 thingss:
    #first an idicator saying this is a suggestion
    #second the action that matches the input the closest to our input.
    #thridly, the list of inputs that the goal touches directly.
    return [concat _ [lindex $ires [lsearch $ires [::candle::getBestMatch $goal $ires]]] $ires]
  }
  if {[llength $::actionslist] > 1} {
    ::candle::record::newChain $input $goal $actions
  }
  return $actions
}































## getActionsPath input as word, goal as word
#
# Takes an input representation and a goal representation. Searches the main
# table in the database to find a path from the goal, back to the input, while
# at the same time it looks for the goal starting at the input. As soon as it
# finds a place where the two intersect it finds the path and compiles the list
# of actions that must be taken to get there. Finds the shortest possible path.
# Returns the list of actions if one is found. If one is not found it finds the
# input in the list that is closest to the input passed to it and returns that.
#
# example:  000 002
# returns:  +1 +1
#
proc ::candle::getActionsPath {input goal} {
set ::actionslist ""
#initialize everything
  set tiloc "" ;#temporary input location
  set tiact ""
  set tires ""

  set tgloc ""
  set tgact ""
  set tgres ""

  set iloc "" ;#large list input location
  set iact ""
  set ires ""

  set gloc ""
  set gact ""
  set gres ""

  set go $goal
  set in $input
  set temp ""
  set match ""

  while {($go ne "" || $in ne "") && $match eq ""} {
    #get all the goals

    set temp ""
    if {$go ne ""} { set temp [::repo::get::chainMatch main result $go] }
    set c 0
    set tgloc ""
    set tgact ""
    set tgres ""
    set go ""
    foreach item $temp {
      if {$c == 0} {
        if {[lsearch [concat $gloc $tgloc] $item] == -1} {
          lappend tgloc $item
          lappend go $item
        } else {
          set c -3
        }
      } elseif {$c == 1} {
        lappend tgact $item
      } elseif {$c == 2} {
        lappend tgres $item
        set c -1
      }
      incr c
    }

    #fill the temporary inputs out.
    set temp ""
    if {$in ne ""} { set temp [::repo::get::chainMatch main input $in] }
    set c 0
    set tiloc ""
    set tiact ""
    set tires ""
    set in ""
    foreach item $temp {
      if {$c == 0} {
          lappend tiloc $item
      } elseif {$c == 1} {
        lappend tiact $item
      } elseif {$c == 2} {
        if {[lsearch [concat $ires $tires] $item] == -1} {
          lappend tires $item
          lappend in $item
        } else {
          set tiloc [lrange $tiloc 0 [expr [llength $tiloc]-2]]
          set tiact [lrange $tiact 0 [expr [llength $tiact]-2]]
        }
        set c -1
      }
      incr c
    }

    #fill the long lists with what we found
    set iloc [concat $iloc $tiloc]
    set iact [concat $iact $tiact]
    set ires [concat $ires $tires]

    set gloc [concat $gloc $tgloc]
    set gact [concat $gact $tgact]
    set gres [concat $gres $tgres]

    #check for match
    set match [::candle::helpers::findMatch [concat $tires $input] $gloc]
    if {$match eq ""} { set match [::candle::helpers::findMatch $ires [concat $tgloc $goal]] }
  }

  #compile actions
  set actions ""
  if {$match ne ""} {
    set tempinput $match
    while {$tempinput != $input} {
      set tiindex [lsearch $ires $tempinput]
      set actions "[lindex $iact $tiindex] $actions"
      set tempinput [lindex $iloc $tiindex]
    }
    set tempgoal $match
    while {$tempgoal != $goal} {
      set tgindex [lsearch $gloc $tempgoal]
      lappend actions [lindex $gact $tgindex]
      set tempgoal [lindex $gres $tgindex]
    }
  } else {
    #If no match, return 3 thingss:
    #first an idicator saying this is a suggestion
    #second the action that matches the input the closest to our input.
    #thridly, the list of inputs that the goal touches directly.
    return [concat _ [lindex $ires [lsearch $ires [::candle::getBestMatch $goal $ires]]] $ires]
  }
  if {[llength $::actionslist] > 1} {
    ::candle::record::newChain $input $goal $actions
  }
  return $actions
}

## ::newChain input as word, result as word, actions as list
#
# Saves a new chain if the chain isn't in the database already.
# To do:
# If a matching chain is in the database but its action list is longer
# It'll delete the old one and save this new, shorter one.
#
proc ::candle::record::newChain {input result actions} {
  set returned [::repo::get::allMatch chains $input $actions $result]
  if {$returned eq ""} {
    ::repo::insert chains "time [clock milliseconds] input $input result $result action { $actionslist }"
  }
}

## findMatch input as list, goal as list
#
# Searches the two lists to see if any elements in the two lists match an
# element from the other lists. Returns the first one it finds else empty.
#
# example:  {000 002} {006 005 004 003 002 001 000}
# returns:  000
#
proc ::candle::helpers::findMatch {a b} {
 foreach i $a {
   if {[lsearch -exact $b $i] != -1} {
     return $i
   }
 }
 return
}
#puts [::candle::main 474 474]

## helpers::SavedChain input as word, goal as word
#
# checks to see if we've found a chain to this goal before
# Adds all actions to ::actionslist
#
proc ::candle::helpers::savedChain {input goal} {
  set actions [::repo::get::chainActions $input $goal]
  return $actions
}



################################################################################################################################################################
# GUESS ########################################################################################################################################################
################################################################################################################################################################


## guess input as word, acts as list.
#
# look at main db and compile a list of all the actions that have been used on
# this input before. Compare the acts list with the actionsdonehere list.
# returns the first aciton that isn't on the actionshere list. If that fails it
# returns a random act on the acts list as a last resort.
#
proc ::recall::guess {input acts} {
  set actionsdonehere [::repo::get::actsDoneHere $input]
  set alist ""
  foreach item $acts {
    if {[lsearch -exact $actionsdonehere $item] == -1 && $item != 0} {
      set alist "$alist $item"
    }
  }
  if {$alist ne ""} {
    return [lindex $alist [expr { int([llength $alist] * rand()) }]]
  }
  return [lindex $acts [expr 1 + round( rand() * ([llength $acts]-2)) ]]
}
