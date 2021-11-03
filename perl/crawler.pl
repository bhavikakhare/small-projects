use warnings;
use strict;

use LWP::UserAgent;
use WWW::Mechanize;
use HTML::Strip;
use List::MoreUtils qw/uniq/; # to change mechanise link objects to array of urls


# get the webpage

my $ua = new LWP::UserAgent;
$ua->timeout(120);

my $url = 'https://www.cs.memphis.edu/~vrus/teaching/ir-websearch/';

# get links from webpage & store in LinkedList

my $mech = WWW::Mechanize->new();
# $mech->get($url);

my $docu_count = 0 ;
my $goal = 5 ;
my @documents = ( $url ) ;
my %crawled ;
my $current_url ;
my @link_objects ;
my @links_onpage ;
my $stopper = 5 ;

# make variable names meaningful and add comments and spaces

# while( $docu_count<=$goal && $stopper > 0 ) {
while( $docu_count<=$goal ) {

    $stopper--; 

    # pick a url and mark it crawled
    $current_url = pop @documents ;
    print "\ncurrent $current_url\n" ;
    $crawled{$current_url} = 1 ;

    # add all its links to document array if not crawled or already in docs
    my $temp = eval { 
        $mech->get($current_url);
        @link_objects = $mech->find_all_links();
        @links_onpage = uniq( map { $_->url } @link_objects ); # later remove this uniq -> it is already done later
        @links_onpage = grep {!((/\.ppt$/)|(/mailto/))}@links_onpage ;
    } ;
    if($@) { 
        print "\t error $@" ; 
        @link_objects = () ;
        @links_onpage = () ;
    }
    foreach my $link(@links_onpage) {
        unless ( $link =~ /^http?:\/\//i || $link =~ /^https?:\/\//i ) {
            $link = "$url" . $link ; # format links
        }
    }
    my $ct1 = scalar @documents ;
    my $ct2 = scalar @links_onpage ;
    print "q-size = $ct1 + $ct2\n" ;
    push( @documents , @links_onpage ) ;
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
    print "crawling $link\n" ;

    # if pdf - i could not code this yet

    # if ( $link =~ m/pdf/ ) { # add else

    #     return 0 ;

    # }

    # get content

    # } else {

        my $request = new HTTP::Request( 'GET', $link );
        my $response = $ua->request($request);
        # extract HTML content
        my $content = $response->content();
        die "\t Couldn't get content ! :( \n\n" unless defined $content;
        # strip the HTML tags from it to get pure text
        my $hs = HTML::Strip->new();
        my $page_text = $hs->parse($content);
        $hs->eof;

    # }

    # make everything lowercase
    $page_text =~ tr/[A-Z]/[a-z]/;

    # replace everything but alphabets to |n AND remove multiple consecutive occurrences of \n :)
    $page_text =~ tr/a-z/\n/cs;

    # split this string of many words into an array of words
    my @words = split( '\n', $page_text );
    $count = scalar @words ;
    if( $count >= 50 ) {
        print "VALID: #word: $count\n" ;
        # save to file
        $docu_count++ ;
        open( FILEOUT , '>', "hw6_output_text/text_$docu_count.txt" )
            or die("can not open output file for text_$docu_count to print it \n\n");
        print FILEOUT "$page_text" ;
        print "$link+\n" ;
        open( FILEINDEX , '>>', "file_url_index.txt" )
            or die("can not open output file for file_url_index.txt to print it \n\n");
        print FILEINDEX "$docu_count\t$link\n" ;
        return 1 ;
    } else {
        print "INVALID: #word: $count\n" ;
    }

    return 0 ;

    # text file \n to space

    # figure out pdf to text

    # if enough words then save file & count++
    # save filename to table with url

}
