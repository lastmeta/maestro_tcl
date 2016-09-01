pkg_mkIndex -verbose [pwd] lib/repo.tcl
lappend auto_path [pwd] lib
package require repo 1.0

pkg_mkIndex -verbose [pwd]/lib prepdata.tcl
lappend auto_path [pwd]/lib
package require prepdata 1.0

source lib/see.tcl    ;# get info from msg
source lib/wick.tcl   ;# record data
source lib/candle.tcl ;# get actions
source lib/wax.tcl    ;# post analyzation of data to discover structure.

namespace eval ::maestro {}
namespace eval ::maestro::set {}
namespace eval ::maestro::main {}
namespace eval ::maestro::actions {}
namespace eval ::maestro::record {}
namespace eval ::maestro::find {}
namespace eval ::maestro::client {}
namespace eval ::maestro::client::helpers {}


############################################################################
# Setup ####################################################################
############################################################################


proc ::maestro::set::up {} {
  ::repo::create $::myname
  ::wick::set::globals  $::myname $::talkto $::hearfrom
}

proc ::maestro::set::globals {} {
  set ::chan {}
  set ::myname {}
  set ::hearfrom {}
  set ::talkto {}
}


############################################################################
# Client ###################################################################
############################################################################


proc ::maestro::client::run {} {
  set msg {}
  set sendmsg {}
  set introduction "from"
  lappend introduction [::maestro::client::helpers::getMyName]
  lappend introduction "to"
  lappend introduction "server"
  lappend introduction "message"
  lappend introduction [list "up:" [::maestro::client::helpers::whoTalksToMe?] "down:" [::maestro::client::helpers::whoDoITalkTo?]]
  puts $::chan $introduction
  flush $::chan
  ::maestro::set::up
  puts "Server responded: [gets $::chan]"
  puts "Awaiting Instructions from Server..."
  while {1} {
    set msg [::maestro::client::getsMsg [gets $::chan]]
    puts "received: $msg"
    set sendmsg [::maestro::interpret $msg]
    ::maestro::client::sendMsg $sendmsg
  }
}

proc ::maestro::client::getsMsg {message} {
  set x yes
  set msg $message
  while {$x} {
    fconfigure $::chan -blocking 0
    gets $::chan message
    if {$message eq ""} {
      set x no
    } else {
      lappend msg $message
    }
  }
  fconfigure $::chan -blocking 1
  return $msg
}


proc ::maestro::client::sendMsg {sendmsg} {
  if {$sendmsg ne ""} {
    puts $::chan $sendmsg
    flush $::chan
  }
}



############################################################################
# Interpret ################################################################
############################################################################


## ::interpret msg as message
#
# Entery and exit point. Work on this, make it aseries of chains if you have to.
# format once all data is gathered rather than formatting in various procs.
#
proc ::maestro::interpret msg {
  # make the following into their own procs and call them here:
  # record raw data
  return [::wick::evaluate $msg]
  # choose behavior
    # get path or choose randomly, etc.
  # incorporate into causal structure
  # return behavior.
}


############################################################################
# Helpers ##################################################################
############################################################################


proc ::maestro::client::helpers::getMyName {} {
  puts "What is my position? (eg. 1.1) "
  flush stdout
  set ::myname [gets stdin]
  return $::myname
}
proc ::maestro::client::helpers::whoTalksToMe? {} {
  puts "Who do I take orders from? (eg. 2.1) (eg. user)"
  flush stdout
    set ::hearfrom [gets stdin]
  return $::hearfrom
}
proc ::maestro::client::helpers::whoDoITalkTo? {} {
  puts "Who do I give orders to? (eg. 1.1 1.2) (eg. act) (eg. a.1) "
  flush stdout
  set ::talkto [gets stdin]
  return $::talkto
}

############################################################################
# Run ######################################################################
############################################################################


::maestro::set::globals
set ::chan [socket 127.0.0.1 9900]
::maestro::client::run
