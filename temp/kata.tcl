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

# iiii -> iv
proc simplify1 {romans} {
  lappend romans "end"
  set rome ""
  set same 0
  set count -1
  set last ""
  foreach roman $romans {
    set last [lindex $romans $count]
    if {$last eq $roman} {
      incr same
    }
    if {$same == 3} {
      set rome [concat [lrange $rome 0 [expr [llength $rome] - 4]] $roman [next $roman]]
      set same -1
    } else {
      lappend rome $roman
    }
    incr count
  }
  if {$rome ne $romans} {
    set rome [lrange $rome 0 end-1]
    simplify1 $rome
  } else {
    set rome [lrange $rome 0 end-1]
    return [simplify2 $rome]
  }
}

# viv -> ix
proc simplify2 {romans} {
  lappend romans "end"
  set rome ""
  set oneback ""
  set count 0
  set twoback ""
  foreach roman $romans {
    set twoback [lindex $romans $count-2]
    set oneback [lindex $romans $count-1]
    if {$twoback       eq $roman
    && [last $twoback] eq $oneback
    &&  $twoback       ne ""
    } then {
      set rome [concat [lrange $rome 0 end-2] $oneback [next $twoback]]
    } else {
      lappend rome $roman
    }
    puts "rome is $rome"
    incr count
  }
  if {$rome ne $romans} {
    set rome [string map {" end" ""} $rome]
    simplify1 $rome
  } else {
    set rome [string map {" end" ""} $rome]
    return $rome
  }
}


proc next {letter} {
  switch $letter {
    I {return V}
    V {return X}
    X {return L}
    L {return C}
    C {return D}
    D {return M}
    M {return -}
    default {return -}
  }
}

proc last {letter} {
  switch $letter {
    V {return I}
    X {return V}
    L {return X}
    C {return L}
    D {return C}
    M {return D}
    - {return M}
    default {return _}
  }
}


if { $argc != 1 } {
  puts "tclsh kata.tcl 123"
} else {
  puts "$argv -->"
  puts [string map {" " ""} [simplify1 [convert $argv ""]]]
}
