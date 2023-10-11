## Identificacao 
# Arthur Belini Pini - RA118999
# Pedro Lucas Keizo Honda - RA119188

## Struct do registro
# next - 4B
#
# nome - 50B
# cidade - 50B
# bairro - 50B
# celular - 12B
#
# tipo - 1B (casa - 0, apto. - 1)
# garagem - 1B (nao - 0, sim - 1)
#
# simples - 4B
# suites - 4B
# metragem - 4B
#
# aluguel - 4B
#
# Total: 4B + 50B + 50B + 50B + 12B + 1B + 1B + 4B + 4B + 4B + 4B = 184B

.section .data
    ## Struct de registro
    reg_str:        .space  50      # Nome, cidade e bairro

    reg_bool:       .byte   1       # Tipo e garagem

    reg_int:        .int    0       # Quantidade de quartos simples, suites e metragem

    reg_float:      .float  0.0     # Aluguel

    ## Auxiliares
    regs_lst_first: .int    0       # Ponteiro para pos inicial da lista de registros
    next_reg_addr:  .int    0       # Ponteiro para prox pos da lista de registros
    prev_reg_addr:  .int    0       # Ponteiro para pos anterior a atual da lista de registros
    cur_reg_addr:   .int    0       # Ponteiro para pos atual a atual da lista de registros
    next:           .int    0       # Ponteiro para próxima posição na lista
    offset:         .int    0       # Deslocamento atual do registro atual
    qtd_bytes:      .int    0       # Quantidade de bytes lidos
    num_value:      .int    0       # Valor de um campo numerico do registro
    qtd_quartos:    .int    0       # Quantidade de quartos (simples + suites) no novo registro

    tam_reg:        .int    184

    menu_str:       .asciz  "Menu de Opcoes\n<1> Inserir\n<2> Remover\n<3> Consultar\n<4> Gravar\n<5> Recuperar\n<6> Listar\n<7> Sair\nDigite opcao => "
    jmp_line:       .asciz  "\n"

    opcao:          .int    0

    tipo_int:       .asciz  "%d"
    tipo_str:       .asciz  "%s"
    tipo_bool:      .asciz  "%d"
    tipo_float:     .asciz  "%f"

    pede_nome:      .asciz  "Nome: "
    pede_celular:   .asciz  "Celular (11 digitos): "
    pede_cidade:    .asciz  "Cidade: "
    pede_bairro:    .asciz  "Bairro: "
    pede_tipo:      .asciz  "Tipo: "
    pede_garagem:   .asciz  "Garagem: "
    pede_metragem:  .asciz  "Metragem: "
    pede_simples:   .asciz  "Simples: "
    pede_suites:    .asciz  "Suites: "
    pede_aluguel:   .asciz  "Aluguel: "

    teste: 	        .asciz  "%d\n"

.section .text

.globl _start

## Chama funções principais
_start:
    call    menu                    # Recebe opcao

    call    tratar_opcoes           # Executa opcao

    pushl	$jmp_line               # Pula uma linha
	call	printf

    jmp     _start

## Imprimir menu e recebe opcao
menu:
    pushl	$menu_str
	call	printf

    pushl	$opcao
	pushl	$tipo_int
	call	scanf

    addl    $12, %esp

    RET

## Recebe opcao e redireciona acao
tratar_opcoes:
    cmpl	$1, opcao
	je		inserir

	cmpl	$2, opcao
	je		remover
	
	cmpl	$3, opcao
	je		consultar

    cmpl	$4, opcao
	je		gravar

    cmpl	$5, opcao
	je		recuperar

    cmpl	$6, opcao
	je		listar

    cmpl	$7, opcao
	je		fim

    RET

########## Inserção ##########

## Inserção de registro em memória
## Caminha pela lista até chegar ao fim e insere
inserir:
    # Restauracao de variaveis
    movl    $4, offset              # Offset do primeiro campo do registro
    movl    $0, qtd_quartos         # Reseta contador de qtd_quartos

    # Aloca memoria para novo registro
    call    alocar                  # Aloca registro e poe em cur_reg_addr

    movl    $50, qtd_bytes          # Inicia leituras de strings de 50 bytes

    # Leitura do nome
    pushl	$reg_str  
    pushl	$tipo_str  
    pushl	$pede_nome   
    call    pedir

    call    ler_str

    # Leitura da cidade
    pushl	$reg_str  
    pushl	$tipo_str
    pushl	$pede_cidade
    call    pedir

    call    ler_str

    # Leitura do bairro
    pushl	$reg_str
    pushl	$tipo_str
    pushl	$pede_bairro
    call    pedir

    call    ler_str

    movl    $12, qtd_bytes          # Le celular de 11 digitos

    # Leitura do celular
    pushl	$reg_str 
    pushl	$tipo_str
    pushl	$pede_celular  
    call    pedir

    call    ler_str

    movl    $1, qtd_bytes           # Inicia leituras de booleanos de 1 byte

    # Leitura do tipo
    pushl	$reg_bool
    pushl	$tipo_bool  
    pushl	$pede_tipo
    call    pedir
    movl    reg_bool, %eax
    movl    %eax, num_value

    call    ler_num

    # Leitura da existencia de garagem
    pushl	$reg_bool
    pushl	$tipo_bool
    pushl	$pede_garagem
    call    pedir
    movl    reg_bool, %eax
    movl    %eax, num_value

    call    ler_num

    movl    $4, qtd_bytes           # Inicia leituras de ints e floats de 4 byte

    # Leitura de quantidade de quartos simples
    pushl	$reg_int
    pushl	$tipo_int 
    pushl	$pede_simples 
    call    pedir
    movl    reg_int, %eax
    movl    %eax, num_value

    call    ler_num

    addl    $reg_int, qtd_quartos

    # Leitura da quantidade de suites
    pushl	$reg_int  
    pushl	$tipo_int 
    pushl	$pede_suites 
    call    pedir
    movl    reg_int, %eax
    movl    %eax, num_value

    call    ler_num

    addl    $reg_int, qtd_quartos

    # Leitura da metragem
    pushl	$reg_int  
    pushl	$tipo_int 
    pushl	$pede_metragem 
    call    pedir
    movl    reg_int, %eax
    movl    %eax, num_value

    call    ler_num

    # Leitura do aluguel
    pushl	$reg_float
    pushl	$tipo_float 
    pushl	$pede_aluguel
    call    pedir
    movl    reg_float, %eax
    movl    %eax, num_value

    call    ler_num

    # Finalizacao
    call    ordenar                 # Poe a memoria alocada na pos de acordo com num de quartos (s + s)

    RET

