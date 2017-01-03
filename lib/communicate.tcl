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
  lappend introduction [list "up:" [::communicate::helpers::whoDoIHearFrom?] \
                           "down:" [::communicate::helpers::whoDoITalkTo?  ] ]

  puts $::communicate::chan $introduction
  flush $::communicate::chan
  puts "Server responded: [gets $::communicate::chan]"
  #puts "Asking for current position..."
  #set introduction [list from $::communicate::name to $::communicate::to message 0]
  #puts $::communicate::chan $introduction
  #flush $::communicate::chan
  #::maestro::handle::environment [gets $::communicate::chan]
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
  fconfigure $::communicate::chan -blocking 0 -buffering line -translation crlf
  fileevent $::communicate::chan readable [list ::communicate::interact::listen]
  vwait forever
}

proc ::communicate::interact::listen {} {
  if {[gets $::communicate::chan line] >= 0} {
    puts "IN  cmd: [::see::command $line]"
    puts "IN  msg: [::see::message $line]"
    set sendmsg [::maestro::handle::interpret $line]
    if {$sendmsg ne ""} { ::communicate::interact::send $sendmsg } \
    else {puts "no message to send."}
  }
}

proc ::communicate::interact::send {message} {
  if {$message ne ""} {
    after $::communicate::debug::wait
    puts "OUT cmd: [::see::command [lindex $message 0]]"
    puts "OUT msg: [::see::message [lindex $message 0]]"
    puts $::communicate::chan $message
    flush $::communicate::chan
  }
}
