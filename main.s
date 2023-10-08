## Autores 
# Arthur Belini Pini - RA118999
# Pedro Lucas Keizo Honda - RA119188

## Struct do registro
# nome - 50B
# celular - 11B 
#
# tipo - 1B (casa - 0, apto. - 1)
# garagem - 1B (nao - 0, sim - 1)
#
# endereco - struct: cidade + bairro - 50B + 50B - 100B 
# quartos - struct: simples + suite - 4B + 4B - 8B
# metragem - 4B
#
# aluguel - 4B
#
# Total: 50B + 11B + 1B + 100B + 8B + 1B + 4B + 4B = 179B

.section .data
    nome:       .space  50
    celular:    .space  11

    tipo:       .byte   1
    garagem:    .byte   1   

    endereco:   .int    0       # Ponteiro para pos inicial da struct endereco
    quartos:    .int    0       # Ponteiro para pos inicial da struct quartos
    metragem:   .int    0

    aluguel:    .float  0.0

    tam_reg:    .int    179

    menu_str:   .asciz "Menu de Opcoes\n<1> Inserir\n<2> Remover\n<3> Consultar\n<4> Gravar\n<5> Recuperar\n<6> Listar\n<7> Sair\nDigite opcao => "

    teste: 	    .asciz  "%d\n"

    opcao:      .int    0

    tipo_int:    .asciz  "%d"

.section .text

.globl _start

## Inicialização do programa - Menu de ações
_start:
    call    menu                # Recebe opcao

    call    tratar_opcoes       # Executa opcao

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

## Inserção de cadastro  em memória
inserir:
    movl    $1, %eax

    pushl   %eax
	pushl   $teste
	call    printf

    addl    $8, %esp

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

## Saída do programa
fim:                   
    movl $1, %eax               # eax <- sair
    xor %ebx, %ebx              # ebx <- saída sem erro
    int $0x80                   # Chamada de sistema
