#!/usr/bin/perl

use strict;

use Test::Harness;
use FindBin;

runtests(<$FindBin::Bin/*.t>);
