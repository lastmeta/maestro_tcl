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
# this is commented out because it don't work well and takes a lot of time during exploration.
source lib/encode.tcl       ;# encode raw data into a relative strucutre
#source lib/intuit.tcl       ;# get action chains from relative structure
#source lib/tracer.tcl      ;# debug.
#source lib/chain.tcl       ;# code helper used in intuit.tcl Unused.

namespace eval ::client {}
namespace eval ::client::set {}
namespace eval ::client::handle {}
namespace eval ::client::client {}
namespace eval ::client::respond {}
namespace eval ::client::client::helpers {}


############################################################################
# Setup ####################################################################
############################################################################


proc ::client::set::up {} {
  ::repo::create $::communicate::name
  ::memorize::set::globals
  ::decide::set::globals
  ::recall::set::globals
  # this is commented out because it don't work well and takes a lot of time during exploration.
  ::encode::set::globals
}


################################################################################
# Handle #######################################################################
################################################################################


proc ::client::handle::interpret msg {
  set from [::see::from $msg]
  if {$from eq "env" || [string range $from 0 1] eq "s."} {
    return [::client::handle::environment $msg]
  } elseif {$from eq "user"} {
    return [::client::handle::user $msg]
  }
}

proc ::client::handle::environment msg {
  ::memorize::this $msg
  # this is commented out because it don't work well and takes a lot of time during exploration.
  ::encode::this [::see::message $msg]
  set action [::decide::action $msg]
  return [::client::format $action]
}

proc ::client::handle::user msg {
  set command [::see::command $msg]
  if       {$command eq "explore"} { return [::client::format [::decide::commanded::explore $msg]]
  } elseif {$command eq "sleep"  } { return [::client::format [::decide::commanded::sleep   $msg]           "" user]
  } elseif {$command eq "clear"  } { return [::client::format [::repo::delete::clear [::see::message $msg]] "" user]
  } elseif {$command eq "debug"  } { ::communicate::debug      [::see::message $msg]; return [::client::format $::communicate::debug::wait "communicate::debug::wait" user]
  } elseif {$command eq "stop"   } { ::decide::commanded::stop
  } elseif {$command eq "die"    } { puts "farewell" ; ::client::die }
}


################################################################################
# format #######################################################################
################################################################################


proc ::client::format {{msg ""} {cmd ""} {to ""}} {
  if {$msg ne "" && $cmd ne "" && $to ne ""} {return [list [list from $::communicate::name to $to                command $cmd message $msg when [clock milliseconds]]]
  } elseif {$msg ne "" && $cmd ne ""} {       return [list [list from $::communicate::name to $::communicate::to command $cmd message $msg when [clock milliseconds]]]
  } elseif {$msg ne "" && $to ne ""} {        return [list [list from $::communicate::name to $to                             message $msg when [clock milliseconds]]]
  } elseif {$cmd ne "" && $to ne ""} {        return [list [list from $::communicate::name to $to                command $cmd              when [clock milliseconds]]]
  } elseif {$msg ne ""} {                     return [list [list from $::communicate::name to $::communicate::to              message $msg when [clock milliseconds]]]
  } elseif {$cmd ne ""} {                     return [list [list from $::communicate::name to $::communicate::to command $cmd              when [clock milliseconds]]]
  } else {                                    return ""
  }
}


################################################################################
# die ##########################################################################
################################################################################


proc ::client::die {} {
  exit
}

proc ::client::wake {} {
  ::communicate::interact::send [::client::format 0]
}

################################################################################
# Run ##########################################################################
################################################################################


::communicate::set::up
::client::set::up
::client::wake
::communicate::interact::always
