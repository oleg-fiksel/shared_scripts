#!/usr/bin/perl -w
use strict;
use warnings;

use 5.012; # so readdir assigns to $_ in a lone while test

use Getopt::Std;
use File::Path;
my %opts;
$opts{l}=14;
$opts{w}=60;
$opts{t}=0;
getopts('td:l:w:', \%opts);

die <<EOF if !defined $opts{d};
Usage:

	$0 -d /path/to/backup_dir [-l 14] [-w 60] [t]

	-d 		directory to scan for files
	-l 		how many files to leve behind (default: $opts{l})
	-w 		how long to wait before deleting the files (default: $opts{w})
	-t 		test run (don't delete anything)
EOF

main();
exit 0;

sub get_first_n_elements {
	my ($n,@array)=@_;
	@array=sort {$b cmp $a} @array;
	for(my $i=0; $i < $n;$i++){
		shift @array;
	}
	return @array;
}

sub delete_list{
	my @delete_list=@_;
	if(@delete_list > 0){
	    print "Going to delete in $opts{w} sec:\n".join($/,@delete_list)."\n";
		sleep $opts{w};
		return 0 if $opts{t}==1;
		foreach my $file (@delete_list){
			rmtree $opts{d}.'/'.$file
				or warn "Could not unlink $file: $!";
		}
	}
}

sub main{
	opendir(my $dh, $opts{d}) || die "Can't opendir $opts{d}: $!";
	my @list = grep { $_ !~ /^\./} readdir($dh);
	closedir $dh;
	@list=get_first_n_elements($opts{l},@list);
	delete_list(@list);
}
