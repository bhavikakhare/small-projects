# WAP2 preprocess text in input folder & remove stopwords from english_stopwords.txt BY B KHARE :)
use warnings;
use strict;
use HTML::Strip;
use File::Slurp;
use Lingua::Stem;

my $stemmer = Lingua::Stem->new( -locale => 'EN-UK' ) ;

# find the file of stopwords and store stopwords in a list 

my $folder = shift @ARGV;
my $stopwords_file = "$folder/english_stopwords.txt" ;
my @stopwords ;
my $file ;

open( STOPWORDS , '<', $stopwords_file )
  or die("can not open output file to print it \n\n");

while (<STOPWORDS>) {
    push( @stopwords , $_ );
}

close(STOPWORDS);

# fine & open & loop over all files in hw4 directory

my @files = <$folder/*.txt> ;
opendir(F, $folder) or die "could not open $folder\n" ;

foreach my $file (@files) {
# while ( $file = readdir(F) ) {

    next if( $file eq "$folder/english_stopwords.txt" ) ;

        # open( FILE , $file )
        #   or die("can not open \n\n") ;
        my $content = read_file($file) ;
        # my $request = new HTTP::Request( 'GET', $link );
        # my $response = $ua->request($request);
        # # extract HTML content
        # my $content = $response->content();
        # die "\t Couldn't get content ! :( \n\n" unless defined $content;

        # strip the HTML tags from it to get pure text
        my $hs = HTML::Strip->new() ;
        my $text = $hs->parse($content) ;
        $hs->eof;

        # for each file with text $text
        $text =~ s/http(\S)*//g ;
        $text =~ tr/[A-Z]/[a-z]/ ;
        $text =~ tr/a-z/ /cs ;
        # for each word $stopword
        # my $stopword = "to" ;
        # @stopwords = ("to","a","is") ;
        foreach my $stopword(@stopwords) {
            $stopword =~ s/\n//g ;
            my $re = qr/$stopword/ ;
            $text =~ s/ ${re} / /gs ;
            # print "aa$stopword bb" ;
        }

        # stem words
        my @words = split( ' ', $text ) ;
        $stemmer->stem_in_place(@words) ;
        $text = join( ' ' , @words ) ;

        # save the preprocessed text in hw5_input directory
        $file = substr $file , 4 ;
        open( FILEOUT , '>', "hw5_input/$file.txt" )
            or die("can not open output $file to print it \n\n");
        print FILEOUT "$text" ;

}

closedir(F);
close(FILEOUT);
