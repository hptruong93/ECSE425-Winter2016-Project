###############################################
# This program generates Fibonacci series.
# It stores the generated Fibonacci numbers fisrt into, Reg[2] ($2), and then into memory
# Assume that your data section in memory starts from address 2000
			
	addi $10,  $0, 7	# number of generating Fibonacci-numbers 								#0 
	addi $1,   $0, 1	# initializing Fib(-1) = 1												#4 
	addi $2,   $0, 1	# initializing Fib(0) = 1												#8
	addi $11,  $0, 2000  	# initializing the beginning of Data Section address in memory		#12
	addi $15,  $0, 4	# word size in byte														#16
			
loop:	addi $3, $2, 0		# temp = Fib(n-1)													#20
	add  $2, $2, $1		# Fib(n)=Fib(n-1)+Fib(n-2)												#24
	addi $1, $3, 0		# Fib(n-2)=temp=Fib(n-1)												#28
	mult $10, $15		# $lo=4*$10, for word alignment 										#32
	mflo $12		# assume small numbers 														#36
	add  $13, $11, $12	# Make data pointer [2000+($10)*4]										#40
	sw	 $2, 0($13)	# Mem[$10+2000] <-- Fib(n)													#44
	addi $10, $10, -1	# loop index															#48
	bne  $10, $0, loop 																			#52
			
	lw   $7, 2004($0)																			#56 for testing to see if write was correct

EoP:	beq	 $11, $11, EoP 	#end of program (infinite loop)										#60
###############################################
