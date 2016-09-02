namespace eval ::wick {}
namespace eval ::wick::set {}
namespace eval ::wick::from {}
namespace eval ::wick::help {}
namespace eval ::wick::respond {}
namespace eval ::wick::record {}
namespace eval ::wick::actions {}
namespace eval ::wick::commanded {}


################################################################################################################################################################
# SETUP ########################################################################################################################################################
################################################################################################################################################################


## setGlobals
#
# Sets global variables
#
proc ::wick::set::globals {name downline upline} {
  set ::actionslist ""              ;# list we're currently compiling to send as motor commands
  # all available actions
  set ::acts [string trim [::repo::get::actions] \{\}]
  set ::loc     ""                  ;# current location or latest input
  set ::act     ""                  ;# last action
  set ::input   ""                  ;# new input
  set ::goal    ""                  ;# the goal.
  set ::myname  $name               ;# myname
  set ::dlnames $downline           ;# 1.1 1.2
  set ::upline  $upline             ;# 2.1
  set ::cangoal ""                  ;# potential goal
  set ::canacts ""                  ;# potential actionslist
  puts "::acts $::acts"
  if {[llength $::acts] < 2 } {
    for {set i 0} {$i < 100} {incr i} {
      lappend actions $i
    }
    set ::acts $actions ;#+1 +10 -1 -10" ;#"0 north front east back west south"
  }
  puts "::acts $::acts"
}

proc ::wick::test {var} {
  puts $var
  puts "actionslist:$::actionslist loc:$::loc act:$::act input:$::input "

}


################################################################################################################################################################
# From #########################################################################################################################################################
################################################################################################################################################################


## evaluateMessage msg as message
#
# based on who this was from decide where to send it.
#
proc ::wick::evaluate {msg} {
  set return {}
  set from [::see::from $msg]
  if {$from eq "env" || [string range $from 0 1] eq "s."} {
    return [::wick::from::environment $msg]
  } elseif {[lsearch $::upline $from] != -1} {
    return [::wick::from::up $msg]
  } elseif {$from eq "user"} {
    return [::wick::from::user $msg]
  } elseif {$from eq "server"} {
    return [::wick::from::server $msg]
  } else {
    #unknown origin?!
  }
  return $return
}


## takeInput input as word, optional isnoise as word
#
# Given an input it tries to find a path of actions from the input to the goal.
# If the input isnoise then it forgets the old path it was following and makes a
# new one.
#
proc ::wick::raw {msg} {
  if {[::see::command $msg] eq "noise"} {
    set isnoise yes
  } else {
    set isnoise no
  }
  ::wick::makeMemory [::see::when $msg] [::see::message $msg] $isnoise
  set ::input [::see::message $msg]
  # MOVE TO ACTIONS MODULE
  #if {$isnoise} {
  #  set ::actionslist ""
  #}
  #if {$::input ne "" && $::goal ne "" && $::goal ne "__"} {
  #  return [::wick::respond::environment $msg]
  #}
}



## makeMemory isresult as word
#
# record the last input, the last action and the current result if the current
# result is a direct result of the last input plus last action. Else, if noise
# is introduced to the system then reset the actionslist to adjust to new data.
#
# Record memory notes
# If isnoise eq ""
#   If it's the same input as what came before- my action had no effect. then
#     If it's already in bad don't record it.
#     else, record it in bad.
#   else new input is not same as ::input - my action did have an effect. then
#     if it's already in main don't record it.
#     else, record change in main.
#
proc ::wick::makeMemory {when input isnoise} {
  if {[::wick::help::weHaveActions?] eq no    &&
      $::loc    ne ""                         &&
      $::act    ne ""                         &&
      $::input  ne ""                         &&
      $isnoise  ne "yes"                      &&
      $::input  ne "_"                        &&
      $::goal   eq "_"
  } then {
    ::wick::record::lastStep $when $::loc $::act $input
  } elseif {[::wick::help::weHaveActions?] eq no    &&
      $::loc    ne ""                               &&
      $::act    ne ""                               &&
      $::input  ne ""                               &&
      $isnoise  ne "yes"                            &&
      $::input  ne "_"                              &&
      $::goal   eq ""
  } then {
    ::wick::record::lastStep $when $::loc $::act $input
  } elseif {$isnoise} {
    set ::actionslist ""
  }
  set ::act {}
  set ::loc $input
}









################################################################################################################################################################
# Up #########################################################################################################################################################
################################################################################################################################################################


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


################################################################################################################################################################
# RECORD #######################################################################################################################################################
################################################################################################################################################################


## record::lastStep input as word, action as word, result as word
#
# records the last action we took, its location and result in the database
# if it was fruitless we record it in bad, else main.
# To do:
# some movements are really bad - detrimental. we should be able to check for
# these as well.
#
proc ::wick::record::lastStep {when input action result} {
#::wick::test "$input, $action, $result"
set $action [string trim $action]
  if {$action ne ""} {
    if {$result eq $input} {
      ::wick::record::newBad $when $input $action $result
    } else {
      ::wick::record::newMain $when $input $action $result

    }
  }
}


## record::newMain input as word, actions as word, result as word
#
# Saves a new main action if there isn't one in the database already.
#
proc ::wick::record::newMain {when input action result} {
  set returned [::repo::get::allMatch main $input [string trim $action] $result]
  if {$returned eq ""} {
    ::repo::insert main "time $when input $input result $result action $action"
  }
}

## record::newBad input as word, actions as word, result as word
#
# Saves a new bad move if there isn't one in the database already.
#
proc ::wick::record::newBad {when input action result} {
  set returned [::repo::get::allMatch bad $input [string trim $action] $result]
  if {$returned eq ""} {
    ::repo::insert bad "time $when input $input result $result action $action"
  }
}
