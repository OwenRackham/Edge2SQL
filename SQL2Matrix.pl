#!/usr/bin/perl -w

use strict;
use warnings;
use DBI;
use lib '/Users/rackham/modules/';
use rackham;
my ( $dbh, $sth );
$dbh = rackham::DBConnect('rackham');

my $seed = $ARGV[0];

my %data;
my %samples;
my %genes;
my $sth=$dbh->prepare( "select distinct SampleName,SampleID,group from TC_expressions where backgroundID = $seed;" );
$sth->execute;
while ( my @temp = $sth->fetchrow_array ) {
		$data{$temp[0]}{$temp[1]} = $temp[2];
		$genes{$temp[1]} = 1;
		$samples{$temp[0]} = 1;
	}
	print "genes\t";
	my $list = join(':', sort keys %samples);
	print $list;
	print "\n";
	foreach my $gene (sort keys %data){
		print "$gene";
		foreach my $sample (sort keys %{$data{$gene}})){
			print "\t$sample{$gene}{$sample}";
		}
		print "\n";
	}
	
	