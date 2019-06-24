#!/usr/bin/env perl
# 
# Filename: StartGame.pl
# Author: Chakravarthy Marella
# Copyright (C) 2011 Chakravarthy Marella, all rights reserved.
# First Created: Nov 11 , 2011
# Code:

use strict;
use warnings;

print "\nChoose an integer between 1 to 3\n1 -> Easy, 2 -> Medium, 3 -> Hard : ";  
my $hard = <stdin>; if ($hard =~ m/^\d{1}$/){chomp($hard);}else {die "Wrong Choice.. game ends\n";}

my $initial_state=&initial_state;

my $u=0;
my @matrix = @{$initial_state};

while ($u==0){
	($u,$_)= &run(\@matrix);
	@matrix = @{$_};
}

my $matrix = \@matrix;
my ($x,$y,$z) = &scores($matrix);
$y = int($y);
if ($x < 1) {print "You won !! ($z:$y)\n\n";}
else {print "computer won !! ($y:$z)\n\n";}

if ($z<5) {print "\nThat was brilliant\n\n";}

####

sub run {
	my $my_matrix = &array_copy($_[0]);
	my @my_matrix = @{$my_matrix};my ($u,$o);

	($u,$o)=&game(\@my_matrix);
	@my_matrix = @{$o};
	return ($u,\@my_matrix);
}

sub game {

	my $my_matrix = &array_copy($_[0]);
	my @my_matrix = @{$my_matrix};

	my $returned_game_state;
	my ($v,$w,$x,$legal_moves);

	($legal_moves,$x) = &legal_moves(1,\@my_matrix);
	$_ = @{$legal_moves}; 
	if ($_ != 0) {
		$v=1;	
		$returned_game_state = &player(\@my_matrix,$legal_moves);
		@my_matrix = @{$returned_game_state};	
	}
	else {$v=0;print "Sorry, you don't have any moves. Press <return> to pass : ";<stdin>;}
	
	$_=&end_game(\@my_matrix);
	if ($_==1){ return 1,\@my_matrix;}

	($legal_moves,$x) = &legal_moves(2,$returned_game_state);
	$_ = @{$legal_moves}; 
	if ($_ != 0) {
		$w=1;
		$returned_game_state = &computer($returned_game_state,$legal_moves);
		@my_matrix = @{$returned_game_state};	
	}
	else {$w=0;print "Oops, computer doesn't have any moves.";}

	if ($v=$w=0) {return 1,\@my_matrix;}	
	else {		
		$_=&end_game(\@my_matrix);
		if ($_==1){ my @o=();return 1,\@my_matrix;}
	}
	return (0,\@my_matrix);
}

sub player {
	my $game_sub_state = $_[0];
	my $inherited_legal_moves = $_[1];
	print "\nyour choice : ";
	my $user_choice = <stdin>;chomp($user_choice);
	($_,$user_choice) = &check_if_user_choice_is_legal($user_choice, $inherited_legal_moves);

	if ($_ == 0) {
		my $dummy_play_or_real = 1; my $player =1;
		$game_sub_state = &play($player,$user_choice, $game_sub_state,$dummy_play_or_real);
		&print_matrix($game_sub_state);
		return $game_sub_state;
	}
	elsif ($_ == 1) {
		my $legal_moves = &convert_num_to_alphabet($inherited_legal_moves);
		print "\nIllegal choice... legal moves are ";
		print join(",",@{$legal_moves});
		&player($game_sub_state,$inherited_legal_moves);
	}
}

