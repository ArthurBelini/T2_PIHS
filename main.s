## Identificacao 
# Arthur Belini Pini - RA118999
# Pedro Lucas Keizo Honda - RA119188

## Struct do registro
# next - 4B
#
# nome - 50B
# celular - 12B
# cidade - 50B
# bairro - 50B
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
# Total: 4B + 50B + 12B + 1B + 100B + 8B + 1B + 4B + 4B = 184B

.section .data
    ## Struct de registro
    nome:           .space  50
    celular:        .space  12
    cidade:         .space  50
    bairro:         .space  50

    tipo:           .byte   1
    garagem:        .byte   1   

    metragem:       .int    0
    simples:        .int    0
    suites:         .int    0
    regs_lst_first: .int    0       # Ponteiro para pos inicial da lista de registros
    regs_lst_cur:   .int    0       # Ponteiro para pos atual da lista de registros
    next:           .int    0       # Ponteiro para próxima posição na lista

    aluguel:        .float  0.0

    ## Auxiliares
    tam_reg:        .int    184

    menu_str:       .asciz  "Menu de Opcoes\n<1> Inserir\n<2> Remover\n<3> Consultar\n<4> Gravar\n<5> Recuperar\n<6> Listar\n<7> Sair\nDigite opcao => "
    jmp_line:       .asciz  "\n"

    opcao:          .int    0

    tipo_int:       .asciz  "%d"
    tipo_str:       .asciz  "%s"

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
    call    alocar

    call    ler_nome

    RET
    

alocar:
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

    movl    %eax, regs_lst_cur      # Move pos atual da lista a regs_lst_cur

    RET

## Le o nome do novo registro
ler_nome:
    # Imprime pedido de nome
    pushl	$pede_nome              
	call	printf

    # Le nome
    pushl	$nome		            
	pushl	$tipo_str	
	call	scanf

    # Define fonte (nome) e destino (regs_lst_cur) para escrita de nome no registro
    leal    nome, %esi              
    movl    regs_lst_cur, %edi
    addl    $4, %edi

    # Move valor de nome para endereco em regs_lst_cur
    movl    $50, %ecx 
    rep     movsb

    addl    $8, %esp
    
    RET

## Le o celular do novo registro
ler_celular:
    movl    50(%edx), %eax          # Move até posição correta no registro

## Le a cidade do novo registro
ler_cidade:
    movl    11(%edx), %eax          # Move até posição correta no registro

## Le o bairro do novo registro
ler_bairro:
    movl    50(%edx), %eax          # Move até posição correta no registro

## Le o tipo do novo registro
ler_tipo:
    movl    50(%edx), %eax          # Move até posição correta no registro

## Le se tem garagem no novo registro
ler_garagem:
    movl    1(%edx), %eax           # Move até posição correta no registro

## Le a quantidade de quartos simples do novo registro
ler_simples:
    movl    1(%edx), %eax           # Move até posição correta no registro

## Le a quantidade de suites do novo registro
ler_suites:
    movl    4(%edx), %eax           # Move até posição correta no registro

## Le a metragem do novo registro
ler_metragem:
    movl    4(%edx), %eax           # Move até posição correta no registro

## Le o aluguel do novo registro
ler_aluguel:
    movl    4(%edx), %eax           # Move até posição correta no registro    

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
