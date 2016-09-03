namespace eval ::encode {}
namespace eval ::encode::set {}


proc ::encode::set::globals {} {
  set ::encode::state {}
}



proc ::encode::this {msg action} {
  if {$::memorize::learn} {
    # do your thing.
  }
}
