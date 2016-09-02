namespace eval ::communicate {}

proc ::communicate::globals {} {
  set ::communicate::chan [socket 127.0.0.1 9900]
  set ::communicate::myname {}
  set ::communicate::hearfrom {}
  set ::communicate::talkto {}
}

############################################################################
# Client ###################################################################
############################################################################


proc ::communicate::interact {} {
  set msg {}
  set sendmsg {}
  set introduction "from"
  lappend introduction [::maestro::client::helpers::getMyName]
  lappend introduction "to"
  lappend introduction "server"
  lappend introduction "message"
  lappend introduction [list "up:" [::maestro::client::helpers::whoTalksToMe?] "down:" [::maestro::client::helpers::whoDoITalkTo?]]
  puts $::communicate::chan $introduction
  flush $::communicate::chan
  ::maestro::set::up
  puts "Server responded: [gets $::communicate::chan]"
  puts "Awaiting Instructions from Server..."
  while {1} {
    set msg [::communicate::getsMsg [gets $::communicate::chan]]
    puts "received: $msg"
    set sendmsg [::maestro::handle::interpret $msg]
    ::communicate::sendMsg $sendmsg
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


############################################################################
# Helpers ##################################################################
############################################################################


proc ::communicate::helpers::getMyName {} {
  puts "What is my position? (eg. 1.1) "
  flush stdout
  set ::communicate::myname [gets stdin]
  return $::communicate::myname
}

proc ::communicate::helpers::whoTalksToMe? {} {
  puts "Who  do I take orders from? (eg. 2.1) (eg. user)"
  flush stdout
  set ::communicate::hearfrom [gets stdin]
  return $::communicate::hearfrom
}

proc ::communicate::helpers::whoDoITalkTo? {} {
  puts "Who do I give orders to? (eg. 1.1 1.2) (eg. act) (eg. a.1) "
  flush stdout
  set ::communicate::talkto [gets stdin]
  return $::communicate::talkto
}
