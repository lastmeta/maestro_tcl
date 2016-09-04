namespace eval ::encode {}
namespace eval ::encode::set {}
namespace eval ::encode::map {}


################################################################################
# Set ##########################################################################
################################################################################

proc ::encode::set::globals {} {
  set ::encode::state {}
  ::encode::set::actions
}

proc ::encode::set::actions {} {
  set max [::repo::get::maxColumn]
  if {[string trim $max] eq "{}"} {
    for {set i 0} {$i < 100} {incr i} {
      ::repo::insert map [list column $i input $i ix a type action]
    }
  }
}

################################################################################
# Encode #######################################################################
################################################################################

proc ::encode::this {input action} {
  if {$::memorize::learn eq "no"} { return }

  ::encode::map::input $input
  ::encode::map::action $action


}


################################################################################
# map ##########################################################################
################################################################################


proc ::encode::map::input {input} {
  set max [::repo::get::maxColumn]
  puts "max   is $max"
  if {$max < 100} { set max 100 }
  puts "max   is $max"
  puts "input is $input"
  for {set i 0} {$i < [string length $input]} {incr i} {
    puts "$i is [string index $input $i]"
    if {[::repo::get::mapMatch [string index $input $i] $i state ] eq ""} { ;# alternatively, get all of map and search through it manually.
      incr max
      puts "in if...[list column $max input [string index $input $i] ix $i type state]"
      ::repo::insert map [list column $max input [string index $input $i] ix $i type state]
    }
  }
}

proc ::encode::map::action {action} {
  if {$action ne ""} {
    if {[::repo::get::mapMatch $action a action ] eq ""} {
      ::repo::insert map [list column $action input $action ix a type action]
    }
  }
}