sub check_if_user_choice_is_legal {


	my $user_choice = $_[0];
	my @legal_moves = @{$_[1]};
	my @A = ('a','b','c','d','e','f','g','h');
	my @nums = (0..7);
	my $first_char = substr ($user_choice,0,1);if (($user_choice !~ m/^.{2}$/) or ($first_char !~ m/^\w$/)){return 1;}
 	my ($move,$c,$num);
	
	for ($c=0;$c<=7;$c++){		
		if ($first_char =~ m/^$A[$c]$/){
			$num=$c; $c=9;
		} 
	}
	if ($c==8) {return 1;}
	$user_choice = "$nums[$num]".substr($user_choice,1,1);
	foreach  $move (@legal_moves) {
		if ($move =~ /^$user_choice$/) { return 0,$user_choice;}
	}
	return 1;
}

sub computer {

	my $game_sub_state=$_[0];
	my $dummy_play_or_real = 1;
	my $legal_moves = $_[1];

	my $copied_array = &array_copy($game_sub_state);
	my @inherited_game_sub_state = @{$copied_array};

	my ($move_to_play,$x,$y)=&game_tree(0,$game_sub_state,$legal_moves);

	$game_sub_state=&play(2,$move_to_play,\@inherited_game_sub_state,$dummy_play_or_real);
	$move_to_play = convert_num_to_alphabet($move_to_play);
	print "Computer played  $move_to_play\n";

	&print_matrix($game_sub_state);
	return $game_sub_state;
}

sub game_tree {	

	my $depth=$_[0];
	$depth++;
	my $inherited_game_sub_state = $_[1];
	my $legal_moves = $_[2];

	my $copied_array = &array_copy($inherited_game_sub_state);
	my @inherited_game_sub_state = @{$copied_array};

	my $my_matrix = &array_copy($inherited_game_sub_state);
	my @my_matrix = @{$my_matrix};

	my($best_move,$best_score);

	$_ = &even_or_odd($depth);
	if ($_==2) {
		($best_move,$best_score)=&make_a_move(1,$depth,\@my_matrix,$legal_moves);# Makes move for player
	}
	else {	
		($best_move,$best_score)=&make_a_move(2,$depth,\@my_matrix,$legal_moves);# Makes move for computer
	}
	return ($best_move,$best_score,\@inherited_game_sub_state);
}

sub make_a_move {

	my $player = $_[0]; 	#@my_matrix = @{$returned_game_state};	

	my $depth=$_[1]; 
	my $inherited_game_sub_state = $_[2];
	my $legal_moves = $_[3];

	my $dummy_play_or_real = 1 ;
	my (@best_moves,@best_scores);

	my $copied_array = &array_copy($inherited_game_sub_state);
	my @inherited_game_sub_state = @{$copied_array};

	my $my_matrix = &array_copy($inherited_game_sub_state);
	my @my_matrix = @{$my_matrix};

	my $move; my ($best_move,$best_score);
	my $returned_game_sub_state;
	my @scores;my $opponent;

	if ($player == 1) { $opponent = 2;}
	elsif ($player == 2) { $opponent = 1;}

	#my ($legal_moves,$x) = &legal_moves($player,\@inherited_game_sub_state);

	foreach $move (@{$legal_moves}) {

		my $my_matrix = &array_copy($inherited_game_sub_state);
		my @my_matrix = @{$my_matrix};
		$returned_game_sub_state = &play($player,$move,\@my_matrix,$dummy_play_or_real);	

		my($legal_moves,$x) = &legal_moves($opponent,$returned_game_sub_state);
		$_ = @{$legal_moves};

		if (($depth<$hard)and($_>0)){	
			($best_move,$best_score,$returned_game_sub_state) = &game_tree($depth,$returned_game_sub_state,$legal_moves);
			push (@scores, $best_score);
		}
		else {											
			my($d,$f,$g) = &scores($returned_game_sub_state);
			push (@scores, $d);
		}
	}
	my $scores = \@scores;
	($best_move,$best_score)=&minimax($legal_moves, \@scores,$depth);
	return ($best_move,$best_score);
}

