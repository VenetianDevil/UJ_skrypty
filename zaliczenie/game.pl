#!usr/bin/perl

sub help(){
    my $help = "             
                             About the game

This is a one-player game. The goal is to decifer a code which is
a sequence of colors. After each attempt player gets feedback about
how many parts of code were decifer correctly and which are
misplaced.
Meanwhile computer will play this same set of game and at the end
will compare if you did better (in less moves).

To start a game run the following command with proper arguments:

$0 LEVEL

where LEVEL can be one of following strings:
    easy
    medium
    hard

-------------------------------------------------------

general script usage:
$0 [-h] LEVEL
optional arguments:
    -h, --help          show this help message and exit
";
    print $help, "\n";
}

while(scalar @ARGV gt 0){
    my $arg = shift;
    if($arg eq "-h" || $arg eq "--help"){
        help();
        exit(0);
    }else{
        print "Error: Unknown argument '", $arg, "'.\n\n";
        help();
        exit(1);
    }
}
