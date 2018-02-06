namespace eval ::recall {}
namespace eval ::recall::set {}
namespace eval ::recall::record {}
namespace eval ::recall::helpers {}
namespace eval ::recall::roots {}
namespace eval ::recall::roots::path {}

proc ::recall::set::globals {} {
  set ::recall::goal                {}
  set ::recall::tried               {}
  set ::recall::stateacts           {}
  set ::recall::roots::actionspath  {}
  set ::recall::roots::done         no
}

proc ::recall::set::goal {goal} {
  if {$goal ne $::recall::goal} {
    set ::recall::goal $goal
    set ::recall::tried {}
  }
}

proc ::recall::set::tried {goal} {
  if {[lsearch $::recall::tried $goal] eq "-1"} {
    lappend ::recall::tried $goal
  }
}




proc ::recall::main {input goal} {

  ::recall::set::goal $goal

  set actions [::recall::simple $input $goal]
  if {$actions ne "" && [lindex $actions 0] ne "_"} { return $actions }

  # if we still have not returned a list of viable actions, try intuit
  # this is commented out because it don't work well and takes a lot of time during exploration.
  #set actions       {}
  #set mainstates    [::repo::get::tableColumns main input]
  #set badstates     [::repo::get::tableColumns bad input ]
  #set newgoal $goal
  #while {[lsearch $mainstates $newgoal] eq "-1" && [lsearch $badstates $newgoal] eq "-1" && $newgoal ne ""} {
  #  set newgoal           [::intuit::guess $input $newgoal $::recall::tried]
  #  ::recall::set::tried $newgoal
  #}
  #if {$newgoal ne ""} {
  #  set actions [::recall::getActionsPathWithPrediction $input $newgoal]
  #}

  if {$actions ne "" && [lindex $actions 0] ne "_"} { return $actions }

  # if no chain, look for the best next goal according best match
  if {[lindex $actions 0] ne "_"} {
    set newgoals [lrange $actions 1 end]
    foreach newgoal $newgoals {
      if {[lsearch $::recall::tried $newgoal] eq  "-1"} {
        set actions [::recall::simple $input $newgoal]
        ::recall::set::tried $newgoal
      }
      if {$actions ne "" && [lindex $actions 0] ne "_"} { return $actions }
    }
  }

  # if we still have not returned a list of viable actions, try using rules:
  if {[string trim $actions] eq ""} {
    set actions [::recall::guess $input $::decide::acts]
  }

  # if we still have not returned a list of viable actions, try guessing:
  if {[string trim $actions] eq ""} {
    set actions [::recall::guess $input $::decide::acts]
  }

  return $actions
}

