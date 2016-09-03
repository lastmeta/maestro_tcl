proc ::decide::set::globals {} {
  #these do not belong here, they're all about actions.
  set ::decide::path    {}                  ;# list we're currently compiling to send as motor commands
  set ::decide::acts [string trim [::repo::get::actions] \{\}] ;# all avilable actions.
  set ::decide::goal    ""                  ;# the goal.
  set ::decide::cangoal ""                  ;# potential goal
  set ::decide::canacts ""                  ;# potential actionslist
  puts "::decide::acts $::decide::acts"
  if {[llength $::decide::acts] < 2 } {
    for {set i 0} {$i < 100} {incr i} {
      lappend actions $i
    }
    set ::decide::acts $actions ;#+1 +10 -1 -10" ;#"0 north front east back west south"
  }
  puts "::decide::acts $::decide::acts"
  }
}

proc ::decide::action {msg} {
  if {$::decide::goal eq "_"} { ;# commanded to do random actions.
    return [::recall::guess [::see::msg $msg] $::decide::acts]
  } else { ;# commanded to achieve an organization
    if {$::decide::path eq ""} { ;# we have no path, try to make one.
    } elseif {$::decide::path eq "_"} { ;# we tried to make a path toward this goal and failed.
      # must sudorandomly (try to activate these columns of goal) explore for now.
    } else { ;# anything else must mean we have a path towards the goal. follow it.

    }
  }
}


################################################################################################################################################################
# commanded #########################################################################################################################################################
################################################################################################################################################################

proc ::decide::commanded::try msg {
  set ::decide::goal [::see::message $msg]
  if {$::decide::goal               eq $::decide::cangoal
  &&  $::decide::canacts            ne  ""
  &&  [lindex $::decide::canacts 0] ne  "_"
  &&  [lindex $::decide::canacts 0] ne  "__"
  } then {
    set ::decide::goal $::decide::cangoal
    set ::decide::path $::decide::canacts
    return [::decide::commanded::exists $msg]
  } elseif {$::decide::goal eq "__"} {
    return [::decide::commanded::stop]
  } elseif {$::decide::goal eq "_"} {
    return [::decide::commanded::guess $msg]
  } elseif {$::decide::goal eq $::decide::input} {
    return [::wick::commanded::report $msg]
  } else {
    return [::wick::commanded::find $msg]
  }
}


proc ::decide::commanded::can msg {
  set goal [::see::message $msg]
  set path [::recall::main $::decide::input $goal]
  set newgoal [lindex $goal 0]
  set path [string trim [lrange $path 1 end] \{\}]
  set ::decide::canacts $path
  set ::decide::cangoal $newgoal
  if {$path             eq  ""  ||
      [lindex $path 0]  eq  "_"
  } then {
    return no
  } else {
    return yes
  }
}

proc ::decide::commanded::exists msg {
  if {[lsearch [::see::message $msg] $::decide::input] >= 0} {
    set path [::recall::main $::decide::input $::decide::goal]
    set ::decide::goal [lindex $path 0]
    set ::decide::path [string trim [lrange $path 1 end] \{\}]
  }
  return [::decide::actions::do]
}

proc ::decide::commanded::stop {} {
  set ::decide::path ""
  set ::decide::goal ""
}

proc ::decide::commanded::sleep msg {
  ::decide::commanded::stop
  set todo [::see::message $msg]
  # process actions limit if its not already processed or if its explicit.
  if {$todo eq "acts"} {
    set ::decide::acts [::sleep::find::actions $::decide::acts]
    puts "actions: $::decide::acts"
  } else {
    for {set i 0} {$i < 100} {incr i} {
      lappend actions $i
    }
    if {$::decide::acts eq $actions} {
      set ::decide::acts [::sleep::find::actions $::decide::acts]
      puts "actions: $::decide::acts"
    }
  }
  #process opposites.
  if {$todo eq "opps"} {
    set ::decide::acts [::sleep::find::opposites $::decide::acts]
    puts "opposite actions: $::decide::acts"
  }
  #reset actions
  if {$todo eq "react"} {
    return [::decide::commanded::resetActions]
  }
}

proc ::decide::commanded::resetActions {} {
  puts resetActions
  for {set i 0} {$i < 100} {incr i} {
    lappend actions $i
  }
  set ::decide::acts $actions
  sleep::update::actions $actions
  puts "available actions: $::decide::acts"
}

proc ::wick::commanded::report msg {
  ::wick::commanded::stop
  return [list [list from $::myname to $::upline command done message $::input when [clock milliseconds]]]
}

proc ::wick::commanded::guess msg {
  set ::actionslist [::candle::guess $::input $::acts]
  return [list [list from $::myname to [lindex $::dlnames 0] message [::wick::actions::do] when [clock milliseconds]]]
}

