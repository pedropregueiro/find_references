#!/usrb/bin/perl

use strict;
use warnings;
use File::Find qw(find);
use Cwd;

our $dir_file;
our $file_extension;
our $lookup;
our $init_dir = getcwd;
our $csv_file = "results.csv";
our @results;

sub wanted {
	
	my $file_name;
	my $counter = 1;
	my $line;

    if ($_ =~ /$file_extension$/ && -T $File::Find::name) {
	    $file_name = $File::Find::name;
	}
	else { 
		return; 
	}

	open FILE, "<", $file_name or die $!;
	while ($line = <FILE>) {
		if($line =~ /.*?$lookup.*?/i) {
			push(@results, $file_name . "," . $counter . "," . $line);
		}	
		$counter++;
	}
	
	close(FILE);
}

sub main {
	
	if($#ARGV != 2) {
		print "Usage: perl find_refs.pl <directory> <file_extension> <lookup string>\n";
		return;
	}	

	$dir_file = $ARGV[0];
	$file_extension = $ARGV[1];
	$lookup = $ARGV[2];

	print "looking for the string '$lookup' in '*$file_extension' files in the directory '$dir_file'\n";
	find(\&wanted, $dir_file);
	

	# todo: parse an extra argument to decide output: xml, csv, etc...
	# currently only exporting to csv

	open WFILE, ">", "$init_dir/$csv_file" or die $!;
	foreach(@results) {
		print WFILE $_;
	}
	close (WFILE);
	print "created file with results: $init_dir/$csv_file\n";

}


main()
