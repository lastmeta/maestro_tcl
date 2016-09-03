namespace eval ::communicate {}

proc ::communicate::globals {} {
  set ::communicate::chan [socket 127.0.0.1 9900]
  set ::communicate::name {}
  set ::communicate::from {}
  set ::communicate::to {}
}

proc ::communicate::setup {} {
  set msg {}
  set sendmsg {}
  set introduction "from"
  lappend introduction [::maestro::client::helpers::getMyName]
  lappend introduction "to"
  lappend introduction "server"
  lappend introduction "message"
  lappend introduction [list "up:" [::maestro::client::helpers::whoDoIHearFrom?] "down:" [::maestro::client::helpers::whoDoITalkTo?]]
  puts $::communicate::chan $introduction
  flush $::communicate::chan
  ::maestro::set::up
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


################################################################################
# Interaction ##################################################################
################################################################################

proc ::communicate::interact {} {
  while {1} {
    set msg [::communicate::getsMsg [gets $::communicate::chan]]
    puts "received: $msg"
    set sendmsg [::maestro::handle::interpret $msg]
    if {$sendmsg ne ""} { ::communicate::sendMsg $sendmsg }
  }
}

proc ::communicate::getsMsg {message} {
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


proc ::communicate::sendMsg {sendmsg} {
  if {$sendmsg ne ""} {
    puts $::communicate::chan $sendmsg
    flush $::communicate::chan
  }
}
