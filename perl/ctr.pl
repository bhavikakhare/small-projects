# program to count #words in the course home-page & then count the frequency of each word :)

# by B KHARE

use warnings;

use strict;

use LWP::UserAgent;

use HTML::Strip;

# get the webpage

my $ua = new LWP::UserAgent;

$ua->timeout(120);

my $url = 'https://www.cs.memphis.edu/~vrus/teaching/ir-websearch/';

my $request = new HTTP::Request( 'GET', $url );

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

# declare the hashes we will use

my %index;

my %frequency;

my $word;

# word count !

my $ct = scalar @words;

print "\n\t This page has $ct words ! \n";

# to count frequencies

my $nwords = 0;

# process each word...

while ( $word = pop @words ) {

    # if it's unknown assign a new index

    if ( !exists( $index{$word} ) ) {

        $index{$word} = $nwords++;

    }

    # always update the frequency

    $frequency{$word}++;

}

# now we print the words sorted

foreach $word ( sort keys %index ) {

    print "\t $word \t\t $frequency{$word} \n";

}
