namespace eval ::chain {

  proc this {seed args} {
    foreach arg $args {
      set index [lsearch -all $arg {}]
      foreach in $index {
        set arg [lreplace $arg $in $in $seed]
      }
      set seed [{*}$arg]
    }
    return $seed
  }

  proc inspect {args} {
    puts {*}$args
    return {*}$args
  }
}
