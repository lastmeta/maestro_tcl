proc allNumbers {} {
  puts "about to yield"
  yield
  puts "done yielding"
  set i 0
  while 1 {
    puts "about to yield in while loop i = $i"
    yield $i
    incr i 2
    puts "done yeilding in while loop i = $i"
  }
}
after 2000
coroutine nextNumber allNumbers
after 2000
for {set i 0} {$i < 10} {incr i} {
  after 2000
  puts "received [nextNumber]"
}
after 2000
rename nextNumber {}
puts "nextnumber [nextNumber]"
