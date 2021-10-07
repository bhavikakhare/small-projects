# program to count #words in the course home-page & then count the frequency of each word :)

# by B KHARE

use warnings;

use strict;

use LWP::UserAgent;

use WWW::Mechanize;

use HTML::Strip;

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

my @links = @{$mech->find_all_links()};

# declare the hashes we will use

my %frequencies = ();

my %documents = ();

my $word ;
my @words ;

foreach my $link(@links) {

    unless ( $link->[0] =~ /^http?:\/\//i || $link->[0] =~ /^https?:\/\//i ) {

        $link->[0] = "$url" . $link->[0] ;
    
    }

    print "\n\t$link->[0]\n";

    crawl( \$link->[0] , \%frequencies , \%documents , \@words );

}

# now we print the words sorted

foreach $word ( sort keys %frequencies ) { # make sure this way to write sort works C

    # print sum of frequencies instead C
    # print document count

    my $sum = 0 ;
    foreach my $link(@links) {
        $sum = sum( fre , $sum );
    }
    print "\t $word \t\t $frequencies{$word} \n";

}

# function to crawl each link

sub crawl { 

    my ( $link , %frequencies , %documents , %words ) = @_ ;

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

        $documents{$word}{$link}++;

    }

}

