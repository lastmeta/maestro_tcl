namespace eval ::see {}

# {\
#   {from {} to {} when {} about {} message {} command {}} \  <-full, empty
#   {from 2.1 to 1.1 message _ command try} \                 <-stop example
#   {from 1.1 to s.1 message __} \                            <-stop example
# }

proc ::see::from msg {
  return [::see::ifNotBlank $msg from]
}
proc ::see::to msg {
  return [::see::ifNotBlank $msg to]
}
proc ::see::when msg {
  return [::see::ifNotBlank $msg when]
}
proc ::see::about msg {
  return [::see::ifNotBlank $msg about]
}
proc ::see::command msg {
  return [::see::ifNotBlank $msg command]
}
proc ::see::message msg {
  return [::see::ifNotBlank $msg message]
}
proc ::see::contents msg {
  if {[::see::ifNotBlank $msg from]     eq "" &&
      [::see::ifNotBlank $msg to]       eq "" &&
      [::see::ifNotBlank $msg when]     eq "" &&
      [::see::ifNotBlank $msg about]    eq "" &&
      [::see::ifNotBlank $msg command]  eq "" &&
      [::see::ifNotBlank $msg message]  eq ""
  } then {
    return
  }
  return [dict keys $msg]
}

proc ::see::ifNotBlank {msg key} {
  if {[dict exists $msg $key]} {
    return [dict get $msg $key]
  }
  return
}
