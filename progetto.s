.data
listInput: .string "ADD(a) ~ ADD(b)~ADD(c)~PRINT ~DEL(c)~PRINT~SSX~PRINT~REV~PRINT"
addressStart: .word 0x01000000
str1: .string "La lista e': "
str2: .string "La lista e' vuota"
newline: .string "\n"
.text
lw s0, addressStart #address lista
la s1, listInput #input
add a0, s0, zero #PAHEAD
li s2, 0 #indice input 0

jal checkAdd
  
checkAdd:
    add t1, s2, s1 #t1 = il puntatore al primo carattere
    lb t2, 0(t1) #t2 = primo carattere 
    addi t3, t2, -65 # t3 = primo carattere - A
    bne t3, zero, checkDelete #se t3 e' 0 allora trovato A|DD senno si controlla se e' una D
    addi s2, s2, 1 #incremento l'indice t0 di 1
    add t1, s2, s1 #t1 = puntatore al secondo carattere
    lb t2, 0(t1) #t2  = secondo carattere
    addi t3, t2, -68 #t3 0 secondo carattere - 68
    bne t3, zero, reloadCommandNotFound #se t3 e' 0 allora trovato AD|D senno comando non valido
    addi s2, s2, 1 #incremento l'indice di 1
    add t1, s2, s1 #t1 = puntatore al terzo carattere
    lb t2, 0(t1) #t2 = terzo carattere
    addi t3, t2, -68 #t3 = terzo carattere - 68
    bne t3, zero, reloadCommandNotFound #se t3 e' zero trovato ADD senno comando non valido
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -40 #Trovato Open
    bne t3, zero, reloadCommandNotFound
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    li t5, 125 #ParametroIncorretto
    bgt t2, t5, reloadCommandNotFound
    li t5, 32 #ParametroIncorretto
    blt t2, t5, reloadCommandNotFound
    add a2, t2, zero #salvo parametro in a2
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -41 #Trovato Close
    bne t3, zero, reloadCommandNotFound
 
    jal verifyGood
 
    bne a1, zero, callAdd
    j commandNotFound

callAdd:
    jal add
    j nextCommand

add:
    lb t0, 0(a0)
    bne t0, zero, normal_case
    
base_case:
    sb a2, 0(s0) #Scrivo il parametro nel primo byte
    sw s0, 1(s0) #Il primo ellemento punta a se stesso
    jr ra
    
normal_case:
    j searchMemory
    normal_case_1:
        lb t0, 0(a0)
        lw t5, 1(a0)
        beq t5, a0, inserisci #se punta alla testa inserisco
        doAdd:
            lw t2, 1(t5) #leggo il primo puntatore
            beq t2, a0, inserisci #se punta alla testa inserisco
            add t5, t2, zero
            j doAdd
        
inserisci:
    sb a2, 0(a3) #a3 memoriaLibera
    sw a0, 1(a3)
    sw a3, 1(t5)
    
    jr ra

checkDelete:
    addi t3, t2, -68 #Trovato D|EL
    bne t3, zero, checkPrint
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -69
    bne t3, zero, reloadCommandNotFound #Trovato DE|L
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -76
    bne t3, zero, reloadCommandNotFound #Trovato DEL
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -40 #Trovato Open
    bne t3, zero, reloadCommandNotFound
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -32 #ParametroIncorretto
    blt t3, zero, reloadCommandNotFound
    addi t3, t2, -125 #ParametroIncorretto
    bgt t3, zero, reloadCommandNotFound
    add a2, t2, zero #salvo parametro in a2
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -41 #Trovato Close
    bne t3, zero, reloadCommandNotFound
 
    jal verifyGood
 
    bne a1, zero, callDelete
    j commandNotFound
        
    callDelete:
        jal delete
        j nextCommand
delete:
	lb t0, 0(a0)
	lw t1, 1(a0)
	beq t0, a2, verifyStart
    add t3, a0, zero
	
	loopDelete:
		lb t0, 0(t1)
        beq t0, a2, verify
        add t3, t1, zero
        lw t1, 1(t1)
        beq t1, a0, returnDelete
		j loopDelete

returnDelete:
    jr ra

verify:
    lw t4, 1(t1)
    sb zero, 0(t1)
    sw zero, 1(t1)
    sw t4, 1(t3)
    add t1, t4, zero
    beq t4, a0, returnDelete
 
    j loopDelete
 
verifyStart:
	beq t1, a0, delAll
	
	j delHead

