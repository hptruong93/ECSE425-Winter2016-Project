#####################testin individual instructions#######################
add 		$3 $0 $23
sub 		$4 $3 $2
addi 		$1 $10 1000
slt 		$1 $2 $10
slti 		$1 $2 230
mult		$2 $3
div 		$2 $3
mfhi          $1
mflo		$1
lui 		$1 200
and           $2 $3 $4
or		$23 $24 $31
andi		$23 $10 100
ori		$1 	$2	4
nor		$1	$2	$
xor		$1 	$2 	$
xori		$2	$5	
sll		$2 	$3	$
srl		$2	$6	$
sra		$23	$5	$
lw 		$23	1000($5
sw		$1	100($2)
lb		$3	23($4)
sb		$1	23($3)
beq		$5	$6	
beq		$2	$10	
END:
bne 		$1	$2	
j 		LABEL
LABEL:
jr		$31
jal		12356