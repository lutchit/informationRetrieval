#!/usr/bin/env perl

use parser;
use parser2;
use writer;
use strict;
# use warnings;

my @requests = (
    'olive oil health benefit',
    'notting hill film actors',
    'probabilistic models in information retrieval',
    'web link network analysis',
    'web ranking scoring algorithm',
    'supervised machine learning algorithm',
    'operating system mutual exclusion');


my @writingListLtn = ();
my @writingListBm25 = ();
my $compteur = 0;

my $nbDocuments = 9804;
my %postingList = ();
my %docsList = ();


parser::parsing(\%postingList, \%docsList);

my $avgdl = avgdl(%docsList);

print $avgdl;

#
# my %postingList = (
#     'olive' => {'doc1' => '5', 'doc2' => '1'},
#     'oil' => {'doc1' => '4', 'doc3' => '3'}
# );

for my $request (@requests) {
    my @requestTerms = split(/ /, $request);
    my %RSVltn = ();
    my %RSVbm25 = ();
    for my $term (@requestTerms) {
        if(exists $postingList{$term}) {
            my %hash = %{$postingList{$term}};
            for my $key (keys %hash) {
                my $scoreLtn = ltn($hash{$key}, scalar(keys %hash));
                my $scoreBm25 = bm25($hash{$key}, scalar(keys %hash), 1.2, 0.5, $key);
                if(exists $RSVltn{$key}) {
                    $RSVltn{$key} = $RSVltn{$key} + $scoreLtn;
                } else {
                    $RSVltn{$key} = $scoreLtn;
                }
                if(exists $RSVbm25{$key}) {
                    $RSVbm25{$key} = $RSVbm25{$key} + $scoreBm25;
                } else {
                    $RSVbm25{$key} = $scoreBm25;
                }
            }
        }
    }
    $compteur = 0;
    foreach my $doc ( reverse (sort { $RSVltn{$a} <=> $RSVltn{$b} } keys %RSVltn) ) {
        printf "%-8s %s\n", $doc, $RSVltn{$doc};
        push(@writingListLtn, $doc);
        $compteur++;
        last if ($compteur == 1500);
    }

    $compteur = 0;
    foreach my $doc ( reverse (sort { $RSVbm25{$a} <=> $RSVbm25{$b} } keys %RSVbm25) ) {
        printf "%-8s %s\n", $doc, $RSVbm25{$doc};
        push(@writingListBm25, $doc);
        $compteur++;
        last if ($compteur == 1500);
    }

    # Sort RSV by increasing score and keep the best 1500 results
    # Write the 1500 result lines for the current request
    writer::writeRuns("02", "ltn", @writingListLtn);
    writer::writeRuns("02", "bm25", @writingListBm25);
}

sub bm25 {
    my $tf = shift;
    my $df = shift;
    my $k = shift;
    my $b = shift;
    my $docNo = shift;
    my $newTf = ($tf*($k+1))/($k*((1 + $b) + $b * (%docsList{$docNo} / $avgdl)) + $tf);
    my $newIdf = log(($nbDocuments - $df + 0.5)/($df + 0.5));
    return $newTf*$newIdf;
}

# bm25(term, docNo, k, b){ //On peut prendre k=1 et b=0.5 ; 0<b<1 ; 0<k<+infini
# 	hash = postList[term]
# 	tf = hash[docNo]
# 	df = length(hash) //nb de documents dans lesquels apparait le terme
# 	newtf = (tf*(k+1))/(k*((1+b)+b*(docLengths[docNo]/avgdl))+tf)
# 	newidf = log((nbDoc-df+0.5)/(df+0.5))
# 	bm25 = newtf*newidf
# 	return bm25
# }

sub ltn {
    my $tf = shift;
    my $df = shift;
    return (1 + log($tf))*(log($nbDocuments/$df))*(1);
}

sub avgdl {
  my $length = 0;
  for my $key (keys %docsList){
    $length += %docsList{$key};
  }
  print "LENGTH" . $length;
  return $length/(scalar(keys %docsList));
}