sub minimax {

	my ($legal_moves, $scores,$depth) = ($_[0], $_[1],$_[2]); 
	my @scores = @$scores;
	my ($best_move,$best_score);
	$_ = &even_or_odd ($depth);

	if ($_==2) {
		($best_move,$best_score)=&pick_min($legal_moves, \@scores);
	}
	else {	($best_move,$best_score)=&pick_max($legal_moves, \@scores);

	}
	return ($best_move,$best_score);
}

sub legal_moves {

	my $player = $_[0];
	my $inherited_game_sub_state = $_[1];

	my $copied_array = &array_copy($inherited_game_sub_state);
	my @inherited_game_sub_state = @{$copied_array};

	my $my_matrix = &array_copy($inherited_game_sub_state);
	my @my_matrix = @{$my_matrix};

	my $dummy_or_real_play = 0;
	my $opponent;

	my ($i,$j,$x,$y);
	if ($player == 1) { $opponent = 2;}
	elsif ($player == 2) { $opponent = 1;}
	my @legal_moves=();

	for ($i=0;$i<8;$i++){	
		for ($j=0;$j<8;$j++){
			($x,$y) = &rule1($i,$j,$player,$opponent,$dummy_or_real_play,\@my_matrix);
			if($x == 0){
				push (@legal_moves, "$i$j");
			}				
		}
	}
	return (\@legal_moves,\@inherited_game_sub_state);
}

sub play {

	my ($player,$user_choice,$inherited_game_sub_state,$dummy_play_or_real) = ($_[0],$_[1],$_[2],$_[3]);

	my $copied_array = &array_copy($inherited_game_sub_state);
	my @inherited_game_sub_state = @{$copied_array};

	my $my_matrix = &array_copy($inherited_game_sub_state);
	my @my_matrix = @{$my_matrix};

	my $opponent;
	my $returned_game_state;

	if ($player == 1) {
		$opponent = 2;
		$returned_game_state = &rule2(substr($user_choice,0,1),substr($user_choice,1,1),$player,$opponent,$dummy_play_or_real,\@my_matrix); # rule2+rule3+sandwich
	}
	elsif ($player == 2) {
		$opponent = 1;
		$returned_game_state = &rule2(substr($user_choice,0,1),substr($user_choice,1,1),$player,$opponent,$dummy_play_or_real,\@my_matrix); # rule2+rule3+sandwich
	}
	@my_matrix = @$returned_game_state;
	if ($dummy_play_or_real == 1) {return \@my_matrix;}
	elsif ($dummy_play_or_real == 0) {return \@inherited_game_sub_state;}
}

# Rule-1 for a legal move : It should be empty
sub rule1 {	

	my ($i,$j,$player,$opponent,$dummy_or_real_play,$inherited_game_sub_state) = ($_[0],$_[1],$_[2],$_[3],$_[4],$_[5]);	

	my $copied_array = &array_copy($inherited_game_sub_state);
	my @inherited_game_sub_state = @{$copied_array};

	my $my_matrix = &array_copy($inherited_game_sub_state);
	my @my_matrix = @{$my_matrix};

	my ($x,$y); 

	if ($my_matrix[$i][$j] == 0){
		($x,$y) = &rule2($i,$j,$player,$opponent,$dummy_or_real_play,\@my_matrix);	
		if($x == 0){	#print "$i,$j is legal";<stdin>;
			return (0,0);					
		}
		return (1,0);
	}
	return (1,0);
}

