namespace eval ::memorize {}
namespace eval ::memorize::set {}
namespace eval ::memorize::from {}
namespace eval ::memorize::help {}
namespace eval ::memorize::respond {}
namespace eval ::memorize::record {}
namespace eval ::memorize::actions {}
namespace eval ::memorize::commanded {}


################################################################################################################################################################
# SETUP ########################################################################################################################################################
################################################################################################################################################################


## setGlobals
#
# Sets global variables
#
proc ::memorize::set::globals {} {
  set ::memorize::learn   yes                 ;# if you want to stop learning for whatever reason set to no.
  set ::memorize::loc     ""                  ;# current location or latest input
  set ::memorize::act     ""                  ;# last action
  set ::memorize::input   ""                  ;# new input

  #these do not belong here, they're all about actions.
  set ::memorize::actionslist ""              ;# list we're currently compiling to send as motor commands
  set ::memorize::acts [string trim [::repo::get::actions] \{\}] ;# all avilable actions.
  set ::memorize::goal    ""                  ;# the goal.
  set ::memorize::cangoal ""                  ;# potential goal
  set ::memorize::canacts ""                  ;# potential actionslist
  puts "::acts $::acts"
  if {[llength $::acts] < 2 } {
    for {set i 0} {$i < 100} {incr i} {
      lappend actions $i
    }
    set ::memorize::acts $actions ;#+1 +10 -1 -10" ;#"0 north front east back west south"
  }
  puts "::memorize::acts $::memorize::acts"
}

proc ::memorize::test {var} {
  puts $var
  puts "actionslist:$::memorize::actionslist loc:$::memorize::loc act:$::memorize::act input:$::memorize::input "

}


################################################################################################################################################################
# Make Memory ##################################################################################################################################################
################################################################################################################################################################


proc ::memorize::raw {msg} {
  ::memorize::makeMemory [::see::when $msg] [::see::message $msg] [::see::command $msg]
  set ::input [::see::message $msg]
}

proc ::memorize::makeMemory {when input isnoise} {
  if {$::memorize::learn
  &&  $::memorize::loc ne ""
  &&  $input           ne ""
  } then {
    if {$isnoise         eq "noise"
    &&  $::memorize::act ne ""
    } then {
      ::memorize::record::lastStep $when $::memorize::loc $::memorize::act $input
    } else {
      ::memorize::record::lastStep $when $::memorize::loc "_" $input
    }
  }
  set ::memorize::act {}
  set ::memorize::loc $input
}


################################################################################################################################################################
# RECORD #######################################################################################################################################################
################################################################################################################################################################

proc ::wick::record::lastStep {when input action result} {
  set $action [string trim $action]
  if {$action ne ""} {
    if {$result eq $input} {
      ::wick::record::newBad $when $input $action $result
    } else {
      ::wick::record::newMain $when $input $action $result
    }
  }
}

# Saves a new main action if there isn't one in the database already.
proc ::wick::record::newMain {when input action result} {
  set returned [::repo::get::allMatch main $input [string trim $action] $result]
  if {$returned eq ""} {
    ::repo::insert main "time $when input $input result $result action $action"
  }
}

# Saves a new bad move if there isn't one in the database already.
proc ::wick::record::newBad {when input action result} {
  set returned [::repo::get::allMatch bad $input [string trim $action] $result]
  if {$returned eq ""} {
    ::repo::insert bad "time $when input $input result $result action $action"
  }
}



################################################################################################################################################################
# Up #########################################################################################################################################################
################################################################################################################################################################

# MOVE TO ACTIONS MODULE
#if {$isnoise} {
#  set ::actionslist ""
#}
#if {$::input ne "" && $::goal ne "" && $::goal ne "__"} {
#  return [::wick::respond::environment $msg]
#}



proc ::wick::commanded::can msg {
  set goal [::see::message $msg]
  set path [::candle::main $::input $goal]
  set newgoal [lindex $goal 0]
  set path [string trim [lrange $path 1 end] \{\}]
  set ::canacts $path
  set ::cangoal $newgoal
  if {$path             eq  ""  ||
      [lindex $path 0]  eq  "_"
  } then {
    return [list [list from $::myname to [::see::from $msg] command no message $newgoal when [clock milliseconds]]]
  } else {
    return [list [list from $::myname to [::see::from $msg] command yes message $newgoal when [clock milliseconds]]]
  }
}

proc ::wick::commanded::try msg {
  set ::goal [::see::message $msg]
  if {$::goal               eq $::cangoal &&
      $::canacts            ne  ""        &&
      [lindex $::canacts 0] ne  "_"       &&
      [lindex $::canacts 0] ne  "__"
  } then {
    set ::goal        $::cangoal
    set ::actionslist $::canacts
    return [::wick::commanded::exists $msg]
  } elseif {$::goal eq "__"} {
    return [::wick::commanded::stop]
  } elseif {$::goal eq "_"} {
    return [::wick::commanded::guess $msg]
  } elseif {[llength $::goal] > 1} {
    return [::wick::commanded::find $msg]
  } elseif {$::goal eq $::input} {
    return [::wick::commanded::report $msg]
  } else {
    return [::wick::commanded::find $msg]
  }
}


proc ::wick::commanded::resetActions {} {
  puts resetActions
  for {set i 0} {$i < 100} {incr i} {
    lappend actions $i
  }
  set ::acts $actions
  ::naisen::wax::update::actions $actions
  puts "available actions: $::acts"
}

proc ::wick::commanded::exists msg {
  if {[lsearch [::see::message $msg] $::input] >= 0} {
    set path [::candle::main $::input $goal]
    set ::goal [lindex $path 0]
    set ::actionslist [string trim [lrange $path 1 end] \{\}]
  }
  set when [clock milliseconds]
  return [list\
          [list from $::myname to $::dlnames message [::wick::actions::do] when $when]\
          [list from $::myname to [::see::from $msg] command ok message $::goal when $when]\
         ]
}

proc ::wick::commanded::stop {} {
  set ::actionslist ""
  set ::goal ""
  return
}
proc ::wick::commanded::sleep msg {
  ::wick::commanded::stop
  set todo [::see::message $msg]

  # process actions limit if its not already processed or if its explicit.
  if {$todo eq "acts"} {
    set ::acts [::naisen::wax::find::actions $::acts]
    puts "actions: $::acts"
  } else {
    for {set i 0} {$i < 100} {incr i} {
      lappend actions $i
    }
    if {$::acts eq $actions} {
      set ::acts [::naisen::wax::find::actions $::acts]
      puts "actions: $::acts"
    }
  }

  #process opposites.
  if {$todo eq "opps"} {
    set ::acts [::naisen::wax::find::opposites $::acts]
    puts "opposite actions: $::acts"
  }

  #reset actions
  if {$todo eq "react"} {
    return [::wick::commanded::resetActions]
  }


  #process other stuff.

  #put data into the database in rules

  #use rules to produce predictions about everything and put all details in db.

  return done.
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
