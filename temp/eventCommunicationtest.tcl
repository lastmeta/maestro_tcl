proc GetData {chan} {
    if {[gets $chan line] >= 0} {
       puts -nonewline "Read data: "
       puts $line
    }
}

fconfigure stdin -blocking 0 -buffering line -translation crlf
fileevent stdin readable [list GetData stdin]

vwait forever

#set ::chan [socket 127.0.0.1 9900]
#fconfigure $::chan -blocking 0
#::user::run
#vwait forever