# Rule-2 for a legal move : Adjacent cell must be occupied by opponent
sub rule2 {

	my ($i,$j,$player,$opponent,$dummy_play_or_real,$inherited_game_sub_state)=($_[0],$_[1],$_[2],$_[3],$_[4],$_[5]);

	my $copied_array = &array_copy($inherited_game_sub_state);
	my @inherited_game_sub_state = @{$copied_array};	


	my $my_matrix = &array_copy($inherited_game_sub_state);
	my @my_matrix = @{$my_matrix};

	my ($k,$l,$x,$returned_game_state); 
	my $found=1;	

	for ($k=-1;$k<=1;$k++){
		for ($l=-1;$l<=1;$l++){					
			if ((defined($my_matrix[$i+$k][$j+$l])) and ($my_matrix[$i+$k][$j+$l] == $opponent)){		
				($x,$returned_game_state) = &rule3($i,$j,$k,$l,$player,$opponent,$dummy_play_or_real,\@my_matrix);
				@my_matrix = @$returned_game_state;
				if($x == 0){			
					$found=0;#print "$i+$k, $j+$l is legal at rule 2";<stdin>;
					if ($dummy_play_or_real == 0){return 0,\@inherited_game_sub_state;}	
				}
			}
		}
	}
	if ($found==0){return 0, \@my_matrix;}	
	else {return 1,\@inherited_game_sub_state;}
}

# Rule-3 for a legal move : players move must sandwich opponent's coin
sub rule3 {

	my ($i,$j,$k,$l,$player,$opponent,$dummy_play_or_real,$inherited_game_sub_state)= ($_[0],$_[1],$_[2],$_[3],$_[4],$_[5],$_[6],$_[7]);

	my $copied_array = &array_copy($inherited_game_sub_state);
	my @inherited_game_sub_state = @{$copied_array};

	my $my_matrix = &array_copy($inherited_game_sub_state);
	my @my_matrix = @{$my_matrix};

	my $returned_game_state;
 
	my $m=$i+$k+$k;						
	my $n=$j+$l+$l;

	while(($n>=0)and($n<=7)and($m>=0)and($m<=7)){
		if ((defined($my_matrix[$m][$n]))and($my_matrix[$m][$n]==$player)){#print "$m,$n and $i,$j are in line at rule 3\n";<stdin>;
			if ($dummy_play_or_real == 1){
				$returned_game_state = &sandwich($i,$j,$k,$l,$m,$n,$player,\@my_matrix);	# Do sandwich
				return 0,$returned_game_state;
			}
			else {
				return 0,\@inherited_game_sub_state;
			}
		}
		elsif ((defined($my_matrix[$m][$n]))and($my_matrix[$m][$n]==$opponent)){
			$m=$m+$k;
			$n=$n+$l;
		}
		elsif ((defined($my_matrix[$m][$n]))and($my_matrix[$m][$n]==0)){
			return 1,\@inherited_game_sub_state;
		}
	}
	return 1,\@inherited_game_sub_state;
}

sub sandwich {

	my($i,$j,$k,$l,$m,$n,$player,$inherited_game_sub_state)=($_[0],$_[1],$_[2],$_[3],$_[4],$_[5],$_[6],$_[7]);	

	my $copied_array = &array_copy($inherited_game_sub_state);
	my @inherited_game_sub_state = @{$copied_array};

	my $my_matrix = &array_copy($inherited_game_sub_state);
	my @my_matrix = @{$my_matrix};

	my $returned_game_state;
	my($q,$r)=($i,$j);												

	do{$my_matrix[$q][$r]=$player;$q=$q+$k;$r=$r+$l;}								
	until(($q==$m)and($r==$n));
	
	return \@my_matrix;
}

sub pick_min{

	my ($legal_moves, $scores) = ($_[0],$_[1]);
	my @scores = @$scores; 
	my $size = @scores;
	my $c; my $min = $scores[0];my $x=0;
	for($c=0;$c<$size;$c++){
		if ($scores->[$c] < $min) {$x=$c; $min = $scores->[$c];}
	}
	return ($legal_moves->[$min],$min);
}

sub pick_max {

	my ($legal_moves, $scores) = ($_[0],$_[1]);
	my @scores = @$scores; 
	my $size = @scores;
	my $c; my $max = $scores[0]; my $x=0;
	for($c=0;$c<$size;$c++){
		if ($scores[$c] > $max) {$x=$c;$max = $scores[$c];}
	}
	return ($legal_moves->[$x],$max);
}

