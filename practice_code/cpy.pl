# perl script to input 2 filenames -> create the first file with sample text -> copy its contents to file#2 -> print file#2

use warnings;

use strict;

sub Copy {

    my $filename = $_[0];

    my $fileout = $_[1];

    # opening $filename and $fileout

    print "\t $filename created | opening $filename and $fileout \n\n";

    open( INFILE, '<', $filename ) or die("\t can not open input file \n\n");

    open( OUTFILE, '>', $fileout ) or die("\t can not open output file \n\n");

    # copying the contents of $filename to $fileout

    print "\t opened both | copying the contents of $filename to $fileout \n\n";

    while (<INFILE>) {

        print OUTFILE $_;

    }

    close(INFILE);

    close(OUTFILE);

}

my $str = <<END;    # sample text

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

Aliquam mollis aliquet tempus.

Curabitur nec molestie enim, et commodo tortor.

Quisque feugiat urna ligula, sit amet eleifend tortor pulvinar sit amet.

Nam nec condimentum lorem.

Pellentesque convallis, urna posuere venenatis vehicula, tellus lacus sollicitudin libero, lacinia egestas eros nisl sed mi.

Duis in mauris turpis.

Sed tristique mi nec sem gravida auctor.

Cras a sem nulla.

Sed consequat a purus at aliquet.

END

# getting filenames from input parameters

my $filename = shift @ARGV;

my $fileout = shift @ARGV;

# creating $filename with sample text

print "\n\n\t creating $filename with sample text \n\n";

open( MAKEFILE, '>', $filename ) or die("can not make new file \n\n");

print MAKEFILE $str;

close(MAKEFILE);

# copying the contents of $filename to $fileout

Copy( $filename, $fileout );

# displaying the contents of $fileout

print "\t copied | displaying the contents of $fileout \n\n";

open( RESULT, '<', $fileout )
  or die("can not open output file to print it \n\n");

while (<RESULT>) {

    print $_ ;

}

close(RESULT);

print "\n A SUCCESSFUL RUN ! :) \n\n";
