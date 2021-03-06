#!/usr/bin/perl

use FindBin;
use Term::ANSIColor;
use lib "$FindBin::RealBin";
use Board;

my $welcome = "
			Welcome to the game
	 __  __         _             __  __ _         _ 
	|  \\/  |__ _ __| |_ ___ _ _  |  \\/  (_)_ _  __| |
	| |\\/| / _` (_-<  _/ -_) '_| | |\\/| | | ' \\/ _` |
	|_|  |_\\__,_/__/\\__\\___|_|   |_|  |_|_|_||_\\__,_|
                                                 
";
my $legend = "
	    
      Legend:
      + - hit (you guessed one part correctly)
      o - miss (you guessed one part correctly, but misplaced it)

";
print $welcome;

my $scoreboard;

sub help(){
    my $help = "             
                             About the game

    This is a one-player game. The goal is to decifer a code which is
    a sequence of colors. After each attempt player gets feedback about
    how many parts of the code were decifer correctly and how many were
    misplaced:
    + - hit (you guessed one part correctly)
    o - miss (you guessed one part correctly, but misplaced it)
    There are 5 available colors (red, yellow, blue, green, purple).
    The code consists of 4 colors, selected randomly from the 5 available
    and they can repeat themselves; for example it's possible that 
    the code consists of only red color: {red red red red}.

    After game, if you win and decide to save your score, the game will
    show you a scoreboard of 10 records in total, marking yours in it.
    To see full scoreboard run: $0 -s

    -------------------------------------------------------

    general script usage:
    $0 [-h] [-s]
    optional arguments:
        -h, --help          show this help message and exit
        -s, --scoreboard    show full scoreboard
    ";
    print $help, "\n";
}

while(scalar @ARGV gt 0){
    my $arg = shift;
    if($arg eq "-h" || $arg eq "--help"){
        help();
        exit(0);
    }
    elsif($arg eq "-s" || $arg eq "--scoreboard"){
      $scoreboard = `$FindBin::RealBin/records.py -p`;
      print_scoreboard();
      exit(0);
    }else{
        print "Error: Unknown argument '", $arg, "'.\n\n";
        help();
        exit(1);
    }
}

# if($mode eq ""){
#     print "Error: Game mode is required.\n\n";
#     help();
#     exit(1);
# }

# print "MODE: ", $mode, "\n";

my $game = `$FindBin::RealBin/engine.sh -0`;
my @game = split(/\n/, $game);
my $game = @game[0];
my @data = split(/:/, $game);

my $round = 0;
my $rounds=@data[1];
my $slots=@data[2];
my $code = @data[5];

my $board = new Board($rounds, $slots);

sub print_code {
  my @code = split(/,/, $code);

  my $color = "";
  print "Code: ";
  foreach (@code){
    if( $_ eq "r" ) {$color = "red"}
    elsif ( $_ eq "y" ) {$color = "yellow"}
    elsif( $_ eq "b" ) {$color = "blue"}
    elsif( $_ eq "g" ) {$color = "green"}
    elsif( $_ eq "p" ) {$color = "magenta"};

    print colored([$color], "@"), " ";

  }
  print "\n"
}

sub is_try_valid {
  my ($try) = @_;
  my @try = split(//, $try);
  my @colors=("r", "y", "b", "g", "p");

  if(length($try)!=$slots){
    print "Error: your guess must consists of 4 chars (do not use spaces) \n";
    return 0;
  }
  # my $valid = 1;
  foreach (@try){
    # print $_;
    my $one_try = $_;
    if (!(grep { $_ eq $one_try } @colors)){
      print "Error: you used symbols that does not match any of the available colors \n";
      return 0;
      # $valid = 0;;
      # break;
    }
  }

  return 1;
}

my $the_game_is_on = 1;
my $win = 0;
my($try) = "";

# print_code();
print $legend;
$board->print_board($game);

$btime = time;
while ($round < 10 && $the_game_is_on){
  print "Guess the code (r=", colored(["red"], "@"), " y=", colored(["yellow"], "@"), , " b=", colored(["blue"], "@"), " g=", colored(["green"], "@"), " p=", colored(["magenta"], "@"), "):";
  my $try = readline(STDIN);
  chomp($try);

  my $validTry = is_try_valid($try);
  if( $validTry ){
    $round = $round + 1;
    
    my $step = `$FindBin::RealBin/engine.sh -t $try $round -g $game`;
    # print "step: ", $step, "\n";
    my @step = split(/\n/, $step);
    $game = @step[0];
    my @win = split(/:/, @step[1]);
    $win = @win[1];

    # print "156 \$board ", $board, "\n";
    # print "157 display ", $step, "\n";

    $board->print_board($game);
    if ($win != 0){
      $the_game_is_on = 0;
    }
  }
}
$etime = time;
$elapse = $etime - $btime;

print_code();

sub save_score {
  print "Write your nick: ";
  my $nick = readline(STDIN);
  chomp($nick);
  $nick =~ s/ /_/g;
  $scoreboard = `$FindBin::RealBin/records.py -s $nick $round $elapse -p`;

  print_scoreboard();
}

sub print_scoreboard {
  @scoreboard = split(/\n/, $scoreboard);
  foreach (@scoreboard) {
    my @score = split(/ /, $_);
    if (@score[-1] eq "new") {
      print colored(["red"], $_), "\n";
    } else {
      print $_, "\n"
    }
  }
}

if ($win == 1){
  print "Rounds: ", $round, "\n";
  print "Time: ", $elapse, "s\n";

  print "
  __   __         __      ___        _ 
  \\ \\ / /__ _  _  \\ \\    / (_)_ _   | |
   \\ V / _ \\ || |  \\ \\/\\/ /| | ' \\  |_|
    |_|\\___/\\_,_|   \\_/\\_/ |_|_||_| (_)
                                                 
";

  print "Do you want to save your score? (Yes): ";
  my $save = readline(STDIN);
  chomp($save);
  if($save eq "Yes" || $save eq "yes" || $save eq "y" || $save eq "Y"){
    save_score();
  }
  
}

if ($win == -1){
  print "
  __   __          _                  _ 
  \\ \\ / /__ _  _  | |   ___ ___ ___  | |
   \\ V / _ \\ || | | |__/ _ (_-</ -_) |_|
    |_|\\___/\\_,_| |____\\___/__/\\___| (_)
                                                 
";
}

exit;