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
    reg_bool:       .byte   0       # Tipo e garagem
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
    cont:           .int    0       # Contador da pos para remover registro
    filtrar:        .int    0       # 0 - não filtrar listagem, 1 - filtar (consulta)

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
    pede_remover:   .asciz  "Pos: "
    pede_consultar: .asciz  "Qtd quartos: "

    mostra_nome:    .asciz  "Nome: %s\n"
    mostra_cidade:  .asciz  "Cidade: %s\n"
    mostra_bairro:  .asciz  "Bairro: %s\n"
    mostra_celular: .asciz  "Celular: %s\n"
    mostra_tipo:    .asciz  "Tipo: %d\n"
    mostra_garagem: .asciz  "Garagem: %d\n"
    mostra_simples: .asciz  "Simples: %d\n"
    mostra_suites:  .asciz  "Suites: %d\n"
    mostra_metragem:.asciz  "Metragem: %d\n"
    mostra_aluguel: .asciz  "Aluguel: %.2f\n"

    mostra_id:      .asciz  "%d.\n"    

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

    movl    $49, qtd_bytes          # Inicia leituras de strings de 50 bytes

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

    movl    $11, qtd_bytes          # Le celular de 11 digitos

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

    movl    reg_int, %eax
    addl    %eax, qtd_quartos

    # Leitura da quantidade de suites
    pushl	$reg_int  
    pushl	$tipo_int 
    pushl	$pede_suites 
    call    pedir
    movl    reg_int, %eax
    movl    %eax, num_value

    call    ler_num

    movl    reg_int, %eax
    addl    %eax, qtd_quartos

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

# Le uma string do novo registro
ler_str:
    movl    qtd_bytes, %eax

    movb    $0, reg_str(%eax)

    # Define fonte (reg_str) e destino (regs_lst_cur) para escrita de nome no registro
    leal    reg_str, %esi              
    movl    cur_reg_addr, %edi
    addl    offset, %edi

    # Move valor de nome para endereco em regs_lst_cur
    movl    qtd_bytes, %ecx 
    rep     movsb

    movl    qtd_bytes, %eax
    addl    %eax, offset
    addl    $1, offset

    RET

# Le um booleano do novo registro
#ler_bool:
#    cmpb	$'s',%al
#	je		_start

# Le um numero do novo registro
ler_num:             
    movl    cur_reg_addr, %eax
    addl    offset, %eax

    movl    num_value, %ebx
    movl    %ebx, (%eax)

    movl    qtd_bytes, %eax
    addl    %eax, offset
    
    RET

# Posiciona registro alocado na pos da lista segundo o num de quartos (simples + suites)
ordenar:
    # Inicializacao
    # prev_reg_addr <- endereco do ponteiro para primeiro endereco da lista
    # next_reg_addr <- endereco do primeiro registro ou 0 (lista vazia)
    leal    regs_lst_first, %eax
    movl    regs_lst_first, %ebx

    movl    %eax, prev_reg_addr
    movl    %ebx, next_reg_addr

    proximo_ordenar:
    movl    next_reg_addr, %eax

    cmpl	$0, %eax
    je      inserir_na_pos

    ## Calcula quantidade de quartos (simples + suites) do registro atual

    # Calcula posicao da quantidade de quartos simples (%eax) e suites (%ebx)
    addl	$168, %eax

    movl    4(%eax), %ebx

    # Compara %eax com %ebx
    addl    (%eax), %ebx

    movl    qtd_quartos, %eax

    cmpl	%eax, %ebx              # %ebx >= %eax ?, %eax - qtd_quartos_inserir, %ebx - qtd_quartos_atual
    jge     inserir_na_pos

    # prev_reg_addr <- next_reg_addr; Salva next_reg_addr em prev_reg_addr
    movl    next_reg_addr, %eax
    movl    %eax, prev_reg_addr

    # next_reg_addr <- proximo; calcula proximo registro da lista 
    movl    (%eax), %ebx
    movl    %ebx, next_reg_addr

    jmp     proximo_ordenar

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
    # %eax <- endereco de regs_lst_first
    leal    regs_lst_first, %eax
    movl    %eax, cur_reg_addr

    # Print e scanf da pos a remover
    pushl   $pede_remover
    call    printf

    pushl   $cont
    pushl   $tipo_int
    call    scanf

    loop_remover:                   # loop para caminhar por elementos
    movl    cur_reg_addr, %eax
    cmpl    $0, (%eax)
    je      pos_invalida

    cmpl    $0, cont                # verifica posicao a remover
    je      remocao                 # se pos correta, pula para remocao

    decl    cont

    # pula para proximo registro
    movl    cur_reg_addr, %eax  
    movl    (%eax), %ebx
    movl    %ebx, cur_reg_addr

    jmp     loop_remover

    remocao:                        # remocao de fato  
    movl    cur_reg_addr, %eax      # %eax <- cur_reg_addr - pos anterior a removida
    movl    (%eax), %edx            # %edx <- cur_reg_addr + 1 pos
    movl    (%edx), %ebx            # %ebx <- cur_reg_addr + 2 pos

    movl    %ebx, (%eax)            # conecta cur_reg_addr com cur_reg_addr + 2 e pula cur_reg_addr + 1

    # remove pos %edx
    pushl   %edx
    call    free

    addl    $16, %esp

    RET

    pos_invalida:
    addl    $12, %esp

    RET