sub even_or_odd {
	$_ = $_[0]/2;	
	if ($_ =~ m/\./){return 1;}
	else {return 2;}
}

sub convert_num_to_alphabet {

	my @A = ('a','b','c','d','e','f','g','h');
	my @nums = (0..7);

	my ($c,$d,$d1,$d2,$e);
	$e = $_[0];

	if (ref($e) eq "ARRAY"){
		my @legal_moves = ();
		foreach $d(@{$e}) {
			($d1,$d2) = (substr($d,0,1),substr($d,1,1));
			for ($c=0;$c<=7;$c++){		
				if ($d1 == $nums[$c]){
					push (@legal_moves,"$A[$c]$d2"); 
					$c=8;
				}
			}
		}
		return \@legal_moves;
	}
	else{
		($d1,$d2) = (substr($e,0,1),substr($e,1,1));
		for ($c=0;$c<=7;$c++){		
			if ($d1 == $nums[$c]){
				$e = "$A[$c]"."$d2"; 
				return $e;
			}
		}
	}
}

sub print_matrix {

	my @my_matrix = @{$_[0]};
	my @A = ('a','b','c','d','e','f','g','h');
	my @nums = (0..7);
	my ($i,$j);
	
	print "\n\t        |   0   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |\n";
	print "\t .......|.......|.......|.......|.......|.......|.......|.......|.......|\n";
	for ($i=0;$i<8;$i++){
	print "\t        |       |       |       |       |       |       |       |       |\n";
	print "\t    $A[$i]   ";
		for ($j=0;$j<8;$j++){
			if ($my_matrix[$i][$j]==0) {print "|       ";}
			elsif ($my_matrix[$i][$j]==1) {print "|   +   ";}
			elsif ($my_matrix[$i][$j]==2) {print "|   _   ";}
		}
		print "|\n";
		print "\t        |       |       |       |       |       |       |       |       |\n";
		print "\t .......|.......|.......|.......|.......|.......|.......|.......|.......|\n";
	}
	print "\n";
	
}

sub end_game {
	my @my_matrix = @{$_[0]};
	my ($i,$j);
	for ($i=0;$i<8;$i++){
		for ($j=0;$j<8;$j++){
			if ($my_matrix[$i][$j]==0) {
				return 0;
			}
		}
	}
	return 1;
}

sub scores{
	my @my_matrix = @{$_[0]};
	my ($i,$j);
	my $player=0;my $computer=0;
	for ($i=0;$i<8;$i++){
		for ($j=0;$j<8;$j++){
			if ($my_matrix[$i][$j]==1) {
				$player++;
			}
			elsif ($my_matrix[$i][$j]==2) {
				$computer++;
			}
		}
	}
	$computer = sprintf ("%.4f",$computer);
	$_ = $computer/$player;
	return ($_,$computer,$player);
}

sub initial_state {

	my ($i,$j,@matrix);
	for ($i=0;$i<8;$i++){
		for ($j=0;$j<8;$j++){
			$matrix[$i][$j]=0;
		}
	}
	$matrix[3][3]=$matrix[4][4]=1;
	$matrix[3][4]=$matrix[4][3]=2;
	&print_matrix(\@matrix);
	print "You are playing '+', type row alphabet followed by column number (example c4) \n";
	return (\@matrix);
}

sub array_copy {

	my $in_array = $_[0];
	my @in_array = @{$in_array};
	my @out_array;
	my ($i,$j);
	
	for ($i=0;$i<8;$i++){
		for ($j=0;$j<8;$j++){
			if($in_array[$i][$j]==0){$out_array[$i][$j]=0;}
			elsif($in_array[$i][$j]==1){$out_array[$i][$j]=1;}
			elsif($in_array[$i][$j]==2){$out_array[$i][$j]=2;}
		}
	}
	return (\@out_array);
}

__END__
