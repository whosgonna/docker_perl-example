#!/usr/bin/env perl

use 5.030;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new();

my $resp = $ua->get('https://perl.org');

my $cont = $resp->decoded_content;

say $cont;
