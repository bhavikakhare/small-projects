# reverse_index.pl
# BY B KHARE :)

# run in cmd with "perl reverse_index.pl hw5_input"

use warnings;
use strict;
use File::Slurp;

my $folder = shift @ARGV ;
my @files = <$folder/*.txt> ;
my %frequencies = () ;
my $word ;
my $file_name ;


foreach my $file (@files) {

    %counted = () ;

    my $content = read_file($file) ;
    my @words = split( ' ', $content ) ;

    while ( $word = pop @words ) {

        # add to that document frequency C
        if(exists($frequencies{$word})) {
            $frequencies{$word}{$file}++ ;
        } else {
            my %new_hash = () ;
            $frequencies{$word} = \%new_hash ;
            $frequencies{$word}{$file} =1 ;
        }
        # print "$word + $frequencies{$word}{$link} + $link\n" ;
    }
    print "read $file\n" ;

}

close( FILE_LENGTH ) ;

open( FILEOUT , '>', "reverse_index.txt" )
            or die("can not open reverse_index.txt to print to it \n\n");
my $output = "" ;

print "indexing\n" ;

foreach $word ( sort keys %frequencies ) {

    # print "\nlooping" ;
    # print document count

    my $sum = 0 ;
    my $size = 0 ;
    $output = "" ;
    foreach my $file(@files) { # do i need to check if $f($w) is an existing hash ?
        if(exists($frequencies{$word})) {
            if( exists($frequencies{$word}{$file}) && $frequencies{$word}{$file}>0 ) {

                # file_name formatting to pretty it up
                $file_name = $file ;
                # $file_name = substr( $file_name , index($file_name,'\\') ) ;
                # $file_name = substr($file_name,index($file_name,'/')+1,-4) ;
                if ( $file_name =~ /_(\d*)\.txt$/ ) { $file_name = $1 ; }

                $size = $size +1 ;
                $output = "$output$file_name: $frequencies{$word}{$file};\t" ;
                # $sum = $frequencies{$word}{$file} + $sum ;
            }
        }
    }
    # $size = scalar keys $frequencies{$word} ;
    print FILEOUT "$word ($size) \t{\t$output}\n" ;

}

