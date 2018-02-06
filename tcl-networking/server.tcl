source lib/see.tcl

namespace eval ::server {}
namespace eval ::server::get {}
namespace eval ::server::help {}
namespace eval ::server::greet {}
namespace eval ::server::handle {}

proc ::server::global {} {
	set ::clients {}
}


################################################################################################################################################################
# Get #########################################################################################################################################################
################################################################################################################################################################


proc ::server::get::myAbove data {
	set message [::see::message $data]
	return [lindex $message [expr [lsearch $message "up:"] + 1]]
}
proc ::server::get::myBelow data {
	set message [::see::message $data]
	return [lrange $message [expr [lsearch $message "down:"] + 1] [llength $message]]
}


################################################################################################################################################################
# Handle #########################################################################################################################################################
################################################################################################################################################################


## ::server::handle::Client chan as channelword
#
# recieve a message in a particular channel. Evaluate it, and forward it onto
# the correct recipient.
#
# example: {{from 1.1 to s.1 message 6 when 1458228695512}}
# sends to s.1: {from 1.1 to s.1 message 6 when 1458228695512}
#
proc ::server::handle::client chan {
  set msgs [gets $chan]
	foreach msg $msgs {
		set to [::see::to $msg]
		if {$to ne {}} {
			puts [lindex [dict get $::clients $to] 0] $msg
		}
	}
}

## ::server::handle::user chan as channel
#
# forward the user command appropriately.
#
proc ::server::handle::user chan {
  set msg [gets $chan]
  set name [::see::from $msg]
	puts "The user said: $msg"
	if {[::see::to $msg] eq "server" } {
		foreach clientkey [dict keys $::clients] {
			if {[lindex [dict get $::clients $clientkey] 1] eq "user"} {
				puts [lindex [dict get $::clients $clientkey] 0] [dict replace $msg to $clientkey]
			}
		}
	} else {
		set from [::see::from $msg]
		set to [::see::to $msg]
		puts [lindex [dict get $::clients $to] 0] $msg
	}
	#puts $chan "Awaiting Command..."
	puts done
}


################################################################################################################################################################
# Accept #########################################################################################################################################################
################################################################################################################################################################


## ::server::accept chan as channel addr as word port as word
#
# meet new connections and record their details
#
proc ::server::accept {chan addr port} {
  set msg [gets $chan]
  set name [::see::from $msg]
	puts "Incoming msg: $msg"
 	if {$name eq "user"} {
		::server::greet::client $chan $name user
	} else {
		::server::greet::client $chan $name client $msg
  }
}

## ::server::handle::user chan as channel
#
# record details, respond, set up fileevent for each channgel.
#
proc ::server::greet::client {chan name handle {message ""}} {
	fconfigure $chan -buffering line
	puts $chan [list "from" "server" "to" $name "message" "you are $name your channel is $chan"]
	if {$message eq ""} {
		lappend ::clients $name $chan
	} else {
		lappend ::clients $name "$chan [::server::get::myAbove $message] [::server::get::myBelow $message]"
	}
	fileevent $chan readable [list ::server::handle::[set handle] $chan]
}


################################################################################################################################################################
# run #########################################################################################################################################################
################################################################################################################################################################


::server::global
socket -server ::server::accept 9900
vwait forever
