namespace eval ::memorize {}
namespace eval ::memorize::set {}
namespace eval ::memorize::record {}

################################################################################################################################################################
# SETUP ########################################################################################################################################################
################################################################################################################################################################


proc ::memorize::set::globals {} {
  set ::memorize::learn   yes                 ;# if you want to stop learning for whatever reason set to no.
  set ::memorize::loc     ""                  ;# current location or latest input
  set ::memorize::act     ""                  ;# last action
  set ::memorize::input   ""                  ;# new input
}

proc ::memorize::set::learn {msg} {
  if {$msg eq "on"} {
    set ::memorize::learn   yes
  } elseif {$msg eq "off"} {
    set ::memorize::learn   no
  } else {
    set ::memorize::learn   $msg
  }
}


################################################################################################################################################################
# Make Memory ##################################################################################################################################################
################################################################################################################################################################


proc ::memorize::this {msg} {
  ::memorize::makeMemory [::see::when $msg] [::see::message $msg] [::see::command $msg]
  set ::memorize::input [::see::message $msg]
}

proc ::memorize::makeMemory {when input isnoise} {
  if {$::memorize::learn
  &&  $::memorize::loc ne ""
  &&  $input           ne ""
  } then {
    if {$isnoise         ne "noise"
    &&  $::memorize::act ne ""
    } then {
      ::memorize::record::lastStep $when $::memorize::loc $::memorize::act $input
    } else {
      ::memorize::record::lastStep $when $::memorize::loc "_" $input
    }
  }
  # this is commented out because it don't work well and takes a lot of time during exploration.
  #set ::encode::lastaction $::memorize::act
  set ::memorize::act {}
  set ::memorize::loc $input
}


################################################################################################################################################################
# RECORD #######################################################################################################################################################
################################################################################################################################################################

proc ::memorize::record::lastStep {when input action result} {
  set $action [string trim $action]
  if {$action ne ""} {
    if {$result eq $input} {
      ::memorize::record::newBad $when $input $action $result
    } else {
      ::memorize::record::newMain $when $input $action $result
    }
  }
}

# Saves a new main action if there isn't one in the database already.
proc ::memorize::record::newMain {when input action result} {
  set returned [::repo::get::allMatch main $input [string trim $action] $result]
  if {$returned eq ""} {
    ::repo::insert main "time $when input $input result $result action $action"
  }
}

# Saves a new bad move if there isn't one in the database already.
proc ::memorize::record::newBad {when input action result} {
  set returned [::repo::get::allMatch bad $input [string trim $action] $result]
  if {$returned eq ""} {
    ::repo::insert bad "time $when input $input result $result action $action"
  }
}