proc ::wick::commanded::find msg {
  if {[llength $::goal] > 1} {
    return [::wick::commanded::multiple $msg]
  } else {
    return [::wick::commanded::single $msg]
  }
}

proc ::wick::commanded::multiple msg {
  ::wick::commanded::stop
  set ::goal [::see::message $msg]
  foreach goal $::goal {
    set path [::candle::main $::input $goal]
    set newgoal [lindex $path 0]
    set ::actionslist [lrange $path 1 end]
    if {[lindex $::actionslist 0] ne "_"} {
      set ::goal $goal
      break
    }
  }
  return [::wick::commanded::goal $msg]
}

proc ::wick::commanded::single msg {
  ::wick::commanded::stop
  set ::goal [::see::message $msg]
  set path [::candle::main $::input $::goal]
  set newgoal [lindex $path 0]
  set ::actionslist [lrange $path 1 end]
  return [::wick::commanded::goal $msg]
}

proc ::wick::commanded::goal msg {
  if {[lindex $::actionslist 0] eq "_"} {
    set goal [lindex $::actionslist 1]
    set ::actionslist [lrange $::actionslist 2 end]
  } else {
    set goal $::goal
  }
  set when [clock milliseconds]
  return [list\
          [list from $::myname to $::dlnames message [::wick::actions::do] when $when]\
          [list from $::myname to [::see::from $msg] command ok message $goal when $when]\
         ]
}


################################################################################################################################################################
# environment #########################################################################################################################################################
################################################################################################################################################################



## decideactions
#
# tries to find a path or tries to do a random action. Returns actions.
#
proc ::wick::respond::environment {msg} {
  ::wick::respond::next

  if {$::goal eq "_"} {
    if {$::upline ne "user"} {
      set ::goal ""
      return [::wick::commanded::report $msg]
    } else {
      return [::wick::commanded::guess $msg]
    }

  }

  if {[::wick::help::shouldWeChain?]} {
    ::wick::respond::chain
  }

  if {[::wick::help::shouldWeGuess?]} {
    ::wick::respond::guess
  }

  if {$::actionslist eq {}} {
    return
  }

  return [list [list from $::myname to [lindex $::dlnames 0] message [::wick::actions::do] when [clock milliseconds]]]
}

proc ::wick::respond::next {} {
  if {[lindex $::goal 0] eq $::input} {
    set ::goal [lrange $::goal 1 end]
  }
}

proc ::wick::respond::chain {} {
  set path [::candle::main $::input $::goal]
  set ::actionslist [lrange $path 1 end]
}

proc ::wick::respond::guess {} {
  set ::actionslist [::candle::guess $::input $::acts]
}

################################################################################################################################################################
# helpers #########################################################################################################################################################
################################################################################################################################################################








proc ::wick::help::shouldWeChain? {} {
  #if we have reached goal do nothing
  #if input or goal is empty do nothing
  #if we have actions do nothing
  #if goal eq _ GUESS
  #if input and goal aren't equal and we have no actions, find a chain
  #if     {!$::doacts}                       { return no  }
  if {$::input  eq $::goal}             { return no  } \
  elseif {$::input  eq {} || $::goal eq {}} { return no  } \
  elseif {$::goal   eq "_"}                 { return no  } \
  elseif {$::goal   eq "__"}                { return no  } \
  elseif {[::wick::help::weHaveActions?]}   { return no  } \
  else                                      { return yes }
}

proc ::wick::help::shouldWeGuess? {} {

  #if     {!$::doacts}                       { return no  }
  if {$::input  eq $::goal}             { return no  } \
  elseif {$::input  eq {} || $::goal eq {}} { return no  } \
  elseif {$::goal   eq "_"}                 { return yes } \
  elseif {$::goal   eq "__"}                { return no  } \
  elseif {[::wick::help::weHaveActions?]}   { return no  } \
  else                                      { return yes }

}

proc ::wick::help::weHaveActions? {} {
  if {[llength $::actionslist] < 1} {
    return no
  }
  return yes
}


################################################################################################################################################################
# ACTIONS ######################################################################################################################################################
################################################################################################################################################################


proc ::wick::actions::addList {actions} {
  foreach a $actions {
    if {$a ne ""} {
      lappend ::actionslist $a
    }
  }
}
proc ::wick::actions::addAction {arg} {
  lappend ::actionslist $arg
}

## actions::do
#
# pops the first action off the acionlist and returns it.
#
proc ::wick::actions::do {} {
  set ::actionslist [string map {\{ "" \} ""} $::actionslist ]
  set ::act [lindex $::actionslist 0]
  set ::actionslist [lrange $::actionslist 1 [expr [llength $::actionslist ]-1]]
  return $::act
}

proc ::wick::actions::filterBad {newaction} {
  set returned [::repo::get::allMatch bad $::input $newaction $::input]
  if {$returned ne ""} {
    return
  } else {
    return $newaction
  }
}
