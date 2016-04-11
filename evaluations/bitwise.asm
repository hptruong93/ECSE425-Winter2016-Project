# Differences between bitwise and logical operators (& vs &&, | vs ||)
# $1: x = 3
# $2: y = 4
# $3: z = x & y    */ bitwise AND: 0...0011 and 0...0100 = 0...0 /*
# $4: w = x && y   */ logical AND: both are nonzero, so w = 1 /*
# $5: a = x | y    */ bitwise OR: 0...0011 and 0...0100 = 0...0111 /*
# $6: b = x || y   */ logical OR: at least one is nonzero, so w = 1 /*


				addi $11,  $0, 2000  	# initializing the beginning of Data Section address in memory 	#0
				addi $15, $0, 4 		# word size in byte 										   	#4
				
Bitwise:        addi $1, $0, 3																			#8
                addi $2, $0, 4																			#12
                and  $3, $1, $2         # z = x & y														#16
				
				addi $10, $0, 0																			#20
				mult $10, $15			# $lo=4*$10, for word alignment 								#24
				mflo $12				# assume small numbers											#28
				add  $13, $11, $12 		# Make data pointer [2000+($10)*4]								#32
				add $2,$0,$3 																			#36
				sw	 $2, 0($13)																			#40

                # w = x && y						
                beq  $1, $0, False      # branch to False if x = 0										#44
                beq  $2, $0, False      # branch to False if y = 0										#48
                addi $4, $0, 1          # x and y are both nonzero, so w = 1							#52
				
				addi $10, $0, 1																			#56
				mult $10, $15			# $lo=4*$10, for word alignment 								#60
				mflo $12				# assume small numbers											#64
				add  $13, $11, $12 		# Make data pointer [2000+($10)*4]								#68
				add $2,$0,$4 																			#72
				sw	 $2, 0($13)																			#76
				
                j Continue																				#80
False:          addi $4, $0, 0          # x and/or y are 0, so w = 0									#84

Continue:       or   $5, $1, $2         # a = x | y														#88
				
				addi $10, $0, 3																			#92
				mult $10, $15			# $lo=4*$10, for word alignment 								#96
				mflo $12				# assume small numbers											#100
				add  $13, $11, $12 		# Make data pointer [2000+($10)*4]								#104
				add $2,$0,$5 																			#108
				sw	 $2, 0($13)																			#112
				
                # w = x || y
                bne  $1, $0, True       # branch to True if x is non-zero								#116
                bne  $2, $0, True       # branch to True if y is non-zero								#120
                addi $6, $0, 0          # x and y are both zero, so b = 0								#124
				
				addi $10, $0, 4																			#128
				mult $10, $15			# $lo=4*$10, for word alignment 								#132
				mflo $12				# assume small numbers											#136
				add  $13, $11, $12 		# Make data pointer [2000+($10)*4]								#140
				add $2,$0,$6 																			#144
				sw	 $2, 0($13)																			#148
				
                j End 																					#152
True:           addi $6, $0, 1          # x and/or y are non-zero, so b = 1								#156

End:       		add  $31, $31, $0 		#evaluation purpose												#160
				beq	 $11, $11, End 		#end of program (infinite loop)									#164
