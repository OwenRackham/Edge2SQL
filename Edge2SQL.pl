#!/usr/bin/perl -w

use strict;
use warnings;
use DBI;
use lib '/home/rackham/modules/';
use rackham;
my ( $dbh, $sth );
$dbh = rackham::DBConnect('rackham');

my $dirto = $ARGV[0];

opendir my $dir, "$dirto" or die "Cannot open directory: $!";
my @files = readdir $dir;

foreach my $file (@files){
	next if ($file =~ m/^\./);
	next if ($file =~ m/^tabs/);
	my $filename = $file;
	$file =~ s/\.csv//g;
	my @sample = split('_vs_',$file);
	#print "$dirto"."$filename\n";
	open FILE, "$dirto"."$filename" or die $!;
	#open OUTPUT, ">"."$dirto"."tabs/"."$file".".tab"; 
	while (<FILE>){
		next if ($_ =~ m/^logConc/);
		my @line = split(',',$_);
		my $sth=$dbh->prepare( "INSERT INTO TC_expressions (sampleID,backgroundID,GeneSymbol,logConc,logFC,P_value,adj_P_value) VALUES ('$sample[0]','$sample[1]','$line[0]','$line[1]','$line[2]','$line[3]','$line[4]')" );
		$sth->execute;
		#print OUTPUT "$sample[0]\t$sample[1]\t$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\n";
	}
}

closedir $dir;
