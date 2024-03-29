#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 2;

# Test set 1 -- can we load the library?
BEGIN { use_ok('Data::Pageset::HTML'); }

# Test set 2 -- create client with ordered list of arguements
my $pager = Data::Pageset::HTML->new( {
        total_entries    => 100,
        entries_per_page => 10,
} );
ok $pager, "Created new Data::Pageset::HTML";
