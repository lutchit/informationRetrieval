#!/usr/bin/env perl

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


my $nbDocuments = 9800;
# my %postingList = parsing();
my %postingList = (
    'olive' => {'doc1' => '5', 'doc2' => '1'},
    'oil' => {'doc1' => '4', 'doc3' => '3'}
);

for my $request (@requests) {
    my @requestTerms = split(/ /, $request);
    my %RSV = ();
    for my $term (@requestTerms) {
        my %hash = %{$postingList{$term}};
        for my $key ( keys %hash ) {
            my $score = ltn($hash{$key}, scalar(keys %hash));
            if(exists $RSV{$key}) {
                $RSV{$key} = $RSV{$key} + $score;
            } else {
                $RSV{$key} = $score;
            }
        } 
    }
    print "size of hash:  " . keys( %RSV ) . ".\n";
    for my $key ( keys %RSV ) {
        my $value = $RSV{$key};
        print "$key => $value\n";
    }
    # Sort RSV by increasing score and keep the best 1500 results
    # Write the 1500 result lines for the current request
}

sub ltn {
    my $tf = shift;
    my $df = shift;
    return (1 + log($tf))*(log($nbDocuments/$df))*(1);
}

# ltnResults = ltn(postingList)
# ltcResults = ltc(postingList)

# writeRuns(ltnResults)
# writeRuns(ltcResults)

# sub function {
#     my $arg1 = shift;
#     my $arg2 = shift;
# }

# function(value1, value2);