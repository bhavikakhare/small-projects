# script to return ranked list of query results for a given query
  use strict;
  use warnings;

# read RI file into matrix or sth

my %r_index = () ;
open FILE, "reverse_index.txt" or die $! ;
my $key ;
my $df ;
my $start_index ;
my $end_index ;
my $tf_string ;
my @hash_values ;
my $ctr = 0 ;
while ( my $line = <FILE> ) {
    chomp($line);
    # chomp($line);
    $start_index = index( $line , '\t' ) ;
    $key = substr $line , 0 , $start_index ;
    # my ($key) = $line =~ /^(.*?)\s/;
    if( $ctr < 2 ) {
      print("\nPR $start_index x $line") ; 
      $ctr=$ctr+1 ; 
    }
    $line = substr $line , index( $line , '\t' ) +1 ;
    $df = substr $line , 0 , index( $line , '\t' ) ;
    # if( $ctr < 2 ) {
    #   # print("\n $line") ; 
    #   $ctr=$ctr+1 ; 
    # }
    $line = substr $line , index( $line , '\t' ) +1 ;
    $start_index = index($line,'{') ;
    $end_index = index($line,'}') ;
    $tf_string = substr $line , $start_index +1 , $end_index-$start_index -1 ;
    $tf_string =~ s/\s+//g ;
    @hash_values = split(';',$tf_string) ;
    foreach my $hash_value( @hash_values ) {
        $start_index = index($hash_value,':') ;
        $end_index = length($hash_value) ;
        my %new_hash = () ;
        if( exists($r_index{$key}) ) {
        } else {
          $r_index{$key} =  \%new_hash ;
        }
        $r_index{$key}{ substr $hash_value , 0 , $start_index } = substr $hash_value , ($start_index+1) ;
    }
}
close FILE;

# ask for query

if( scalar @ARGV > 0 ) {

} 

# proprocess query

# calculate cosim with all documents each word is in & store in list -> order it

# map file-number to the page-link

# print the relevant links

#####

# make an HTML page

# make a form on it &  server
