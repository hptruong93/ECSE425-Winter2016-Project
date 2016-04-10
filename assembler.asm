###############################################################################
############### A large loop program ##########################################
############### The loop does not fit in cache ################################
###############################################################################

#Find all prime divisors

addi $1 $0 15						#Input																	#0
addi $5 $0 100 						#index in memory where we store prime divisors							#4

addi $2 $0 1 						#Checking if this number is a prime divisor 							#8
OUTER_LOOP: addi $2 $2 1 			#Increment index														#12
beq $2 $1 END						#Cannot find any prime divisor 											#16

addi $3 $0 1 						#Check if $2 is prime 													#20
INNER_LOOP: addi $3 $3 1 			#Increment inner index 													#24
beq $3 $2 FOUND_PRIME				#If cannot find divisor 												#28

#Check if $2 mod $3 = 0
div $2 $3																									#32
mflo $29																									#36
mult $29 $3																									#40
mflo $28																									#44
beq $28 $2 OUTER_LOOP				#If $2 mod $3 = 0 then this is not a prime. Check the next divisor 		#48

j INNER_LOOP 																								#52

FOUND_PRIME: div $1 $2				#check if $2 divides $1													#56
mfhi $3																										#60
bne $3 $0 OUTER_LOOP																						#64


sw $2 0($5)							#Store the result 														#68
addi $5 $5 4						#Increment pointer in memory											#22

j OUTER_LOOP																								#76

add $8 $2 $0																								#80
END: j END																									#84
