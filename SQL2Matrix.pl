#!/usr/bin/perl -w

use strict;
use warnings;
use DBI;
use lib '/home/rackham/modules/';
use rackham;
my ( $dbh, $sth );
$dbh = rackham::DBConnect('rackham');

my $seed = $ARGV[0];

my $sth=$dbh->prepare( "INSERT INTO TC_expressions (sampleID,backgroundID,GeneSymbol,logConc,logFC,P_value,adj_P_value) VALUES ('$sample[0]','$sample[1]','$line[0]','$line[1]','$line[2]','$line[3]','$line[4]')" );
$sth->execute;