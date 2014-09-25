#!/usr/local/sc/sc.bin/perl

open F, \"> e:/temp/junk32.txt\" or die \"Can\'t open: $!\\n\";

print F \"Test it: \", scalar(localtime), \"\\n\";

print F \"Addr: %DELIVERY_ADDRESS%\\n\";

#####

close F;

exit;