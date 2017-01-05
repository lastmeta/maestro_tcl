proc convert {arb roman} {
  if {$arb > 1000} {
    lappend roman M
    set arb [expr $arb-1000]
  } elseif {$arb >= 500} {
    lappend roman D
    set arb [expr $arb-500]
  } elseif {$arb >= 100} {
    lappend roman C
    set arb [expr $arb-100]
  } elseif {$arb >= 50} {
    lappend roman L
    set arb [expr $arb-50]
  } elseif {$arb >= 10} {
    lappend roman X
    set arb [expr $arb-10]
  } elseif {$arb >= 5} {
    lappend roman V
    set arb [expr $arb-5]
  } elseif {$arb >= 1} {
    lappend roman I
    set arb [expr $arb-1]
  }
  if {$arb > 0} {
    convert $arb $roman
  } else {
    return $roman
  }
}


if { $argc != 1 } {
  puts "tclsh kata 123"
} else {
  puts "$argv -->"
  puts [string map {" " ""} [convert $argv ""]]
}
