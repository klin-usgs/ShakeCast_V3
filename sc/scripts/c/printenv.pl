#!c:/perl/bin/perl.exe
#!/usr/local/sc/sc.bin/perl
#
# $Id: printenv.pl 64 2007-06-05 14:58:38Z klin $
#
# Print Environment
#


print <<EOF;
Content-type: text/html

<html>
<head><title>CGI Server Environment Variables</title></head>
<body bgcolor="#ffffff">

<h1>CGI Server Environment Variables</h1>
<FONT COLOR="#000080">
<pre>
EOF

foreach $key (sort keys %ENV) {
	print $key, '=', $ENV{$key}, "\n";
}

print <<EOF;
</body>
</html>
EOF
