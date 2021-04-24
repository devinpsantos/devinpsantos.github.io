use strict; 
use warnings; 

# This program tells us the amount of ones in any number
my $answer; # must at least declare $answer for do-while 
do {
print "Enter a number.\n";
my $anynum = <STDIN>; # allows user to enter number in cmd line 
chomp $anynum;  # get rid of empty spaces 
my $num = $anynum; 
my $totalones = 0; 
# while number is not equal to 0
while($num != 0){
	# bit-wise AND to single out LSB 
	if(($num & 1) == 1){
		$totalones++; # if its 1, increment the count  
	}
	
	$num = $num >> 1; # logical shift right, toss out LSB and shift right one time 
	
}

# use printf when wanting to display values like so ( %d means decimal value of number ) 
printf "The number %d has %d total ones in its binary equivalent.\n", $anynum, $totalones; 
print "Enter yes to go again or something random to end program.\n";
$answer = <STDIN>; 
chomp $answer; 
} while($answer eq "yes");  # use == when comparing numbers and eq when comparing letters/words

