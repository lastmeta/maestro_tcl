pkg_mkIndex -verbose [pwd] lib/repo.tcl
lappend auto_path [pwd] lib
package require repo 1.0

source lib/see.tcl          ;# get info from msg
source lib/prepdata.tcl     ;# mostly for recall
source lib/communicate.tcl  ;# hear from and talk to server.
source lib/memorize.tcl     ;# record raw data
source lib/decide.tcl       ;# when you get new data, decide what to do with it.
source lib/recall.tcl       ;# get actions and action chains from raw data
source lib/sleep.tcl        ;# post analyzation of data to discover structure.
source lib/encode.tcl       ;# encode raw data into a relative strucutre
source lib/intuit.tcl       ;# get action chains from relative structure
#source lib/tracer.tcl      ;# debug.
#source lib/chain.tcl       ;# code helper used in intuit.tcl Unused.

namespace eval ::maestro {}
namespace eval ::maestro::set {}
namespace eval ::maestro::handle {}
namespace eval ::maestro::client {}
namespace eval ::maestro::respond {}
namespace eval ::maestro::client::helpers {}


############################################################################
# Setup ####################################################################
############################################################################


proc ::maestro::set::up {} {
  ::repo::create $::communicate::name
  ::memorize::set::globals
  ::decide::set::globals
  ::recall::set::globals
  ::encode::set::globals
}


################################################################################
# Handle #######################################################################
################################################################################


proc ::maestro::handle::interpret msg {
  set from [::see::from $msg]
  if {$from eq "env" || [string range $from 0 1] eq "s."} {
    return [::maestro::handle::environment $msg]
  } elseif {$from eq "user"} {
    return [::maestro::handle::user $msg]
  }
}

proc ::maestro::handle::environment msg {
  ::memorize::this $msg
  ::encode::this [::see::message $msg]
  set action [::decide::action $msg]
  return [::maestro::format $action]
}

proc ::maestro::handle::user msg {
  if {[::see::command $msg] eq "explore"} {
    return [::maestro::format [::decide::commanded::explore $msg]]
  } elseif {[::see::command $msg] eq "stop"} {
    ::decide::commanded::stop
  } elseif {[::see::command $msg] eq "try"} {
    return [::maestro::format [::decide::commanded::try $msg]]
  } elseif {[::see::command $msg] eq "can"} {
    return [::maestro::format [::decide::commanded::can $msg] "" [::see::from $msg]]
  } elseif {[::see::command $msg] eq "sleep"} {
    return [::maestro::format [::decide::commanded::sleep $msg]]
  } elseif {[::see::command $msg] eq "learn"} {
    ::memorize::set::learn [::see::message $msg] ;#encode will reference ::memorize::learn
  } elseif {[::see::command $msg] eq "acts"} {
    ::sleep::update::actions [::see::message $msg]
    ::decide::set::actions [::see::message $msg]
  } elseif {[::see::command $msg] eq "do"} {
    return [::maestro::format [::decide::commanded::do $msg]]

  } elseif {[::see::command $msg] eq "limit"} {
    ::encode::set::limit [::see::message $msg]
    puts "learning limit: $::encode::limit"
  } elseif {[::see::command $msg] eq "cells"} {
    ::encode::set::cellspernode [::see::message $msg]
    puts "cells per node: $::encode::cellspernode"
  } elseif {[::see::command $msg] eq "incre"} {
    ::encode::set::incre [::see::message $msg]
    puts "increment amount: $::encode::incre"
  } elseif {[::see::command $msg] eq "decre"} {
    ::encode::set::decre [::see::message $msg]
    puts "decrement amount: $::encode::decre"
  }
}


################################################################################
# format #######################################################################
################################################################################


proc ::maestro::format {{msg ""} {cmd ""} {to ""}} {
  if {$msg ne "" && $cmd ne "" && $to ne ""} {
    return [list [list from $::communicate::name to $to                command $cmd message $msg when [clock milliseconds]]]
  } elseif {$msg ne "" && $cmd ne ""} {
    return [list [list from $::communicate::name to $::communicate::to command $cmd message $msg when [clock milliseconds]]]
  } elseif {$msg ne "" && $to ne ""} {
    return [list [list from $::communicate::name to $to                             message $msg when [clock milliseconds]]]
  } elseif {$cmd ne "" && $to ne ""} {
    return [list [list from $::communicate::name to $to                command $cmd              when [clock milliseconds]]]
  } elseif {$msg ne ""} {
    return [list [list from $::communicate::name to $::communicate::to              message $msg when [clock milliseconds]]]
  } elseif {$cmd ne ""} {
    return [list [list from $::communicate::name to $::communicate::to command $cmd              when [clock milliseconds]]]
  } else {
    return ""
  }
}


################################################################################
# Run ##########################################################################
################################################################################


::communicate::set::up
::maestro::set::up
::communicate::interact::always
