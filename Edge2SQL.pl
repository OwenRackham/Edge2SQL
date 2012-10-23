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

my $sampleID = 1;
my %sampleIDs;
my %links;
foreach my $file2 (@files){
	next if ($file2 =~ m/^\./);
	next if ($file2 =~ m/^tabs/);
	my $t = $file2;
	$t =~ s/\.csv//g;
	my @sample = split('_vs_',$t);
	#print STDERR "this $file\n";
	#####RESOLVE SAMPLE IDS############
	unless(exists($sampleIDs{$sample[0]})){
		$sampleIDs{$sample[0]} = $sampleID;
		$sampleID++;
	}
	unless(exists($sampleIDs{$sample[1]})){
		$sampleIDs{$sample[1]} = $sampleID;
		$sampleID++;
	}
	######RESOLVE GROUPS#################
	$links{$sample[0]}{$sample[1]} = 1;
	$links{$sample[1]}{$sample[0]} = 0;
}
########REPERCULATE THROUGH GROUPS#########
my $group = 0;
my %groups;
foreach my $a (keys %links){
	unless(exists($groups{$a})){
		$groups{$a} = $group;
	}
	foreach my $b (keys %{$links{$a}}){
		unless(exists($groups{$b})){
			$groups{$b} = $group;
		}
	} 
	$group++;
}

foreach my $file (@files){
	print "file is $file\n";
	next if ($file =~ m/^\./);
	next if ($file =~ m/^tabs/);
	my $filename = $file;
	$file =~ s/\.csv//g;
	my @sample = split('_vs_',$file);
	print "$dirto"."$filename\n";
	open FILE, "$dirto"."$filename" or die $!;
	#open OUTPUT, ">"."$dirto"."tabs/"."$file".".tab"; 
	while (<FILE>){
		chomp;
		next if ($_ =~ m/^logConc/);
		my @line = split(',',$_);
		
		my $sth=$dbh->prepare( "INSERT INTO TC_expressions (sampleID,SampleName,backgroundID,BackgroundName,groupID,GeneSymbol,logConc,logFC,P_value,adj_P_value) VALUES ('$sampleIDs{$sample[0]}','$sample[0]','$sampleIDs{$sample[1]}','$sample[1]','$groups{$sample[0]}','$line[0]','$line[1]','$line[2]','$line[3]','$line[4]')" );
		$sth->execute;
		#print STDERR "$sampleIDs{$sample[0]}\t$sample[0]\t$sampleIDs{$sample[1]}\t$sample[1]\t$groups{$sample[0]}\t$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\n";
		
		print  "$sampleIDs{$sample[0]}\t$sample[0]\t$sampleIDs{$sample[1]}\t$sample[1]\t$groups{$sample[0]}\t$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\n";
	}
}

closedir $dir;
