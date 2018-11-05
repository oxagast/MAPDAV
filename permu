#!/usr/bin/perl
use Algorithm::Permute qw/permute/;
$|++;
while (<STDIN>) {
    push @data, $_;
}
my $perm = Algorithm::Permute->new( \@data, 2 );
while ( my @set = $perm->next ) {
    for $setoffset ( 1 .. scalar(@set) - 1 ) {
        $wipe = "$set[$cb]$set[$cb+$setoffset]";
        $wipe =~ s/\W//g;
        for $b ( 100 .. 999 ) {
            print $wipe . $b . "\n";
        }
    }
}