# Aloca memoria para novo registro
alocar:
    pushl   tam_reg
    call    malloc

    movl    %eax, cur_reg_addr

    addl    $4, %esp

    RET

# Pede string do novo registro
pedir:
    popl    %ebx

    # Imprime pedido de string
    call	printf
    addl    $4, %esp

    # Le string
	call	scanf

    addl    $8, %esp

    pushl   %ebx

    RET

## Le uma string do novo registro
ler_str:
    # Define fonte (reg_str) e destino (regs_lst_cur) para escrita de nome no registro
    leal    reg_str, %esi              
    movl    cur_reg_addr, %edi
    addl    offset, %edi

    # Move valor de nome para endereco em regs_lst_cur
    movl    qtd_bytes, %ecx 
    rep     movsb

    addl    qtd_bytes, %eax
    addl    %eax, offset

    RET

## Le um numero do novo registro
ler_num:             
    movl    cur_reg_addr, %edi
    addl    offset, %edi

    movl    $num_value, (%edi)

    addl    qtd_bytes, %eax
    addl    %eax, offset
    
    RET

# Posiciona registro alocado na pos da lista segundo o num de quartos (simples + suites)
ordenar:
    movl    regs_lst_first, %edx

    leal    regs_lst_first, %eax
    movl    %eax, prev_reg_addr
    movl    %edx, next_reg_addr

    proximo_procurar:
    cmpl	$0, %edx
    je      inserir_na_pos

    movl	168(%edx), %edx
    addl	$4, %edx

    cmpl	$qtd_quartos, %edx
    jg      inserir_na_pos

    movl    (%edx), %eax
    movl    %eax, %edx

    jmp     proximo_inserir

    movl    $next_reg_addr, prev_reg_addr
    movl    (%edx), %eax
    movl    %eax, next_reg_addr
    movl    next_reg_addr, %edx

    jmp     inserir_na_pos

    inserir_na_pos:
    movl    cur_reg_addr, %eax

    movl    prev_reg_addr, %ebx
    movl    %eax, (%ebx)

    movl    next_reg_addr, %ebx
    movl    %ebx, (%eax)

    RET

########## Remoção ##########

## Remoção de cadastro em memória
remover:
    movl    $2, %eax

    pushl   %eax
	pushl   $teste
	call    printf

    addl    $8, %esp

    RET

## Consulta de cadastro em memória
consultar:
    movl    $3, %eax

    pushl   %eax
	pushl   $teste
	call    printf

    addl    $8, %esp

    RET

## Gravação de cadastro em disco
gravar:
    movl    $4, %eax

    pushl   %eax
	pushl   $teste
	call    printf

    addl    $8, %esp

    RET

## Recuperação de cadastro em disco
recuperar:
    movl    $5, %eax

    pushl   %eax
	pushl   $teste
	call    printf

    addl    $8, %esp

    RET

## Relatório de cadastros em memória
listar:
    movl    $6, %eax

    pushl   %eax
	pushl   $teste
	call    printf

    addl    $8, %esp

    RET

## Libera lista
## Caminha pela lista enquanto libera os nós
## Em geral, inverso de inserir
liberar:
    movl    regs_lst_first, %edx    # Move endereço em regs_lst para %edx

    proximo_liberar:
    cmpl	$0, %edx                # 0 representa fim da lista
    je      fim_lst_liberar         # Caso 0, pula para fim_lst

    movl    (%edx), %ebx            # Backup da prox pos da lista

    pushl   %edx                    # Endereço de %edx que se deseja liberar para pilha
    call    free
    addl    $4, %esp

    movl    %ebx, %edx              # Recupera prox pos da lista

    jmp     proximo_liberar

    fim_lst_liberar:
    RET

## Saída do programa
fim:
    call liberar                    # Libera lista de registros
               
    break2:
    movl $1, %eax                   # eax <- sair
    xor %ebx, %ebx                  # ebx <- saída sem erro
    int $0x80                       # Chamada de sistema

########## Auxiliares ##########

mostrar_reg:
    leal    regs_lst_first, %edx    # Move endereço de regs_lst para %edx

    proximo_inserir:
    cmpl	$0, (%edx)              # 0 representa fim da lista
    je      fim_lst_alocar          # Caso 0, pula para alocar

    movl    (%edx), %eax            # Move valor no endereço em %edx para %eax
    movl    %eax, %edx              # Move valor de %eax para %edx

    jmp     proximo_inserir

    fim_lst_alocar:
    pushl   %edx                    # Backup de %edx
    pushl   tam_reg
    call    malloc

    addl    $4, %esp                # Retira tam_reg da pilha
    popl    %edx                    # Recuperar %edx
    movl    $0, (%eax)              # Move 0 para o endereço do valor de %eax
    movl    %eax, (%edx)            # Move endereço em %eax para endereço do valor de %edx

    movl    %eax, cur_reg_addr      # Move pos atual da lista a regs_lst_cur

    RET
