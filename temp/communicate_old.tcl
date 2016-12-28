namespace eval ::communicate {}
namespace eval ::communicate::set {}
namespace eval ::communicate::helpers {}
namespace eval ::communicate::interact {}
namespace eval ::communicate::debug {}

proc ::communicate::set::globals {} {
  set ::communicate::chan [socket 127.0.0.1 9900]
  set ::communicate::name {}
  set ::communicate::from {}
  set ::communicate::to {}
  set ::communicate::debug::wait 0
}

proc ::communicate::set::up {} {
  ::communicate::set::globals
  set msg {}
  set sendmsg {}
  set introduction "from"
  lappend introduction [::communicate::helpers::getMyName]
  lappend introduction "to"
  lappend introduction "server"
  lappend introduction "message"
  lappend introduction [list "up:" [::communicate::helpers::whoDoIHearFrom?] "down:" [::communicate::helpers::whoDoITalkTo?]]
  puts $::communicate::chan $introduction
  flush $::communicate::chan
  puts "Server responded: [gets $::communicate::chan]"
  puts "Awaiting Instructions from Server..."
}


############################################################################
# Helpers ##################################################################
############################################################################


proc ::communicate::helpers::getMyName {} {
  puts "Who am I?"
  flush stdout
  set ::communicate::name [gets stdin]
  return $::communicate::name
}

proc ::communicate::helpers::whoDoIHearFrom? {} {
  puts "Who talks to me?"
  flush stdout
  set ::communicate::from [gets stdin]
  return $::communicate::from
}

proc ::communicate::helpers::whoDoITalkTo? {} {
  puts "Who do I talk to?"
  flush stdout
  set ::communicate::to [gets stdin]
  return $::communicate::to
}



############################################################################
# Debug ####################################################################
############################################################################


proc ::communicate::debug {msg} {
  if {[lindex $msg 0] == "wait" } {
    set ::communicate::debug::wait [lindex $msg 1]
  }
}


################################################################################
# Interaction ##################################################################
################################################################################

proc ::communicate::interact::always {} {
  while {1} {
    after $::communicate::debug::wait
    set msg [::communicate::interact::get [gets $::communicate::chan]]
    #puts "received: $msg"
    puts "cmd-in: [::see::command $msg]     msg-in: [::see::message $msg]"
    set sendmsg [::maestro::handle::interpret $msg]
    if {$sendmsg ne ""} { ::communicate::interact::send $sendmsg } \
    else {puts "no message to send."}
  }
}

proc ::communicate::interact::get {message} {
  set x yes
  set msg $message
  while {$x} {
    fconfigure $::communicate::chan -blocking 0
    gets $::communicate::chan message
    if {$message eq ""} {
      set x no
    } else {
      lappend msg $message
    }
  }
  fconfigure $::communicate::chan -blocking 1
  return $msg
}


proc ::communicate::interact::send {message} {
  if {$message ne ""} {
    puts "cmdout: [::see::command [lindex $message 0]]     msgout: [::see::message [lindex $message 0]]"
    puts $::communicate::chan $message
    flush $::communicate::chan
  }
}
