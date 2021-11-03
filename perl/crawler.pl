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
my @links ;

# make variable names meaningful and add comments and spaces

while( $docu_count<=$goal ) {

    # pick a url and mark it crawled
    $current_url = pop @documents ;
    $crawled{$current_url} = 1 ;
    # add all its links to document array if not crawled or already in docs
    my $temp = eval { 
        $mech->get($current_url);
        @link_objects = $mech->find_all_links();
    } ;
    if ($@) {
    # alert the error
        print "\n\t $@" ;
    }
    @links = uniq( map { $_->url } @link_objects ); # later remove this uniq -> it is already done later
    @links = grep {!((/\.ppt$/)|(/mailto/))}@links ;
    foreach my $link(@links) {
        unless ( $link =~ /^http?:\/\//i || $link =~ /^https?:\/\//i ) {
            $link = "$url" . $link ; # format links
        }
    }
    push( @documents , @links ) ;
    @documents = uniq @documents ;
    # used uniq instead of checking if already in docs to avoid a loop
    # get text & preprocess
    $docu_count += crawl( $current_url ) ;
    # figure out pdf to text
    # if enough words then save file & count++
    # save filename to table with url
}

# make sure crawl returns 1 and saves the file for ct>50

# function to crawl each link

sub crawl { 

    my $link = shift ;

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
    if( scalar @words >= 50 ) {
        return 1 ;
        # save to file
        print "$link+\n" ;
    }

    return 0 ;

}
