namespace eval ::memorize {}
namespace eval ::memorize::set {}
namespace eval ::memorize::record {}

################################################################################################################################################################
# SETUP ########################################################################################################################################################
################################################################################################################################################################


proc ::memorize::set::globals {} {
  set ::memorize::learn   yes       ;# for memorize
  set ::memorize::encode  no        ;# for encoding
  set ::memorize::loc     ""        ;# current location or latest input
  set ::memorize::act     ""        ;# last action
  set ::memorize::input   ""        ;# new input
  set ::memorize::levels  ""        ;# level count
  set ::memorize::regions ""        ;# region count
}

proc ::memorize::set::learn {msg} {
  if {$msg eq "on"} {
    set ::memorize::learn   yes
  } elseif {$msg eq "off"} {
    set ::memorize::learn   no
  } else {
    set ::memorize::learn   $msg
  }
}


proc ::memorize::set::encode {msg} {
  if {$msg eq "on"} {
    set ::memorize::encode   yes
  } elseif {$msg eq "off"} {
    set ::memorize::encode   no
  } else {
    set ::memorize::encode   $msg
  }
}

################################################################################################################################################################
# Make Memory ##################################################################################################################################################
################################################################################################################################################################


proc ::memorize::this {msg} {
  ::memorize::makeMemory [::see::when $msg] [::see::message $msg] [::see::command $msg]
  set ::memorize::input [::see::message $msg]
}

proc ::memorize::makeMemory {when input isnoise} {
  if {$::memorize::learn
  &&  $::memorize::loc ne ""
  &&  $input           ne ""
  } then {
    if {$isnoise         ne "noise"
    &&  $::memorize::act ne ""
    } then {
      ::memorize::record::lastStep $when $::memorize::loc $::memorize::act $input
    } else {
      ::memorize::record::lastStep $when $::memorize::loc "_" $input
    }
  }
  # this is commented out because it don't work well and takes a lot of time during exploration.
  #set ::encode::lastaction $::memorize::act
  set ::memorize::act {}
  set ::memorize::loc $input
}


################################################################################################################################################################
# RECORD #######################################################################################################################################################
################################################################################################################################################################

proc ::memorize::record::lastStep {when input action result} {
  set $action [string trim $action]
  if {$action ne ""} {
    if {$result eq $input} {
      ::memorize::record::newBad $when $input $action $result
    } else {
      ::memorize::record::newMain $when $input $action $result
    }
  }
}

# Saves a new main action if there isn't one in the database already.
proc ::memorize::record::newMain {when input action result} {
  set returned [::repo::get::allMatch main $input [string trim $action] $result]
  if {$returned eq ""} {
    set mainid [::repo::insert main "time $when input $input action $action result $result"]
    #tables:
    # regions(level,region,mainid,reg_to)
  	# roots(state,level,region)

    #first:
    #if input is a root.
      #do notihng
    #else
      #if input ins't listed in main as input or result previously (other than mainids) (if inputid == mainid)
        #for set i 1 to levels
          #make a new root
          #if you need to make a new level do so
      #else
        #if you need to make a new region do so.
        #make a region
    #endif



    #foreach level from 1 to levels
      #get the region that in the input belongs to
      #get the region that in the result belongs to
      #get the action - the main id that is in mainid

    #if this belongs to a new region we've never seen before
      #(that is to say if this result is not a state we've seen in main or result before?)

  }
}

# Saves a new bad move if there isn't one in the database already.
proc ::memorize::record::newBad {when input action result} {
  set returned [::repo::get::allMatch bad $input [string trim $action] $result]
  if {$returned eq ""} {
    ::repo::insert bad "time $when input $input result $result action $action"
  }
}
