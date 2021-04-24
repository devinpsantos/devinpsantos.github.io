use strict;
use warnings;

# This program allows user to access atm and interact 
my $user_in;
my $demand; 
my $answer;


		print "--Welcome to Chase ATM--\nPlease enter your 4-digit PIN.\n";
		$user_in = <STDIN>;
		chomp $user_in;
		

		if($user_in == 2136){
			do{
			print "Enter 1 to Withdraw, 2 to Check Balance, or 3 to Deposit.\n";
			$demand = <STDIN>;
			chomp $demand;
			
				if($demand == 2){
				
					my $balance = int(rand(2000));
					printf "Balance: %d US dollars\n", $balance;
				
				}
				elsif($demand == 1){
				
					print "Enter Amount to be withdrawn\n";
					my $amount = <STDIN>;
					printf "Please take your %d US dollars.\n", $amount;
				
				}
			
				elsif($demand == 3){
				
					print "Enter deposit amount.\n";
					my $dep = <STDIN>;
					printf "%d US dollars has been deposited.\n", $dep;
				
				}
			
				else{
					print "Incorrect entry.\n";
				}
			
		
	    
		
		print "Would you like to do something else Y or N?\n";
		$answer = <STDIN>;
		chomp $answer; 
		
} while($answer eq "Y");
		}

else{
			print "PIN is incorrect.\n";
			
		}

print "Thank You! Goodbye.";



