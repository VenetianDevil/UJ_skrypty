#!usr/bin/perl

use FindBin;
use lib "$FindBin::RealBin";

my $welcome = "
			Welcome to the game
	 __  __         _             __  __ _         _ 
	|  \\/  |__ _ __| |_ ___ _ _  |  \\/  (_)_ _  __| |
	| |\\/| / _` (_-<  _/ -_) '_| | |\\/| | | ' \\/ _` |
	|_|  |_\\__,_/__/\\__\\___|_|   |_|  |_|_|_||_\\__,_|
                                                 
";
print $welcome;

my($mode);

sub help(){
    my $help = "             
                             About the game

    This is a one-player game. The goal is to decifer a code which is
    a sequence of colors. After each attempt player gets feedback about
    how many parts of code were decifer correctly and how many are
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
    }elsif($arg =~ m/(easy|medium|hard)/){
        if($mode eq ""){
            $mode = $arg;
        }
    }else{
        print "Error: Unknown argument '", $arg, "'.\n\n";
        help();
        exit(1);
    }
}

if($mode eq ""){
    print "Error: Game mode is required.\n\n";
    help();
    exit(1);
}

print "MODE: ", $mode, "\n";

sub set_playsers {
	my ($sting) = @_;
  my @cp = split(/:/, $string);
  return $cp[1];
}

# my $player = new Player('a', $mode);
# my $computer = new Player('c', $mode);

my $board = `$FindBin::RealBin/engine.sh -0`;
my @board = split(/\n/, $board);
my $board = @board[0];
# print "game: $board \n";

my $the_game_is_on = 1;
my $round = 0;
my $win = 0;
my($try) = "";

sub print_board {
  my ($board) = @_;
  my @boards = split(/:/, $board);
  my $rounds=@boards[1];
  my $slots=@boards[2];
  $board = @boards[3];
  $board =~ s/,,/,_,/g;
  $board =~ s/,,/,_,/g;
  $board =~ s/^,/_,/g;
  $board =~ s/,$//g;
  my @board = split(/,/, $board);

  $feedback = @boards[4];
  $feedback =~ s/,,/,_,/g;
  $feedback =~ s/,,/,_,/g;
  $feedback =~ s/^,/_,/g;
  $feedback =~ s/,$//g;
  my @feedback = split(/,/, $feedback);

  # print "print board ", @board, "\n";
  my $blen = $rounds * $slots;
  for my $i (0..$blen) {  
    if ( $i > 0 && $i % $slots == 0 ) {
      print "| ";
      for my $j ($i-4..$i-1) {
        print $j, @feedback[$j];
        print " ";
      }
      print "\n"
    }
    print $board[$i], " ";
  }
  print "\n\n"
}

while ($round < 10 && $the_game_is_on){
    print "Guess the code: ";
    my $line = readline(STDIN);
    chomp($line);

    if(length($line)==4){
      $try = $line;
      $round = $round + 1;
      
      my $step = `$FindBin::RealBin/engine.sh -t $try $round -b $board`;
      # print "step: ", $step, "\n";
      my @step = split(/\n/, $step);
      $board = @step[0];
      my @win = split(/:/, @step[1]);
      $win = @win[1];

      print "125board ", $board, "\n";
      print_board($board);

      if ($win != 0){
        $the_game_is_on = 0;
      }

    }
    else{
      print "Error: try must have 4 chars"
    }
}

if ($win == 1){
  print "
  __   __         __      ___        _ 
  \\ \\ / /__ _  _  \\ \\    / (_)_ _   | |
   \\ V / _ \\ || |  \\ \\/\\/ /| | ' \\  |_|
    |_|\\___/\\_,_|   \\_/\\_/ |_|_||_| (_)
                                                 
";
}

if ($win == -1){
  print "
  __   __          _                  _ 
  \\ \\ / /__ _  _  | |   ___ ___ ___  | |
   \\ V / _ \\ || | | |__/ _ (_-</ -_) |_|
    |_|\\___/\\_,_| |____\\___/__/\\___| (_)
                                                 
";
}