#!/usrb/bin/perl

use strict;
use warnings;
use File::Find qw(find);
use Cwd;
use Getopt::Long;
use IO;
use XML::Writer;

our $dir_file;
our $file_extension;
our $lookup;
our $init_dir = getcwd;
our $csv_file = "results.csv";
our $xml_file = "results.xml";
our @results;


sub export_csv {
	
	open WFILE, ">", "$init_dir/$csv_file" or die $!;
	foreach(@results) {
		print WFILE $_;
	}
	close (WFILE);
	print "created file with results: $init_dir/$csv_file\n";

}

sub export_xml {

	my $output = new IO::File(">$init_dir/$xml_file");
	my $writer = new XML::Writer( OUTPUT => $output );

	$writer->xmlDecl('UTF-8');
	$writer->startTag('root');

	foreach(@results) {
		my ($name, $line, $result) = split (/,/, $_);
		$writer->startTag('file', 'name' => $name);
		$writer->startTag('line');
		$writer->characters($line);
		$writer->endTag('line');
		$writer->startTag('result');
		$writer->characters($result);
		$writer->endTag('result');
		$writer->endTag('file');

	}
    
    $writer->endTag('root');
    $writer->end();
    $output->close();
	
}

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
	
	if(scalar(@results == 0)) { 
		print "No results found!\n";
		return;
	}
	
	my $export = \&export_xml;
	&$export();

}


main()
