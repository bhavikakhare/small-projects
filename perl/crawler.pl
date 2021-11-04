# program to crawl the UoM homepage and collect 10000 pages with >50 words and save their text and preprocessed versions
# create a hw6_output_text folder 
# run with "perl crawler.pl"

use warnings;
use strict;

use LWP::UserAgent;
use LWP::Simple;
use WWW::Mechanize;
use HTML::Strip;
use File::Slurp;
use URI;
my $ua = new LWP::UserAgent;
use List::MoreUtils qw/uniq/; # to change mechanise link objects to array of urls

$ua->timeout(120);

my $url = 'https://www.cs.memphis.edu/~vrus/teaching/ir-websearch/';

# get links from webpage & store in LinkedList

my $mech = WWW::Mechanize->new();
# $mech->get($url);

my $docu_count = 0 ;
my $goal = 10000 ;
my @documents = ( $url ) ;
my %crawled ;
my $current_url ;
my @link_objects ;
my @links_onpage ;
# my $stopper = 100 ;

# make variable names meaningful and add comments and spaces
        # open( ERRORREPORT , '>>', "crawl_error_report.txt" )
        #     or die("can not open output file for crawl_error_report.txt to print it \n\n");
open STDOUT,'>','error_report.txt' or die "can't open output" ;

# while( $docu_count<$goal && $stopper > 0 ) { $stopper--; 
while( $docu_count<$goal ) {

    # pick a url and mark it crawled
    $current_url = shift @documents ;
    if( exists($crawled{$current_url}) && $crawled{$current_url} == 1 ) { next ; }
    print "\ncurrent $current_url\n" ;
    $crawled{$current_url} = 1 ;

    # add all its links to document array if not crawled or already in docs
    my $temp = eval { 
        $mech->get($current_url);
        @link_objects = $mech->find_all_links();
        @links_onpage = uniq( map { $_->url } @link_objects ); # later remove this uniq -> it is already done later
        @links_onpage = grep {!((/\.ppt$/)|(/\.js$/)|(/\.css$/)|(/\.json$/)|(/mailto/))}@links_onpage ;
        # @links_onpage = grep {(m/html$/)|(m/pdf$/)|(m/txt$/)|(m/php$/)}@links_onpage ;
    } ;
    if($@) { 
        print "\t error $@" ; 
        # print ERRORREPORT "\t couldn't get links from $current_url error $@\n\n" ;
        # skip this link or continue or sth
        @link_objects = () ;
        @links_onpage = () ;
        next;
    }
    my $ct1 = scalar @documents ;
    # my $ct2 = scalar @links_onpage ;
    print "q-size : $ct1 " ;
    foreach my $link(@links_onpage) {
        unless ( $link =~ /^http?:\/\//i || $link =~ /^https?:\/\//i ) {
            $link = URI->new_abs( $link , $current_url ) ;
        }
        if ( exists($crawled{$link}) && $crawled{$link} == 1 ) { next ; }
        else { push( @documents , $link ) ; }
    }
    my $ct2 = scalar @documents ;
    $ct2 = $ct2 - $ct1 ;
    print "+ $ct2\n" ;
    # push( @documents , @links_onpage ) ;
    @documents = uniq @documents ;
    # used uniq instead of checking if already in docs to avoid a loop

    # get text & preprocess
    $docu_count += crawl( $current_url , $docu_count ) ;
    print "docu_count is $docu_count\n" ;

}

# make sure crawl returns 1 and saves the file for ct>50

# function to crawl each link

sub crawl { 

    my $count ;

    my $link = shift ;
    my $docu_count = shift ;
    my $page_text ;
    print "crawling ... ... ... ...\n" ;

    # if pdf - i could not code this yet

    if ( $link =~ m/pdf$/ ) {
        
        # getstore( "pdf_file.pdf" , $link );
        my $mech = WWW::Mechanize->new;
        $mech->get( $link, ":content_file" => "pdf_file.pdf" );
        system q[ pdftotext.exe "pdf_file.pdf" ] ;
        $page_text = read_file("pdf_file.txt") ;
        unlink "pdf_file.pdf" ;
        unlink "pdf_file.txt" ;

    } else {

        my $request = new HTTP::Request( 'GET', $link );
        my $response = $ua->request($request);
        # extract HTML content
        my $content = $response->content();
        die "\t Couldn't get content ! :( \n\n" unless defined $content;
        # strip the HTML tags from it to get pure text
        my $hs = HTML::Strip->new();
        $page_text = $hs->parse($content);
        $hs->eof;

    }

    # make everything lowercase
    $page_text =~ tr/[A-Z]/[a-z]/;

    # replace everything but alphabets to |n AND remove multiple consecutive occurrences of \n :)
    $page_text =~ tr/a-z/ /cs;

    # split this string of many words into an array of words
    my @words = split( ' ', $page_text );
    $count = scalar @words ;
    if( $count >= 50 ) {
        print "VALID: #word: $count\n" ;
        # save to file
        $docu_count++ ;
        open( FILEOUT , '>', "hw6_output_text/text_$docu_count.txt" )
            or die("can not open output file for text_$docu_count to print it \n\n");
        print FILEOUT "$page_text" ;
        print "$link\n" ;
        open( FILEINDEX , '>>', "file_url_index.txt" )
            or die("can not open output file for file_url_index.txt to print it \n\n");
        print FILEINDEX "$docu_count\n" ;
        return 1 ;
    } else {
        print "INVALID: #word:$count<50\n" ;
        # print ERRORREPORT "INVALID: #word:$count<50\t$link\n\n" ;
    }

    return 0 ;

    # figure out pdf to text

}