delAll:
	sb zero, 0(a0)
	sw zero, 1(a0)
	j returnDelete

delHead:
	add t0, a0, zero #salvo la pos della testa da eliminare per controllare quale elemento lo punta (cio? la coda) in t0
	lw t1, 1(t0) #salvo la pos del secondo elemento in t1
	add a0, t1, zero #head = head.pun
	add t2, t0, zero #uso t2 per scorrere la lista
	loopDelHead:
		beq t1, t0, siamoInCoda #se elemento letto punta la vecchia coda -> vai!
		lw t1, 1(t2) #carico l'elemento successivo
		add t2, t1, zero #mi salvo la posizione cosi da poter scorrere
		j loopDelHead

siamoInCoda:
	sw a0, 1(t1) #Dico che coda.pun = head
	j delete

checkPrint:
    addi t3, t2, -80 #Trovato P|RINT
    bne t3, zero, checkSsx
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -82
    bne t3, zero, reloadCommandNotFound #Trovato PR|INT
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -73
    bne t3, zero, reloadCommandNotFound #Trovato PRI|NT
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -78
    bne t3, zero, reloadCommandNotFound #Trovato PRIN|T
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -84
    bne t3, zero, reloadCommandNotFound #Trovato PRINT
    
    jal verifyGood
    bne a1, zero, callPrint
    j commandNotFound
        
        
callPrint:
    jal print
    j nextCommand
    
print:
    lb t0, 0(a0)
    lw t5, 1(a0)
    beq t0, zero, printNull
    add t1, a0, zero #Carico phead che viene usato per scorrere
    add t4, t1, zero #Carico phead che viene usato per la stampa
    
    la a0, str1
    li a7, 4
    ecall
    mv a0, t0
    li a7, 11
    ecall
    add, a0, t1, zero
    beq t5, a0, newLine
    doPrint:
        lb t0, 0(t5) #Leggo il valore da stampare
        lw t2, 1(t5) #leggo il primo puntatore
        add t5, t2, zero
        add a0, t4, zero #Ripristino phead
        bne t2, a0, loadPrint #se punta alla testa inserisco
        mv a0, t0
        li a7, 11
        ecall
        newLine:
        la a0, newline
        li a7, 4
        ecall
        add, a0, t1, zero
        jr ra 
        
loadPrint:
    mv a0, t0
    li a7, 11
    ecall
    j doPrint
    
printNull:
    mv a0, t0
    la a0, str2
    li a7, 4
    ecall
    la a0, newline
    li a7, 4
    ecall
    add a0, t0, zero
    jr ra
    
checkSsx:
    addi t3, t2, -83 #Trovato S|SX
    bne t3, zero, checkRev
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -83 #Trovato SS|X
    bne t3, zero, checkSdx
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -88 #Trovato SSX
    bne t3, zero, reloadCommandNotFound
    
    jal verifyGood
    bne a1, zero, callSsx
    j commandNotFound
        
callSsx:
    jal ssx
    j nextCommand
    
ssx:
    lb t0, 0(a0)
    lw t1, 1(a0)
    beq t0, zero, returnSsx
    beq t1, a0, returnSsx
    add a0, t1, zero
    j returnSsx

returnSsx:
    jr ra

checkSdx:
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -68 #Trovato SD|X
    bne t3, zero, checkSort
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -88 #Trovato SDX
    bne t3, zero, reloadCommandNotFound
    
    jal verifyGood
    bne a1, zero, callSdx
    j commandNotFound
        
callSdx:
    jal sdx
    j nextCommand

sdx:
    lb t0, 0(a0)
    lw t1, 1(a0)
    beq t0, zero, returnSdx
    beq t1, a0, returnSdx
    add t2, t1, zero
    sdxLoop:
        lw t1, 1(t1)
        beq t1, a0, doSdx #se punta alla testa inserisco
        add t2, t1, zero
        j sdxLoop 
        
doSdx:
    add a0, t2, zero
    j returnSdx
    
returnSdx:
    jr ra
    
checkSort:
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -79 #Trovato SO|RT
    bne t3, zero, reloadCommandNotFound
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -82 #Trovato SOR|T
    bne t3, zero, reloadCommandNotFound
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -84 #Trovato SORT
    bne t3, zero, reloadCommandNotFound
    
    jal verifyGood
    bne a1, zero, sort
    j commandNotFound
    
