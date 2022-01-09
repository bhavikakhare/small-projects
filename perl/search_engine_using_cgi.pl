#!C:\Strawberry\perl\bin\perl.exe
# script to return ranked list of query results for a given query

  use strict;
  use warnings;
  use File::Slurp;
  use Lingua::Stem;
  use Math::Complex;
  use CGI ':standard';

# code to test cgi
#    print "Content-Type: text/html\n\n";
#    print "<html><body>\n";
#    print "Hello world!\n";
#    print "</html></body>\n";

# read RI file into matrix or sth

my @hash_values ;
my $ctr = 0 ;
my %url = () ;
my %score = () ;
my $file ;

my $stemmer = Lingua::Stem->new( -locale => 'EN-UK' ) ;


# get stopwords from file 

my $stopwords_file = "english_stopwords.txt" ;
my @stopwords ;

open( STOPWORDS , '<', $stopwords_file )
  or die("can not open output file to print it \n\n");

while (<STOPWORDS>) {
    push( @stopwords , $_ );
}

close(STOPWORDS);


# read reverse_index.txt into a hash

my %r_index = () ;
my $key ;
my $start_index ;
my $end_index ;
my $tf_string ;

my $file_content = read_file('reverse_index.txt') ;
my @array_content = split('\n',$file_content) ;

foreach my $line(@array_content) {

    $line =~ s/\s+//g ;
    $end_index = index( $line , '(' ) ;
    $key = substr $line , 0 , $end_index ;
    $start_index = index($line,'{') ;
    $end_index = index($line,'}') ;
    $tf_string = substr $line , $start_index +1 , $end_index-$start_index -1 ;
    @hash_values = split(';',$tf_string) ;

    foreach my $hash_value( @hash_values ) {
        $start_index = index($hash_value,':') ;
        my %new_hash = () ;
        if( exists($r_index{$key}) ) {
        } else {
          $r_index{$key} =  \%new_hash ;
        }
        my $tf_file_name = substr $hash_value , 0 , $start_index ;
        if( index( $tf_file_name , "stopwords" ) == -1) {
            $r_index{$key}{ $tf_file_name } = substr $hash_value , ($start_index+1) ;
        }
    }

}

# ask for query

my $query = "apple" ;
$query = param("query");
# if( scalar @ARGV > 0 ) {
#     $query = join( ' ' , @ARGV ) ;
#     # print( "\n\tquery:\t$query\n" );
# } 
my $q = $query ;


# proprocess query

$query =~ s/http(\S)*//g ;
$query =~ tr/[A-Z]/[a-z]/ ;
$query =~ tr/a-z/ /cs ;
my $output_file = $query ;
$output_file =~ tr/ /_/ ;
foreach my $stopword(@stopwords) {
    $stopword =~ s/\n//g ;
    my $re = qr/$stopword/ ;
    $query =~ s/ ${re} / /gs ;
}

# stem words

my @words = split( ' ' , $query ) ;
$stemmer->stem_in_place(@words) ;
$query = join( ' ' , @words ) ;

# print( "\n\tquery:\t$query\n" );

# calculate cosim with all documents each word is in & store in list -> order it

my $logN = log( 10000 ) ;
my %weight = () ;

my %query_tf = () ;
my $df ;
my $idf ;
my $query_length = 0 ;
my %docu_length = () ;

# calculate the score of each document - not normalised

foreach my $word(@words) {

    if( exists($query_tf{$word}) == 0 ){
        $query_tf{$word} = grep { $_ eq $word } @words ;
    }

    $df = scalar keys %{$r_index{$word}} ;
    if( $df != 0 ) {
        $idf = $logN - log($df) ;
    } else { $idf = $logN ; }
    $weight{$word} = $idf * $query_tf{$word} ;
    foreach my $link( keys %{$r_index{$word}} ) {
        if( exists($score{$link}) ){} else {
            $score{$link} = 0 ;
            $docu_length{$link} = 0 ;
        }
        $score{$link} += $weight{$word} * $idf * $r_index{$word}{$link} ;
        # no - add square of tfidf in that doc
        $docu_length{$link} += $idf*$idf*$r_index{$word}{$link}*$r_index{$word}{$link} ;
    } 
    $query_length += ( $weight{$word} * $weight{$word} ) ;

}


# map file-number to the page-link

my $url = "" ;
$file_content = read_file('file_url_index.txt') ;
@array_content = split('\n',$file_content) ;
foreach my $line(@array_content) {
    $line =~ s/\s/{/g ;
    $start_index = index($line,'{') ;
    $file = substr $line , 0 , $start_index ;
    $url{$file} = substr $line , $start_index +1 ;
}

# normalise the score of each document by its length and query length

$query_length = sqrt($query_length) ;
foreach my $link( keys %score ) {
    $docu_length{$link} = sqrt($docu_length{$link}) ;
    $score{$link} = $score{$link}/( $docu_length{$link} * $query_length ) ;
}

$ctr = 0 ;
my $output = "\n\n\t\tQUERY:\t$q\n\t\tstemmed:\t$query\n" ;
my $dl_rounded ;
my $sc_rounded ;
my $webpage_output = "<div width='80%'> <table width='80%' margin-left='50px' text-align='center'> <tr> <th>#</th> <th>page</th> <th>URL</th> <th>score</th> <th>length</th> </tr>" ;
foreach my $link( sort { $score{$b} <=> $score{$a} } keys %score ){
    $ctr++ ;
    if($ctr<=20) {
        # printf ( "\n\t$ctr\t$link\t$url{$link} @ %.2f | $docu_length{$link}" , $score{$link} ) ;
    }
    $sc_rounded = int($score{$link}*100) ;
    $dl_rounded = int($docu_length{$link}) ;
    $output = "$output\n\t$ctr\t$link\t$url{$link} @ $score{$link} | $docu_length{$link}" ;
    $webpage_output = "$webpage_output<tr> <th>$ctr</th> <th>$link</th> <th><a href='$url{$link}'>$url{$link}</a></th> <th>$sc_rounded</th> <th>$dl_rounded</th> </tr>" ;
} 

if( scalar %score == 0 ) {
    $webpage_output = "<div width='600px' text-align='center' padding-left='350px'><p padding-left='350px' margin='auto' text-align='center'><h1 padding-left='350px' margin='auto' text-align='center'>:'(</h1></p></div>" ;
}

$output_file = "search_results\\$output_file\.txt" ;

open( OUTPUT_STREAM , '>', $output_file )
  or die("can not open output file to print to it \n\n");

print OUTPUT_STREAM $output ;

close( OUTPUT_STREAM );

# make HTML page to serve results
print header,
start_html(-title=>"$q : search memphis.edu"),
h1($q),
"$webpage_output</table> </div>",
end_html;



# print the relevant links

#####

# make an HTML page

# make a form on it &  server
