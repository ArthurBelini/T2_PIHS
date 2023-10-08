## Autores 
# Arthur Belini Pini - RA118999
# Pedro Lucas Keizo Honda - RA119188

## Struct do registro
# nome - 50B
# celular - 11B
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
# Total: 50B + 11B + 1B + 100B + 8B + 1B + 4B + 4B = 179B

.section .data
    ## Struct de registro
    nome:       .space  50
    celular:    .space  11
    cidade:     .space  11
    bairro:     .space  11

    tipo:       .byte   1
    garagem:    .byte   1   

    metragem:   .int    0
    simples:    .int    0
    suites:     .int    0
    regs_lst:   .int    0       # Ponteiro para pos inicial da lista de registros
    next:       .int    0       # Ponteiro para próxima posição na lista

    aluguel:    .float  0.0

    ## Auxiliares
    tam_reg:    .int    179

    menu_str:   .asciz  "Menu de Opcoes\n<1> Inserir\n<2> Remover\n<3> Consultar\n<4> Gravar\n<5> Recuperar\n<6> Listar\n<7> Sair\nDigite opcao => "
    jmp_line:   .asciz  "\n"

    opcao:      .int    0

    tipo_int:   .asciz  "%d"

    teste: 	    .asciz  "%d\n"

.section .text

.globl _start

## Inicialização de variáveis
_start:
    call    menu                # Recebe opcao

    call    tratar_opcoes       # Executa opcao

    pushl	$jmp_line           # Pula uma linha
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

## Inserção de registro em memória
## Caminha pela lista até chegar ao fim e insere
inserir:
    leal    regs_lst, %edx      # Move endereço de regs_lst para %edx

    proximo:
    cmpl	$0, (%edx)          # 0 representa fim da lista
    je      alocar              # Caso 0, pula para alocar

    movl    (%edx), %eax        # Move valor no endereço em %edx para %eax
    movl    %eax, %edx          # Move valor de %eax para %edx

    jmp     proximo

    alocar:
    pushl   %edx                # Backup de %edx
    pushl   tam_reg
    call    malloc

    addl    $4, %esp            # Retira tam_reg da pilha
    popl    %edx                # Recuperar %edx
    movl    $0, (%eax)          # Move 0 para o endereço do valor de %eax
    movl    %eax, (%edx)        # Move endereço em %eax para endereço do valor de %edx

    RET

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
liberar:


## Saída do programa
fim:                   
    movl $1, %eax               # eax <- sair
    xor %ebx, %ebx              # ebx <- saída sem erro
    int $0x80                   # Chamada de sistema