sort:
    numberOfElement:
    lb t0, 0(a0)
    lw t5, 1(a0)
    beq t0, zero, nextCommand
    beq t5, a0, nextCommand
    li s3, 1
    loop:
        lw t5, 1(t5)
        addi s3, s3, 1
        beq a0, t5, lengthFound
        j loop
                
    lengthFound:
        add a1, s3, zero
        jal bubbleSort
        j nextCommand

    bubbleSort:
        addi sp, sp, -4
        sw ra, 0(sp)
        li t0, 1
        beq a1, t0, return
        li t0, 0 #count
        
        lb t2, 0(a0)
        lw t3, 1(a0)
        li t1, 1 #i
        add s4, a0, zero
        doSort:
          beq t1, a1, endDo
          lb t4, 0(t3)
          lw t5, 1(t3)
          beq t2, t4, else
          bgt t2, t4, if 
          else:
          addi t1, t1, 1
          add s4, t3, zero
          add t3, t5, zero
          add t2, t4, zero
       
          endIf:
          
          j doSort
          
          endDo:
          beq t0, zero, return
          addi a1, a1, -1
          jal bubbleSort
        
    return:
        lw ra, 0(sp)
        addi sp, sp, 4
        jr ra
    if:
        sb t4, 0(s4)
        sb t2, 0(t3)
        addi t0, t0, 1 #count = count +1
        
        addi t1, t1, 1 #i++
        add s4, t3, zero 
        add t3, t5, zero
	
      j endIf
      
checkRev:
    addi t3, t2, -82 #Trovato R|EV
    bne t3, zero, reloadCommandNotFound
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -69 #Trovato RE|V
    bne t3, zero, reloadCommandNotFound
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -86 #Trovato REV
    bne t3, zero, reloadCommandNotFound
    
    jal verifyGood
    bne a1, zero, callRev
    j commandNotFound

callRev:
    jal rev
    j nextCommand

rev:
    lw t1, 1(a0)
    beq t1, a0, returnRev
    lb t0, 0(a0)
    addi sp, sp -4
    sb t0, 0(sp)
    loopRev:
        lb t0, 0(t1)
        j push
        afterpush:
            lw t1, 1(t1)
            beq t1, a0, pop
            j loopRev
            
push:
    addi sp, sp -4
    sb t0, 0(sp)
    j afterpush
    
pop:
    
    add t1, s0, zero
    loopPop:
        lb t0, 0(sp)
        lb t3, 4(sp)
        addi sp, sp, 4
        
        beq t3, zero, lastPop
        sb t0, 0(t1)
        addi t2, t1, 5
        sw t2, 1(t1)
        addi t1, t1 5
        j loopPop
    
lastPop:
    sb t0, 0(t1)
    sw s0, 1(t1)
    j returnRev
    
returnRev:
    jr ra
    
searchMemory:
    add t1, s0, zero #PAHEAD
    lb t0, 0(t1) #Leggo 1 byte
    lw t2, 1(t1) #Leggo 4 byte
        
    scorriMem:
        lw t2, 1(t1) #Leggo 4 byte
        add a3, t1, zero
        beq t2, zero, normal_case_1 #Se i byte letti sono 0 scrivo
        addi t1, t1, 5 #Incremento il count di 5 e guardo la pos successiva
        j scorriMem
    
verifyGood:
    li t2, 32
    addi s2, s2, 1 #indexInput++
    add t1, s2, s1 #t1 = address -> charAt(indexInput)
    lb t3, 0(t1) #t3 = charAt(indexInput)
    beq t3, t2, verifyGood #Trovato spazio
    
verifyTilde:
    li t2, 126
    beq t3, zero, lastCommand
    bne t3, t2, commandNotValid #Trovato tilde
    li a1, 1
    jr ra
    
lastCommand:
    li a1, 1
    jr ra
    
commandNotValid:
    li a1, 0
    jr ra

reloadCommandNotFound:
    addi s2, s2, -1
    j commandNotFound

commandNotFound:
    checkTilde:
        addi s2, s2, 1
        add t1, s2, s1
        lb t2, 0(t1)
        addi t3, t2, -126 #Trovato Spazio
        beq t2, zero, endloop
        bne t3, zero, checkTilde
nextCommand: #Cerca spazi dopo la tilde
    addi s2, s2, 1
    add t1, s2, s1
    lb t2, 0(t1)
    addi t3, t2, -32 #Trovato Spazio
    bne t3, zero, checkAdd
    beq t2, zero, endloop
    j nextCommand 
  
endloop:
    li a0, 10
    ecall