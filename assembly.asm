#####################testin individual instructions#######################
addi 	$1 $0 15
addi 	$2 $0 15
beq 	$1 $2 AAAA
addi	$3 $0 32
AAAA:   mult $1 $2
		mflo $1
jr		$0
