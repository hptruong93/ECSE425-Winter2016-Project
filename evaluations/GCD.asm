###############################################################################
###########################  GCD of THREE numbers   ###########################
###############################################################################


#store x, y, z in $5, $6
addi $5 $0 24   															#0
addi $6 $0 10																#4
addi $8 $0 8	 															#8


START0: 	div $5 $6														#12
			mfhi   $7														#16
			beq $7 $0 START1												#20
			add $5 $6 $0													#24
			add $6 $7 $0													#28
			j START0														#32


START1:	beq $6 $0 FINISH													#36
			add $7 $6 $0													#40
			slt $9 $7 $8													#44
			beq $9 $0 loop													#48
			add $10 $7 $0													#52
			add $7  $0 $8													#56
			add $8 $10 $0													#60

loop:		div $7 $8														#64
			mfhi   $10														#68
			beq $10 $0 FINISH												#72
			add $7 $8 $0													#76
			add $8 $10 $0													#80
			j loop															#84

FINISH: sw $8  1000($0)						#put output into $8				#88
		  lw $9  1000($0)													#92

END:	add $31 $31 $0														#96
		j END																#100

