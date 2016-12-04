#!/usr/bin/env perl

use parser;
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


my @writingList = ();
my $compteur = 0;

my $nbDocuments = 9800;
my %postingList = parser::parsing();
# my %postingList = (
#     'olive' => {'doc1' => '5', 'doc2' => '1'},
#     'oil' => {'doc1' => '4', 'doc3' => '3'}
# );

for my $request (@requests) {
    my @requestTerms = split(/ /, $request);
    my %RSV = ();
    for my $term (@requestTerms) {
        if(exists $postingList{$term}) {
            my %hash = %{$postingList{$term}};
            for my $key (keys %hash) {
                my $score = ltn($hash{$key}, scalar(keys %hash));
                if(exists $RSV{$key}) {
                    $RSV{$key} = $RSV{$key} + $score;
                } else {
                    $RSV{$key} = $score;
                }
            }
        }
    }
    $compteur = 0;
    foreach my $doc ( reverse (sort { $RSV{$a} <=> $RSV{$b} } keys %RSV) ) {
        printf "%-8s %s\n", $doc, $RSV{$doc};
        push(@writingList, $doc);
        $compteur++;
        last if ($compteur == 1500);
    }
#
#     for my $k (keys %RSV){
#   print "$k : $RSV{$k}\n";
# }

    # Sort RSV by increasing score and keep the best 1500 results
    # Write the 1500 result lines for the current request
    writer::writeRuns("02", "ltn", @writingList);
}

sub ltn {
    my $tf = shift;
    my $df = shift;
    return (1 + log($tf))*(log($nbDocuments/$df))*(1);
}
