namespace eval ::intuit {}
namespace eval ::intuit::set {}
namespace eval ::intuit::get {}
namespace eval ::intuit::remove {}
namespace eval ::intuit::compile {}
namespace eval ::intuit::order {}

proc ::intuit::get::guess {state} {
  return [::chain::this $state                                  \
                  [list ::repo::get::connectom::connections {}] \
                  [list ::intuit::remove::otherNodes {} $state] \
                  [list ::intuit::remove::zeros             {}] \
                  [list ::intuit::compile::list             {}] \
                  [list ::intuit::order::list               {}] \ ]
}
