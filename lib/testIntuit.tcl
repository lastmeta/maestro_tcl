source ./see.tcl          ;# get info from msg
source ./prepdata.tcl     ;# mostly for recall
source ./communicate.tcl  ;# hear from and talk to server.
source ./memorize.tcl     ;# record raw data
source ./decide.tcl       ;# when you get new data, decide what to do with it.
source ./recall.tcl       ;# get actions and action chains from raw data
source ./sleep.tcl        ;# post analyzation of data to discover structure.
source ./encode.tcl       ;# encode raw data into a relative strucutre
source ./intuit.tcl       ;# get action chains from relative structure
pkg_mkIndex -verbose [pwd] ./repo.tcl
lappend auto_path [pwd]
package require repo 1.0

::repo::create 1.1




##    set theoryactions {}
#    while $newgoal is not in database {
##      set newgoal           [lindex [::intuit::guess $goal] 0]
      #puts [
      ::intuit::guess "000"
      #]
#    }
