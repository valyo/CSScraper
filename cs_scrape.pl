use strict;
use v5.10;

use URI;
use YAML;
use Web::Scraper;
binmode STDOUT, ":utf8";

# number of molecules 
my $n = 125000;

# scraper block
my $list = scraper {
	process "._quick-comp-ids", "rec_details" => 'TEXT';
	process ".prop_title", "prop[]" => 'TEXT';
	process ".prop_value", "value" => 'TEXT';
	process ".prop_value_nowrap", "valuenw[]" => 'TEXT';
};

# print start date and time
print scalar(localtime(time + 0)), "\n";
# print column names
say join ",","SMILES","logP","logD","ChemSpiderID",;
for (my $i = 1; $i <= $n; $i++){
	my $t = int(rand(4)) + 4;
	sleep($t) unless $i == 1;
	my $xxx = int(rand(25000000)) + 1;
	my $listres = Dump($list->scrape( URI->new("http://www.chemspider.com/Chemical-Structure.$xxx.html") ));
	my $h2 = Load(join "", $listres) or die $!;
	next unless my $details = $h2->{rec_details};
	my $start = index($details, "SMILES:");
	my $end = index($details, "Copy");
	$details = substr $details, $start, $end-$start;
	$details = substr($details, index($details, ":") + 1);
	my $logP = $h2->{value};
	my $logD = $h2->{valuenw}[1];
	if (!$logP || !$logD) {
		$i--;
		next;
	}
	$logP =~ s/^\s+|\s+$//g;
	$logD =~ s/^\s+|\s+$//g;
	say join ",", $details, $logP, $logD, $xxx,;
}
# print end date and time
print scalar(localtime(time + 0)), "\n";
