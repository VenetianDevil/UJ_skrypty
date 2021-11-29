package Board;

use FindBin;
use Term::ANSIColor;

sub new {
    my $class = shift;
    my $self = {
    _rounds => shift,
    _slots => shift,
    };

    bless $self, $class;
    return $self;
}

sub print_board {
  my ($self, $game) = @_;
  my @data = split(/:/, $game);
  my $board = @data[3];
  $board =~ s/,,/,_,/g;
  $board =~ s/,,/,_,/g;
  $board =~ s/^,/_,/g;
  $board =~ s/,$//g;
  my @board = split(/,/, $board);

  my $feedback = @data[4];
  $feedback =~ s/,,/, ,/g;
  $feedback =~ s/,,/, ,/g;
  $feedback =~ s/^,/ ,/g;
  $feedback =~ s/,$//g;
  my @feedback = split(/,/, $feedback);

  # print "print board ", @board, "\n";
  my $blen = $self->{_rounds} * $self->{_slots};
  print "\n";
  for my $i (0..$blen) {  
    if ( $i > 0 && $i % $self->{_slots} == 0 ) {
      print "| ";
      for my $j ($i-4..$i-1) {
        # print $j, @feedback[$j];
        print @feedback[$j];
        print " ";
      }
      print "\n";
    }

    my $color = "";
    if( $board[$i] eq "r" ) {$color = "red"}
    elsif ( $board[$i] eq "y" ) {$color = "yellow"}
    elsif( $board[$i] eq "b" ) {$color = "blue"}
    elsif( $board[$i] eq "g" ) {$color = "green"}
    elsif( $board[$i] eq "p" ) {$color = "magenta"};

    if ($color){
      print colored([$color], "@"), " ";
    } else {
      print $board[$i], " ";
    }
  }
  print "\n\n"
}

1
