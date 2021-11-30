# script to return ranked list of query results for a given query
  use strict;
  use warnings;
  use File::Slurp;
  use Lingua::Stem;
  use Math::Complex;
  use CGI ':standard';

# read RI file into matrix or sth

my %r_index = () ;
# open FILE, "reverse_index.txt" or die $! ;
my $key ;
my $df ;
my %df_map = () ;
my $df_start_index ;
my $df_end_index ;
my $start_index ;
my $end_index ;
my $tf_string ;
my @hash_values ;
my $ctr = 0 ;
my $file_content = read_file('reverse_index.txt') ;
my @array_content = split('\n',$file_content) ;
my %url = () ;
my %score = () ;
my $file ;

my $stemmer = Lingua::Stem->new( -locale => 'EN-UK' ) ;

my $stopwords_file = "HW4/english_stopwords.txt" ;
my @stopwords ;

open( STOPWORDS , '<', $stopwords_file )
  or die("can not open output file to print it \n\n");

while (<STOPWORDS>) {
    push( @stopwords , $_ );
}

close(STOPWORDS);

foreach my $line(@array_content) {
    $line =~ s/\s+//g ;
    # chomp($line);
    # chomp($line);
    # if( $ctr < 3 ) {
    #   print("\n$line\n\n");
    #   $ctr=$ctr+1 ; 
    # }
    $df_start_index = index( $line , '(' ) ;
    $df_end_index = index( $line , ')' ) ;
    # if($start_index==-1 & $ctr<3) {
    #     my $tab = substr($line, 1, 1);
    #     print("\n\ntab$tab tab\n\n");
    #     $ctr =$ctr +1 ;
    # }
    $key = substr $line , 0 , $df_start_index ;
    # my ($key) = $line =~ /^(.*?)\s/;
    # if( $ctr < 3 ) {
    #   print("\n$start_index x $line") ; 
    #   $ctr=$ctr+1 ; 
    # }
    $df = substr $line , $df_start_index+1 , $df_end_index-$df_start_index -1 ;
    $df_map{$key} = $df ;
    # if( $ctr < 2 ) {
    #   # print("\n $line") ; 
    #   $ctr=$ctr+1 ; 
    # }
    $start_index = index($line,'{') ;
    $end_index = index($line,'}') ;
    $tf_string = substr $line , $start_index +1 , $end_index-$start_index -1 ;
    # $tf_string =~ s/\s+//g ;
    @hash_values = split(';',$tf_string) ;
    foreach my $hash_value( @hash_values ) {
        $start_index = index($hash_value,':') ;
        # $end_index = length($hash_value) ;
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
# close FILE;

# ask for query

my $query ;
$query = param("query");

# if( scalar @ARGV > 0 ) {
#     $query = join( ' ' , @ARGV ) ;
#     print("\n\n\tquery:\t$query");
# } 

# proprocess query

    # for each file with text $text
    $query =~ s/http(\S)*//g ;
    $query =~ tr/[A-Z]/[a-z]/ ;
    $query =~ tr/a-z/ /cs ;
    # for each word $stopword
    # my $stopword = "to" ;
    # @stopwords = ("to","a","is") ;
    foreach my $stopword(@stopwords) {
        $stopword =~ s/\n//g ;
        my $re = qr/$stopword/ ;
        $query =~ s/ ${re} / /gs ;
        # print "aa $stopword bb" ;
    }

    # stem words
    my @words = split( ' ' , $query ) ;
    $stemmer->stem_in_place(@words) ;
    $query = join( ' ' , @words ) ;

# print("\n\n\tquery:\t$query");

# calculate cosim with all documents each word is in & store in list -> order it

my $logN = log( scalar @array_content ) ;
# my $logN = log( 10000 ) ;

my %weight = () ;
my $count ;

my %query_tf = () ;
foreach my $word(@words) {
    $count = 0 ;
    $count = grep { $_ eq $word } @words ;
    $query_tf{$word} = $count ;
    my @arr1 = () ;
    foreach my $w(@words){
            push @arr1, $w if !grep{$_ eq $word}@arr1;
    }
    push @arr1, $word;
    @words = @arr1 ;

    if(exists($df_map{$word})) { 
        my $idf = $logN - log($df_map{$word}) ;
        $weight{$word} = $idf*$count ;
        foreach my $link(keys %{$r_index{$word}}) {
            if(exists($score{$link})){} else {
                $score{$link} = 0 ;
            }
            $score{$link} += $weight{$word}*$idf*$r_index{$word}{$link} ;
        } 
    } else {
    }
}

my %docu_length = () ;
my %counted = () ;
# my $count ;

# trash code here
    # foreach my $word(@words) {
    #     $count = 0 ;
    #     if( exists $counted{$word} ){} else {
    #         $count = grep { $_ eq $word } @words ;
    #         $docu_length{$file} += $count*$count ;
    #     }
    #     $counted{$word} = 1 ;
    # }
    # $docu_length{$file} = int(sqrt($docu_length{$file})) ;

    # $file_name = $file ;
    # if ( $file =~ /_(\d*)\.txt$/ ) { $file_name = $1 ; }

    # print FILE_LENGTH "$file_name\t:\t$docu_length{$file}\n" ;
    # # print FILE_LENGTH "$file_name\t:\t$count\n"

# map file-number to the page-link
my $url = "" ;
$file_content = read_file('HW6/old3/file_url_index.txt') ;
@array_content = split('\n',$file_content) ;
foreach my $line(@array_content) {
    $line =~ s/\s/{/g ;
    $start_index = index($line,'{') ;
    $file = substr $line , 0 , $start_index ;
    $url{$file} = substr $line , $start_index +1 ;
}


foreach my $link( keys %score ) {
    $docu_length{$link} = 0 ;
    foreach my $word( @words ) {
        $docu_length{$link} += $weight{$word}*$weight{$word} ;
    }
    $docu_length{$link} = int(sqrt($docu_length{$link})) ;
    $score{$link} = $score{$link}/$docu_length{$link} ;
}

$ctr = 0 ;
my $output = "" ;
foreach my $link(sort { $score{$b} <=> $score{$a} } keys %score) {
    $ctr++ ;
    if($ctr<=20) {
        # print ("\n\t $url{$link} @\t$score{$link}") ;
        $output = "$output\n\t $url{$link} @\t$score{$link}" ;
    }
}

print header,
start_html(-title=>"hi"),
h3 p($output),
end_html;



# print the relevant links

#####

# make an HTML page

# make a form on it &  server