proc ::recall::simple {input goal} {
  # look in chain
  set chain [::recall::helpers::savedChain $input $goal]
  if { $chain ne ""} { return $chain }

  # if not in chain look for a chain
  set actions [::recall::getActionsPathWithPrediction $input $goal]
  return $actions
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
proc ::recall::getBestGoal {goal} {
  set c 0
  set combos [::prepdata::combinations $goal]
  set newresults ""
  foreach combo $combos {
    lappend newresults [::repo::get::byResultsLike main [lindex $combos $c]]
    lappend newresults [::repo::get::byResultsLike predictions [lindex $combos $c]]
    incr c
  }
  return [::recall::getBestMatch $goal $newresults]
}

## getBestMatch goal as word, newresults as list
#
# looks for the goal the list you give it. returns the closest match.
#
# example:  000 {134 032 104}
# returns:  032
#
proc ::recall::getBestMatch {goal newresults} {

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


## getActionsPathOfRules input as word, goal as word
#
# Takes an input and a goal. Searches the rules table for matches in order to
# find a path from the goal, back to the input, while at the same time it looks
# for the goal starting at the input. As soon as it finds a place where the two
# intersect (that is it finds a matching representation) it compiles the list of
# actions that must be taken to get there. Finds the shortest possible path.
# Returns the list of actions if one is found. If one is not found it finds the
# input in the list that is closest to the input passed to it and returns that.
#
# example:  000 002
# returns:  +1 +1
#
proc ::recall::getActionsPathWithPredictionOfRules {input goal} {
  set actionslist ""
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
  set combos_input  [::prepdata::helpers::reorderByUnderscore [::prepdata::combinations $input]]
  set combos_goal   [::prepdata::helpers::reorderByUnderscore [::prepdata::combinations $goal ]]
  while {($go ne "" || $in ne "") && $match eq ""} {
    #get all the goals
    set temp ""
    if {$go ne ""} {
      foreach thing_in_go $go {
        set combos_go [::prepdata::helpers::reorderByUnderscore [::prepdata::combinations $thing_in_go]]
        set temp [concat $temp [::repo::get::chainMatch generals result $combos_go]]
        set temp [::prepdata::lsubstitute $temp $thing_in_go]
      }
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
      foreach thing_in_in $in {
        set combos_in [::prepdata::helpers::reorderByUnderscore [::prepdata::combinations $thing_in_in]]
        set temp [concat $temp [::repo::get::chainMatch generals input $combos_in]]
        set temp [::prepdata::lsubstitute $temp $thing_in_in]
      }
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
    set match [::recall::helpers::findMatch [concat $tires $input] $gloc]
    if {$match eq ""} { set match [::recall::helpers::findMatch $ires [concat $tgloc $goal]] }
    #puts "match: $match"
  }

  #compile actions
  set actions ""
  if {$match ne ""} {
    set tempinput $match
    while {$tempinput != $input} { ;# && [lsearch $combos_input $tempinput] == -1
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
    return [concat _ [lindex $ires [lsearch $ires [::recall::getBestMatch $goal $ires]]] $ires]
  }
  if {[llength $actions] > 1 && $input ne $goal} {
    ::recall::record::newChain $input $goal $actions
  }
  return $actions
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
proc ::recall::getActionsPathWithPrediction {input goal {retinput ""} {retgoal ""}} {
  set actionslist ""
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
    set match [::recall::helpers::findMatch [concat $tires $input] $gloc]
    if {$match eq ""} { set match [::recall::helpers::findMatch $ires [concat $tgloc $goal]] }
  }
  #compile actions
  set actions ""
  if {$match ne ""} {
    set tempinput $match
    while {[lsearch $input $tempinput] eq "-1"} {
      set tiindex [lsearch $ires $tempinput]
      set actions "[lindex $iact $tiindex] $actions"
      set tempinput [lindex $iloc $tiindex]
    }
    upvar $retinput reti
    set reti $tempinput
    set tempgoal $match
    while {[lsearch $goal $tempgoal] eq "-1"} {
      set tgindex [lsearch $gloc $tempgoal]
      lappend actions [lindex $gact $tgindex]
      set tempgoal [lindex $gres $tgindex]
    }
    upvar $retgoal retg
    set retg $tempgoal
  } else {
    #If no match, return 3 thingss:
    #first an idicator saying this is a suggestion
    #second the action that matches the input the closest to our input.
    #thridly, the list of inputs that the goal touches directly.
    return [concat _ [lindex $ires [lsearch $ires [::recall::getBestMatch $goal $ires]]] $ires]
  }
  if {[llength $actions] > 1 && $input ne $goal} {
    ::recall::record::newChain $input $goal $actions
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
proc ::recall::record::newChain {input result actions} {
  set returned [::repo::get::allMatch chains $input $actions $result]
  if {$returned eq ""} {
    ::repo::insert chains "time [clock milliseconds] input $input result $result action [list $actions]"
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
proc ::recall::helpers::findMatch {a b} {
 foreach i $a {
   if {[lsearch -exact $b $i] != -1} {
     return $i
   }
 }
 return
}


## helpers::SavedChain input as word, goal as word
#
# checks to see if we've found a chain to this goal before
# Adds all actions to actionslist
#
proc ::recall::helpers::savedChain {input goal} {
  set actions [::repo::get::chainActions $input $goal]
  return $actions
}


################################################################################################################################################################
# GetLocation ########################################################################################################################################################
################################################################################################################################################################


proc ::recall::location {} {
  set ::memorize::act 0
  return $::memorize::act
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
    set ::memorize::act [lindex $alist [expr { int([llength $alist] * rand()) }]]
    return $::memorize::act
  }
  set ::memorize::act [lindex $acts [expr 1 + round( rand() * ([llength $acts]-2)) ]]
  return $::memorize::act
}



## curious input as word, acts as list.
#
# look at main db and compile a list of all the actions that have been used on
# this input before. Compare the acts list with the actionsdonehere list.
# returns the first aciton that isn't on the actionshere list. If that fails it
# returns a random act on the acts list as a last resort.
#
proc ::recall::curious {input acts} {
  set main      [::repo::get::tableColumns main result]
  set bad       [::repo::get::tableColumns bad  result]
  set all       [concat $main $bad]
  set uncommon  [::prepdata::leastcommon $all]
  set random1   [::prepdata::randompick $uncommon]
  set random2   [::prepdata::randompick $uncommon]
  set acts1     [::recall::getActionsPathWithPrediction $input $random1]
  set acts2     [::recall::getActionsPathWithPrediction $input $random2]
  set lacts1    [llength $acts1]
  set lacts2    [llength $acts2]
  if {$lacts1 < $lacts2 && [lindex $acts1 0] ne "_"} {
    set ::decide::goal $random1
    return $acts1
  } elseif {[lindex $acts2 0] ne "_"} {
    set ::decide::goal $random2
    return $acts2
  } else {
    return "_"
  }
}

# one thing to add to guess or before guess maybe is a curious search:
# 1. compile a list of states/locations where it has the least amount of actions tried.
# 2. pick two from the list at random.
# 3. compute the distance to both.
# 4. the one with the shorter distance wins, set that actionlist as my path and go there.




################################################################################################################################################################
# ROOTS ########################################################################################################################################################
################################################################################################################################################################

proc ::recall::roots::try {goalstate} {
  if {$::memorize::input eq ""} {
    # assume you're at the origin if you don't know where you are. - not great but a work around
    set ::memorize::input [::repo::get::tableColumnsWhere main input [list rowid 1]]
  }
  if {[::repo::get::maxLevel] eq "{}"} {
    puts "I must sleep"
    # candle algo
    puts "slow path-finding"
    return [::recall::getActionsPathWithPrediction $::memorize::input $goalstate]
  } elseif {[::repo::get::tableColumnsWhere main result [list input  $goalstate]] eq ""
  &&        [::repo::get::tableColumnsWhere main result [list result $goalstate]] eq ""
  } then {
    # generalize
    puts "generalizing and path-finding"
    return [::recall::roots $goalstate]
  } else {
    # region pathfinding
    puts "fast path-finding"
    return [::recall::roots::path::find $::memorize::input $goalstate]
  }
}
## roots input as word, acts as list.
#
# generalize path finding using what we've learned during sleep (that is the
# hierarchical informational structure of data we've produced while sleeping)
# order from chaos.
#
proc ::recall::roots {goalstate} {
  puts "in roots"
  #convert goalstate to a binary sdr
  lassign [::encode::sleep::sdr $goalstate] goalnodes goalsdr
  puts "goalnodes $goalnodes goalsdr $goalsdr"
  if {$goalsdr eq ""} {
    puts "I must sleep"
  }
  #get a list of all the signatures from every region in every level
  set allsigs     [::repo::get::tableColumns roots sig]
  set allsize     [::repo::get::tableColumns roots size]
  #compare to every signature and get a list of distances corresponding to the regions by closest match (smallest divergence)
  set distances  [::recall::roots::getDistances $goalsdr $allsigs]
  #go to and explore that region in more detail
#  puts "goalsdr $goalsdr"
#  puts "goalstate allsigs distances  $goalstate . $allsigs . $distances"
  ::recall::roots::explore $goalstate $allsigs $distances
}

proc ::recall::roots::getDistances {goalsdr sigs} {
  puts "in distances"
  set distance  0
  set distances ""
  foreach list $sigs {
    set distance  0
    for {set i 0} {$i < [llength $goalsdr]} {incr i} {
      set distance [expr $distance + abs([expr [lindex $goalsdr $i] - [lindex $list $i]])]
    }
    lappend distances $distance
  }
  return $distances
}

proc ::recall::roots::explore {goalstate sigs distances {lasttry -1}} {
  puts "in explore"

  set smallest 1000000
  set i 0
  foreach distance $distances {
    if {$distance < $smallest && $distance > $lasttry} {
      set smallest $distance
      set index    $i
    }
    incr i
  }
  set lasttry $smallest
  #use index to get the approapriate region.
  set thing  [::repo::get::tableColumnsWhere roots [list level region state] [list sig [lindex $sigs $index]]]
  set level  [lindex $thing 0]
  set region [lindex $thing 1]
  set root   [lindex $thing 2]
  puts "level region root $level $region $root"
  #get all the states of that region
  set states [::recall::roots::getStates $level $region $root]
  set states [lsort -unique $states]
  #see if we've explored everything in every child of that root. if so

  puts "states $states"
  set stateacts [::recall::roots::actions $states]



  if {$stateacts eq ""} {
    ::recall::roots::explore $goalstate $sigs $distances $smallest
  } else {
    #travel to each of states in the keys of stateacts
    #and do each action in the values of stateacts for that key.

    #needed?
    set ::recall::stateacts $stateacts
    puts "stateacts $stateacts"
    ::recall::set::goal [::recall::roots::nextCandidate]
#    puts "::memorize::input ::recall::goal   $::memorize::input . $::recall::goal"

    # hand off responsibility to decide.
    set ::decide::explore       ""
    set ::decide::cangoal       ""
    set ::decide::canpath       ""
    set ::decide::goal          $goalstate
    set ::decide::recall::goal  $goalstate
    set ::decide::recall::sigs  $sigs
    set ::decide::recall::dist  $distances
    set ::decide::recall::ltry  $lasttry
    set ::decide::recall::sgoal [lindex $stateacts 0]
    set ::decide::recall::sacts [lindex $stateacts 1]
    set stateacts               [lrange $stateacts 2 end]
    set ::decide::recall::dict  $stateacts
    # go to that specific place
    puts "recall::goal $::recall::goal"

    set path [::recall::roots::path::find $::memorize::input $::recall::goal]
    #set path [::decide::generalization]
    puts "trying to get to $::recall::goal path $path"
    return $path
  }
}


proc ::recall::roots::actions {states} {
  set stateacts ""

  foreach state $states {
    #get all the actions done by this state in the main and bad.
    set myacts [concat [::repo::get::tableColumnsWhere main        action [list input $state]] \
                       [::repo::get::tableColumnsWhere bad         action [list input $state]] \
                       [::repo::get::tableColumnsWhere predictions action [list input $state]] ]
    foreach act $::decide::acts {
      if {[lsearch $myacts $act] eq "-1"} {
        dict lappend stateacts $state $act
      }
    }
  }
  return $stateacts
}


proc ::recall::roots::getStates {level region root} {
  #this means
  set subregion   $region
  set smallregion ""
  for {set i $level} {$i >= 0} {incr i -1} {
    set subregion [::repo::get::tableColumnsWhere roots state [list region $subregion level $i]]
    if {$i == 1} { set smallregion $subregion }
  }
  puts "level $level subregion $subregion"
  if {$subregion eq ""} {
    return ""
  }

  set candidates [string map {"\{" "" "\}" ""} [::recall::roots::findAllStates $subregion $level]]
  #now that you have a list of states make sure each of them are in the approapriate region
  puts "back"

  foreach candidate $candidates {
    for {set i 0} {$i <= $level} {incr i} {
      set resultregion [::recall::roots::path::findRegion $candidate $level]
      puts "candidate $candidate i $i resultregion $resultregion"
    }
    if {$resultregion ne $region} {
      set idx [lsearch $candidates $candidate]
      set candidates [lreplace $candidates $idx $idx]
    }
  }

  return [string map {\} "" \{ ""} $candidates]
}


proc ::recall::roots::findAllStates {state level} {

  set results $state
  set candidates $state
  set lastresults ""
  #go to main and get every result within a 2^(level+1) radius
  set n [expr 2**[expr $level+1]]
  for {set i 1} {$i < $n} {incr i} {
    set results [concat [::repo::get::chainMatchResults main        input $results] \
                        [::repo::get::chainMatchResults predictions input $results] ]
    set results [lsort -unique $results]
    set candidates [concat $candidates $results]
    if {$lastresults eq $results} { break }
    set lastresults $results
  }
  puts "candidates $candidates"

  set candidates [lsort -unique $candidates]
  return $candidates
}




################################################################################################################################################################
# ROOTS PATH ########################################################################################################################################################
################################################################################################################################################################

proc ::recall::roots::nextCandidate {} {
  #pop off the front of $::recall::stateacts and then set $::recall::actions to the actions and return the goal
  if {[llength $::recall::stateacts] > 1} {
    set stateacts           $::recall::stateacts
    set ::recall::stateacts [lrange $stateacts 2 end]
    set ::recall::actions   [lindex $stateacts 1    ]
    set ::recall::goal      [lindex $stateacts 0    ]
    return                  $::recall::goal
  } else {
    set ::recall::stateacts ""
    set ::decide::explore   "" ;# be sure to stop trying to explore roots when we've exhausted all options.
    return                  ""
  }
}

# so if you want to send in a 'state representation' like those in main you'll have to use
proc ::recall::roots::path::findRegion {state {level 0}} {
  set zerostate [::sleep::find::regions::from $state]
  for {set i 1} {$i <= $level} {incr i} {
    set zerostate [::sleep::find::regions::from $zerostate "" $i]
  }
  return $zerostate
}



proc ::recall::roots::path::find {currentstate goalstate} {
  # clear actions path first.
  set ::recall::roots::actionspath ""
  if {[lsearch [::recall::roots::path::finding $currentstate $goalstate] ""] ne "-1"} {
    set ::recall::roots::actionspath ""
    set n [::repo::get::maxLevel]
    for {set i 0} {$i <= $n} {incr i} {
      set c_region [::recall::roots::path::findRegion $currentstate $i]
      set g_region [::recall::roots::path::findRegion $goalstate    $i]
      #get all states in cregion and all states in g region
      set c_list [::recall::roots::getStates $i $c_region $currentstate]
      set g_list [::recall::roots::getStates $i $g_region $goalstate   ]
      # try with those lists
      set actions [::recall::getActionsPathWithPrediction $c_list $g_list return_c return_g]
      if {$actions eq "" || $actions eq "_" || [lindex $actions 0] eq "_"} {
        # repeat at higherlevel - continue forloop
      } else {
        if {$return_c ne $currentstate} {
          #find a path to current state
          set littleactions [::recall::getActionsPathWithPrediction $currentstate $return_c]
          set ::recall::roots::actionspath $littleactions
        }
        set ::recall::roots::actionspath [concat $::recall::roots::actionspath $actions]
        if {$return_g ne $goalstate} {
          #find path to goal state
          set littleactions [::recall::getActionsPathWithPrediction $return_g $goalstate]
          set ::recall::roots::actionspath [concat $::recall::roots::actionspath $littleactions]
        }
        break
      }
    }
  }

  if {[lindex $::recall::roots::actionspath 0] eq "_"} {
    set ::recall::roots::actionspath ""
    #[lrange $::recall::roots::actionspath 1 end]
    #maybe just set it to lindex 1 instead idk.
  }
  return $::recall::roots::actionspath
}



# since the above idea is simply just coding recurssive process manually here's
# the new idea. follow it down until we get the next action and return it and be done.
proc ::recall::roots::path::finding {currentstate goalstate} {
  # be sure to do this before we start calling this recurssively
  # set ::recall::roots::actionspath ""
  set level     0
  set c_region  ""
  set g_region  "_"
  set lowerids  ""
  set inputs    ""
  set actions   ""
  set results   ""
  #don't go down multiple paths
  if {$currentstate eq $goalstate} {
    set ::recall::roots::done yes
    return
  }
  while {$c_region ne $g_region} {
    set c_region [::recall::roots::path::findRegion $currentstate $level]
    set g_region [::recall::roots::path::findRegion $goalstate $level]
    set atom_ids [::repo::get::tableColumnsWhere regions mainid [list level $level region $c_region reg_to $g_region]]
    if {$atom_ids ne ""} { ;# there's a path from c to g on this level in regions # could be many.
      foreach lower_id $atom_ids {
        for {set i $level} {$i > 0} {incr i -1} {
          # look for this row in region and get the c and g and m for it.
          set lower_id [::repo::get::tableColumnsWhere regions mainid [list rowid $lower_id]]
        }
        #now i = 0 which means level = 0 which means we need to look at the main table
        #look in main for this rowid (m), record input action result in lists
        lappend inputs  [::repo::get::tableColumnsWhere main input  [list rowid $lower_id]]
        lappend actions [::repo::get::tableColumnsWhere main action [list rowid $lower_id]]
        lappend results [::repo::get::tableColumnsWhere main result [list rowid $lower_id]]
      }
      foreach input $inputs action $actions result $results {
        if {$::recall::roots::done} { return } ;# if we found an actions path break the recursion process
        if {$input ne $currentstate} {
          #try to find a way to get there - call this recurssively
          ::recall::roots::path::finding $currentstate $input
        }
        if {$::recall::roots::done} { return } ;# if we found an actions path break the recursion process
        lappend ::recall::roots::actionspath $action
        #return $::recall::roots::actionspath
        if {$result ne $goalstate} {

          #IS THIS BEING CALLED TOO MANY TIMES???
          #SHOULD I RETURN WITH A MESSAGE SO THE THING CALLING ME CAN CALL ME AGAIN INSTEAD OF DOING IT RECURSSIVELY?
        #  puts "calling $result $goalstate"
          #try to find a way to get there - call this recurssively
          ::recall::roots::path::finding $result $goalstate
        }
        if {$::recall::roots::done} { return } ;# if we found an actions path break the recursion process
      }
      break
    }
    incr level
    if {$level > [::repo::get::maxLevel]} { return }

  }
  if {$::recall::roots::done} { return } ;# if we found an actions path break the recursion process
  if {$c_region eq $g_region} {
    #look in main to find exact match and save action
    lappend ::recall::roots::actionspath [::repo::get::tableColumnsWhere main action [list input $currentstate result $goalstate]]
  }
  return $::recall::roots::actionspath
}
