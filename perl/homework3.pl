# program to count #words in the course home-page & then count the frequency of each word :)

# by B KHARE

use warnings;

use strict;

use LWP::UserAgent;

use WWW::Mechanize;

use HTML::Strip;

use List::MoreUtils qw/uniq/; # to change mechanise link objects to array of urls

#use Text::FromAny;

# get the webpage

my $ua = new LWP::UserAgent;

$ua->timeout(120);

my $url = 'https://www.cs.memphis.edu/~vrus/teaching/ir-websearch/';

# my $request = new HTTP::Request( 'GET', $url );

# my $response = $ua->request($request);

# get links from webpage & store in LinkedList

my $mech = WWW::Mechanize->new();

$mech->get($url);

my @link_objects = $mech->find_all_links();

my @links = uniq( map { $_->url } @link_objects );

# declare the hashes we will use

my %frequencies = ();

my %documents = ();

my $word ;
# my @words ;

# get the links in the right format and remove presentations or emailIDs

@links = grep {!/\.edu|\.ppt|\.txt|.pdf/}@links ; 

foreach my $link(@links) {

    unless ( $link =~ /^http?:\/\//i || $link =~ /^https?:\/\//i ) {

        $link = "$url" . $link ;
    
    }

    print "\n\t$link\n";

    crawl( $link , \%frequencies );

}

my $ct = scalar %frequencies ;

print "\nreturned + $ct" ;

# now we print the words sorted

foreach $word ( sort keys %frequencies ) { # make sure this way to write sort works C

    print "\nlooping" ;

    # print document count

    my $sum = 0 ;
    my $size = 0 ;
    foreach my $link(@links) { # do i need to check if $f($w) is an existing hash ?
        $sum = sum( $frequencies{$word}{$link} , $sum );
        if($frequencies{$word}{$link}>0) {
            $size = $size +1 ;
        }
    }
    # $size = keys $frequencies{$word} ;
    print "\t $word \t\t $sum\t $size \n";

}

# function to crawl each link

sub crawl { 

    # my ( $link , $frequencies , $words ) = @_ ;
    # %frequencies = %{$frequencies};
    # @words = @{$words};

    my $link = shift ;
    my $frequencies = shift ;
    print scalar "\n%frequencies" ;
    my %frequencies = %{$frequencies} ;
    # my $words = shift ;
    # my @words = @{$words} ;

    print "\non $link with $frequencies :)" ;
    
    # my $ct = scalar %frequencies ;

    # print "\ncrawling + $ct" ;

    # if pdf

    # if $link =~ m/pdf/ {

    #     my $tFromAny = Text::FromAny->new(
    #     file => $link );
    #     my $text = $tFromAny->text, "\n";

    # }

    # get content

    my $request = new HTTP::Request( 'GET', $link );

    my $response = $ua->request($request);

    # extract HTML content

    my $content = $response->content();

    die "\t Couldn't get content ! :( \n\n" unless defined $content;

    # strip the HTML tags from it to get pure text

    my $hs = HTML::Strip->new();

    my $page_text = $hs->parse($content);

    $hs->eof;

    # make everything lowercase

    $page_text =~ tr/[A-Z]/[a-z]/;

    # replace everything but alphabets to |n AND remove multiple consecutive occurrences of \n :)

    $page_text =~ tr/a-z/\n/cs;

    # split this string of many words into an array of words

    my @words = split( '\n', $page_text );

    my $word;

    # to count frequencies

    my $nwords = 0;

    # process each word...

    while ( $word = pop @words ) {

        # add to that document frequency C
        if(exists($frequencies{$word})){
            $frequencies{$word}{$link}++ ;
        } else {
            my %f = () ;
            $frequencies{$word} = \%f ;
            $frequencies{$word}{$link} =1 ;
        }

        # print "$word + $frequencies{$word}{$link} + $link\n" ;

    }

    $ct = scalar %frequencies ;

    print "\nreturning + $ct" ;

    return;

}
