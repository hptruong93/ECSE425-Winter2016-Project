###############################################################################
############### A large loop program ##########################################
############### The loop does not fit in cache ################################
###############################################################################

#Find all prime divisors

addi $1 $0 72						#Input
addi $5 $0 100 						#index in memory where we store prime divisors

addi $2 $0 1 						#Checking if this number is a prime divisor
OUTER_LOOP: addi $2 $2 1 			#Increment index
beq $2 $1 END						#Cannot find any prime divisor

addi $3 $0 1 						#Check if $2 is prime
INNER_LOOP: addi $3 $3 1 			#Increment inner index
beq $3 $2 FOUND_PRIME				#If cannot find divisor

#Check if $2 mod $3 = 0
div $2 $3							
mflo $29
mult $29 $3
mflo $28
beq $28 $2 OUTER_LOOP				#If $2 mod $3 = 0 then this is not a prime. Check the next divisor

j INNER_LOOP

FOUND_PRIME: sw $2 0($5)			#Store the result
addi $5 $5 4						#Increment pointer in memory

j OUTER_LOOP

END: j END