########## Listagem ##########
## Relatório de cadastros em memória
listar:
    movl    $0, cont

    # %eax <- endereco de regs_lst_first
    movl    regs_lst_first, %eax
    movl    %eax, cur_reg_addr

    proximo_listar:
    # Verifica se ha mais registros para listar
    movl    cur_reg_addr, %eax

    cmpl    $0, %eax
    je      fim_listar

    # Filtragem de quantidade de quartos diferentes
    cmpl    $0, filtrar
    je      nao_filtrar

    movl    cur_reg_addr, %eax
    movl    168(%eax), %ebx
    movl    172(%eax), %ecx
    addl    %ecx, %ebx

    cmpl    qtd_quartos, %ebx
    jne     filtro

    nao_filtrar:

    # Mostra registro
    call    mostrar_reg

    filtro:

    # Vai para prox registro
    movl    cur_reg_addr, %eax  
    movl    (%eax), %ebx
    movl    %ebx, cur_reg_addr

    incl    cont

    # Vai para prox iteracao
    jmp     proximo_listar

    fim_listar:

    RET


########## Consulta ##########

## Consulta de cadastro em memória
consultar:
    movl    $1, filtrar             # ativa filtro por quantidade de quartos

    pushl   $pede_consultar
    call    printf

    pushl   $qtd_quartos
    pushl   $tipo_int
    call    scanf

    call    listar

    movl    $0, filtrar             # remove filtro para execucoes posteriores

    addl    $12, %esp               # 1 (printf) + 2 (scanf)

    RET

## Gravação de cadastro em disco
gravar:

    RET

## Recuperação de cadastro em disco
recuperar:

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
    movl    cur_reg_addr, %esi

    addl    $4, %esi

    # Mostra id do registro
    pushl   cont
    pushl   $mostra_id
    call    printf

    # Mostra nome
    pushl   %esi
    pushl   $mostra_nome
    call    printf
    addl    $50, %esi

    # Mostra cidade
    pushl   %esi
    pushl   $mostra_cidade
    call    printf
    addl    $50, %esi

    # Mostra bairro
    pushl   %esi
    pushl   $mostra_bairro
    call    printf
    addl    $50, %esi

    # Mostra celular
    pushl   %esi
    pushl   $mostra_celular
    call    printf
    addl    $12, %esi

    break1:

    # Mostra tipo
    movl    (%esi), %eax

    movzbl  %al, %eax
    pushl   %eax
    pushl   $mostra_tipo
    call    printf
    addl    $1, %esi

    # Mostra garagem
    movl    (%esi), %eax

    movzbl  %al, %eax
    pushl   %eax
    pushl   $mostra_garagem
    call    printf
    addl    $1, %esi

    # Mostra quantidade de quartos simples
    pushl   (%esi)
    pushl   $mostra_simples
    call    printf
    addl    $4, %esi

    # Mostra quantiade de suites
    pushl   (%esi)
    pushl   $mostra_suites
    call    printf
    addl    $4, %esi

    # Mostra metragem
    pushl   (%esi)
    pushl   $mostra_metragem
    call    printf
    addl    $4, %esi

    # Mostra aluguel
    flds    (%esi)
    fstpl   (%esp)
    pushl   $mostra_aluguel
    call    printf

    addl    $84, %esp               # 11 x 2 x 4 = 84

    RET


