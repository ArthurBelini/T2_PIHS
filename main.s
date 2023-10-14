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
    next_reg_addr:  .int    0       # Ponteiro para prox pos a atual da lista de registros
    prev_reg_addr:  .int    0       # Ponteiro para pos anterior a atual da lista de registros
    cur_reg_addr:   .int    0       # Ponteiro para pos atual da lista de registros

    offset:         .int    0       # Deslocamento atual do registro atual
    qtd_bytes:      .int    0       # Quantidade de bytes lidos
    num_value:      .int    0       # Valor de um campo numerico do registro
    qtd_quartos:    .int    0       # Quantidade de quartos (simples + suites) no novo registro
    cont:           .int    0       # Contador da pos para remover registro
    filtrar:        .int    0       # 0 - não filtrar listagem, 1 - filtar (consulta)
    read_buffer:    .space  180     # Buffer de leitura de registro de arquivo
    tam_reg:        .int    184     # Qtd de bytes do registro
    opcao:          .int    0       # Opcao escolhida pelo usuario

    ## Strings
    menu_str:       .asciz  "Menu de Opcoes\n<1> Inserir\n<2> Remover\n<3> Consultar\n<4> Gravar\n<5> Recuperar\n<6> Listar\n<7> Sair\nDigite opcao => "
    jmp_line:       .asciz  "\n"

    tipo_int:       .asciz  "%d"
    tipo_str:       .asciz  "%s"
    tipo_bool:      .asciz  "%d"
    tipo_float:     .asciz  "%f"

    pede_nome:      .asciz  "Nome (sem espaco): "
    pede_celular:   .asciz  "Celular (11 digitos): "
    pede_cidade:    .asciz  "Cidade (sem espaco): "
    pede_bairro:    .asciz  "Bairro (sem espaco): "
    pede_tipo:      .asciz  "Tipo (0 - casa, 1 - apto.): "
    pede_garagem:   .asciz  "Garagem (0 - sem, 1 - com): "
    pede_metragem:  .asciz  "Metragem: "
    pede_simples:   .asciz  "Simples: "
    pede_suites:    .asciz  "Suites: "
    pede_aluguel:   .asciz  "Aluguel: "
    pede_remover:   .asciz  "Pos: "
    pede_consultar: .asciz  "Qtd quartos: "

    mostra_id:      .asciz  "%d.\n" # Posicao do registro na lista encadeada                
    mostra_nome:    .asciz  "Nome: %s\n"
    mostra_cidade:  .asciz  "Cidade: %s\n"
    mostra_bairro:  .asciz  "Bairro: %s\n"
    mostra_celular: .asciz  "Celular: %s\n"
    mostra_tipo:    .asciz  "Tipo: %s\n"
    mostra_garagem: .asciz  "Garagem: %s\n"
    mostra_simples: .asciz  "Simples: %d\n"
    mostra_suites:  .asciz  "Suites: %d\n"
    mostra_metragem:.asciz  "Metragem: %d\n"
    mostra_aluguel: .asciz  "Aluguel: %.2f\n"
    mostra_casa:    .asciz  "casa"
    mostra_apto:    .asciz  "apto."
    mostra_sem:     .asciz  "nao"
    mostra_com:     .asciz  "sim"

    regs_filename:  .asciz  "registros.txt"


.section .bss
    .lcomm filehandle, 4            # Ponteiro para arquivo para gravar e recuperar

.section .text

.globl _start

# Chama funções principais
_start:
    call    menu                    # Recebe opcao

    call    tratar_opcoes           # Executa opcao

    # Pula uma linha
    pushl	$jmp_line               
	call	printf

    jmp     _start

# Imprime menu e recebe opcao
menu:
    pushl	$menu_str
	call	printf

    pushl	$opcao
	pushl	$tipo_int
	call	scanf

    addl    $12, %esp

    RET

# Recebe opcao e redireciona acao
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

# Inserção de registro em memória
# Aloca, recebe dados e ordena registro na lista encadeada
inserir:
    # Restauracao de variaveis
    movl    $4, offset              # Offset do primeiro campo do registro
    movl    $0, qtd_quartos         # Reseta contador de qtd_quartos

    # Aloca memoria para novo registro
    call    alocar                  # Aloca registro e poe em cur_reg_addr

    ## Inicia leituras de strings de 50 (49 chars + 1 \0) bytes
    movl    $49, qtd_bytes          

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

    ## Le celular de 11 digitos
    movl    $11, qtd_bytes          

    # Leitura do celular
    pushl	$reg_str 
    pushl	$tipo_str
    pushl	$pede_celular  
    call    pedir

    call    ler_str

    ## Inicia leituras de booleanos de 1 byte
    movl    $1, qtd_bytes           

    # Leitura do tipo
    pushl	$reg_bool
    pushl	$tipo_bool  
    pushl	$pede_tipo
    call    pedir

    movl    reg_bool, %eax
    movl    %eax, num_value
    call    ler_bool

    # Leitura da existencia de garagem
    pushl	$reg_bool
    pushl	$tipo_bool
    pushl	$pede_garagem
    call    pedir

    movl    reg_bool, %eax
    movl    %eax, num_value
    call    ler_bool

    ## Inicia leituras de ints e floats de 4 byte
    movl    $4, qtd_bytes           

    # Leitura de quantidade de quartos simples
    pushl	$reg_int
    pushl	$tipo_int 
    pushl	$pede_simples 
    call    pedir

    movl    reg_int, %eax
    movl    %eax, num_value
    call    ler_num

    # Leitura da quantidade de suites
    pushl	$reg_int  
    pushl	$tipo_int 
    pushl	$pede_suites 
    call    pedir

    movl    reg_int, %eax
    movl    %eax, num_value
    call    ler_num

    # Calcula quantidade de quartos (simples + suites)
    call    calc_qtd_quartos

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
    call    ordenar                 # Poe a memoria alocada na pos de acordo com num de quartos (simples + suites)

    RET

# Aloca memoria para novo registro
alocar:
    # Aloca 184 bytes
    pushl   tam_reg
    call    malloc

    movl    %eax, cur_reg_addr      # cur_reg_addr <- endereco da memoria alocada 

    addl    $4, %esp

    RET

# Pede string do novo registro
pedir:
    popl    %ebx                    # Faz backup do endereco de retorno da funcao para poder fazer printf

    # Imprime pedido de string
    call	printf
    addl    $4, %esp

	call	scanf                   # Le string

    addl    $8, %esp

    pushl   %ebx                    # Recupera endereco de retorno da funcao

    RET

# Le uma string do novo registro
ler_str:
    # Inserir marcador de fim de string (\0) ao fim da string
    movl    qtd_bytes, %eax         # qtd_bytes = ultima pos de reg_str atual (11 - celular ou 49 - outros)
    movb    $0, reg_str(%eax)       # Move \0 a posicao qtd_bytes de reg_str

    ## Define fonte (reg_str) e destino (cur_reg_addr) para escrita de campo no registro
    leal    reg_str, %esi           # Fonte de dados

    # Destino de dados
    movl    cur_reg_addr, %edi      
    addl    offset, %edi            # Move ate pos correta de campo atual do destino

    # Move valor de nome para endereco em cur_reg_addr
    movl    qtd_bytes, %ecx         # Qtd de repeticoes de rep abaixo
    rep     movsb                   # Repete a instrucao movsb (mover 1 byte) cur_reg_addr/%ecx vezes

    # Atualizar offset para proxima escrita
    movl    qtd_bytes, %eax
    addl    %eax, offset
    incl    offset                  # 49 escritos + \0

    RET

# Le um booleano do novo registro
ler_bool:
    # Verifica valores booleanos invalidos
    movl    reg_bool, %eax

    cmpb	$0, %al
	je		opcao_valida
    cmpb	$1, %al
	je		opcao_valida

    jmp     fim_erro                # Se nao 0 e nao 1, pula para fim com erro

    opcao_valida:
    movl    cur_reg_addr, %edi
    addl    offset, %edi            # Move ate pos correta de cur_reg_addr

    movb     %al, (%edi)            # valor em cur_reg_addr <- byte inferior de %eax (valor lido)

    # Atualiza offset no registro para proxima escrita
    movl    qtd_bytes, %eax
    addl    %eax, offset

    RET

# Le um numero do novo registro
ler_num:      
    # Posiciona na pos correta do registro       
    movl    cur_reg_addr, %eax
    addl    offset, %eax

    # Insere valor na pos correta
    movl    num_value, %ebx
    movl    %ebx, (%eax)

    # Atualiza offset
    movl    qtd_bytes, %eax
    addl    %eax, offset
    
    RET

########## Remoção ##########

# Remoção de cadastro em memória
remover:
    # cur_reg_addr <- endereco de regs_lst_first
    leal    regs_lst_first, %eax    
    movl    %eax, cur_reg_addr

    # Print e scanf da pos a remover (contador decrementado a cada iteracao)
    pushl   $pede_remover
    call    printf

    pushl   $cont
    pushl   $tipo_int
    call    scanf

    loop_remover:                   # loop para caminhar por elementos
    # Se lista encadeada esta vazia ou chega ao fim, termina
    movl    cur_reg_addr, %eax
    cmpl    $0, (%eax)              
    je      pos_invalida

    # Se chega na pos correta (contador = 0), remove
    cmpl    $0, cont
    je      remocao

    decl    cont

    # pula para proximo registro, endereco do registro atual recebe do prox
    movl    cur_reg_addr, %eax  
    movl    (%eax), %ebx
    movl    %ebx, cur_reg_addr

    jmp     loop_remover

    # Registro atual e removido e anterior do atual passa a apontar para posterior do atual
    remocao: 
    movl    cur_reg_addr, %eax      # %eax <- cur_reg_addr = pos anterior a removida
    movl    (%eax), %edx            # %edx <- cur_reg_addr = pos a ser removida
    movl    (%edx), %ebx            # %ebx <- cur_reg_addr = pos posterior a removida

    movl    %ebx, (%eax)            # Anterior ao removido passa a apontar para posterior ao removido

    # remove pos %edx
    pushl   %edx
    call    free

    addl    $16, %esp

    RET

    pos_invalida:
    addl    $12, %esp               # Um pushl a menos, da remocao

    RET

########## Listagem ##########

# Relatório de cadastros em memória
# Funciona para o relatorio de registros e para consulta pela qtd_quartos
# Se filtrar = 0 funciona como relatorio, se filtrar = 1 funciona como consulta
listar:
    movl    $0, cont                # Representa id do registro, pos na lista encadeada

    # cur_reg_addr <- endereco de regs_lst_first
    movl    regs_lst_first, %eax
    movl    %eax, cur_reg_addr

    proximo_listar:
    # Verifica se ha mais registros para listar
    movl    cur_reg_addr, %eax

    cmpl    $0, %eax                # 0 representa fim da lista encadeada
    je      fim_listar

    ## Filtragem de quantidade de quartos diferentes
    # Verifica valor de filtrar; se nao esta filtrando, pula para mostrar registro independentemente
    cmpl    $0, filtrar
    je      nao_filtrar

    # %ebx <- qtd de quartos do registro atual na lista encadeada
    movl    cur_reg_addr, %eax
    movl    168(%eax), %ebx
    movl    172(%eax), %ecx
    addl    %ecx, %ebx

    # Compara qtd_quartos (digitado pelo usuario) e %ebx (qtd de quartos do registro atual)
    # Se nao sao iguais, filtra registro atual e nao mostra
    cmpl    qtd_quartos, %ebx
    jne     filtro

    nao_filtrar:

    call    mostrar_reg             # Mostra registro

    filtro:                         # Pula mostrar registro

    # Vai para prox registro
    movl    cur_reg_addr, %eax  
    movl    (%eax), %ebx
    movl    %ebx, cur_reg_addr

    incl    cont

    jmp     proximo_listar

    fim_listar:

    RET


########## Consulta ##########

# Consulta de cadastro em memória
# Le qtd_quartos consultado e chama listar com filtro = 1
consultar:
    movl    $1, filtrar             # ativa filtro por quantidade de quartos

    # Pede qtd_quartos
    pushl   $pede_consultar
    call    printf

    # Le qtd_quartos
    pushl   $qtd_quartos
    pushl   $tipo_int
    call    scanf

    call    listar

    movl    $0, filtrar             # remove filtro para execucoes posteriores

    addl    $12, %esp               # 1 (printf) + 2 (scanf)

    RET

########## Gravacao ##########

# Gravacao de cadastro em disco
gravar:
    ## Abrir arquivo para leitura

    # Setando flags
    movl    $5, %eax                # Flag para system call para abrir arquivos
    movl    $regs_filename, %ebx    # Nome do arquivo, regs_filename
    movl    $0101 | 01000, %ecx     # Sobrescreve; somente para escrita
    movl    $0666, %edx             # Permissao de execucao e escrita para todos

    int     $0x80                   # Chamada de sistema

    # Teste de erro de abertura de arquivo
    test    %eax, %eax
    js      fim_erro

    movl    %eax, filehandle        # Move ponteiro para arquivo em filehandle

    ## Loop pelos registros

    # cur_reg_addr <- regs_lst_first
    movl    regs_lst_first, %eax
    movl    %eax, cur_reg_addr

    proximo_gravar:
    cmpl    $0, cur_reg_addr        # 0 representa fim da lista encadeada
    je      fechar_arquivo_gravar

    ### Leitura do arquivo

    ## Setando flags
    
    # %ecx <- endereco do registro deslocado pela pos do primeiro campo
    movl    cur_reg_addr, %ecx
    addl    $4, %ecx                # Pula primeiros 4 bytes (endereco do prox registro)

    movl    $4, %eax                # Flag de escrita em arquivo
    movl    filehandle, %ebx        # %ebx <- filehandle
    movl    $180, %edx              # %edx <- quantidadade de bytes que serao lidos
    int     $0x80                   # Chamada de sistema

    # Teste de erri de escrita
    test    %eax, %eax              
    js      fim_erro

    # Ir para proximo registro
    # cur_reg_addr <- prox registro
    movl    cur_reg_addr, %eax
    movl    (%eax), %ebx
    movl    %ebx, cur_reg_addr

    jmp     proximo_gravar

    # Fechar arquivo
    fechar_arquivo_gravar:
    movl    $6, %eax                # Flag de fechar arquivo
    movl    filehandle, %ebx        # %ebx <- filehandle
    int     $0x80                   # Chamada de sistema

    fim_gravar:
    RET

########## Recuperacao ##########

# Recuperação de cadastro em disco
recuperar:
    # Ao recuperar, os registros em memoria sao deletados; comentar esta linha para isso nao acontecer
    call    liberar                 

    ## Abrir arquivo para escrita

    # Setando flags
    movl    $5, %eax                # Flag para system call para abrir arquivos
    movl    $regs_filename, %ebx    # Nome do arquivo, regs_filename
    movl    $0100, %ecx             # Cria se nao existe; somente para leitura
    movl    $0555, %edx             # Permissao de execucao e leitura para todos

    # Chamada de sistema
    int     $0x80                   # Chamada de sistema

    # Teste de erro de abertura de arquivo
    test    %eax, %eax
    js      fim_erro

    movl    %eax, filehandle        # Move ponteiro para arquivo em filehandle

    # Loop de leitura de registros
    proximo_recuperar:
    movl    $read_buffer, %ecx      # %ecx <- buffer dos dados lidos

    movl    $3, %eax                # Flag de leirura de arquivo
    movl    filehandle, %ebx        # ebx <- filehandle
    movl    $180, %edx              # %edx <- qtd de bytes que serao lidos
    int     $0x80                   # Chamada de sistema

    # Verifica se ha dados no arquivo ou se chegou no fim do arquivo
    cmpl    $0, %eax                # Se valor em %eax <= 0, significa que chegou ao fim do arquivo
    jle     fechar_arquivo_recuperar

    # Alocar novo registro e deslocar para pos correta de dados
    call    alocar

    movl    %eax, cur_reg_addr      # %eax <- endereco alocado
    addl    $4, %eax                # Deslocar para posicao de dados

    # Escreve do buffer para memoria alocada
    leal    read_buffer, %esi       # Fonte de dados
    movl    %eax, %edi              # Destino de dados
    movl    $180, %ecx              # Qtd de execucoes de rep
    rep     movsb                   # Escreve 180 bytes do buffer para memoria alocada

    # Ordena registro lido do arquivo em memoria na lista encadeada atraves de qtd_quartos
    call    calc_qtd_quartos        # qtd_quartos <- quantidade de quartos (simples + suites) do registro lido
    call    ordenar                 # Insere registro na lista

    jmp     proximo_recuperar

    # Fechar arquivo
    fechar_arquivo_recuperar:
    movl    $6, %eax                # Flag para fechar arquivo
    movl    filehandle, %ebx        # %ebx <- filehandle
    int     $0x80                   # Chamada de sistema

    RET

# Saída do programa sem erros
fim:
    call liberar                    # Libera lista de registros
               
    movl $1, %eax                   # eax <- sair
    movl $0, %ebx                   # ebx <- saída sem erro
    int $0x80                       # Chamada de sistema

########## Auxiliares (utilizadas por diferentes acoes) ##########

# Calcula quantidade de quartos (simples + suites) do endereco em cur_reg_addr
calc_qtd_quartos:
    movl    cur_reg_addr, %eax      # %eax <- cur_reg_addr

    addl	$168, %eax              # Desloca para pos de quartos simples

    movl    4(%eax), %ebx           # %ebx <- %eax deslocado para pos de suites

    addl    (%eax), %ebx            # Soma (%eax) (simples) com %ebx (suites)

    movl    %ebx, qtd_quartos       # qtd_quartos <- soma

    RET

# Libera lista
# Caminha pela lista enquanto libera os nós
# Em geral, inverso de inserir
liberar:
    movl    regs_lst_first, %edx    # %edx <- regs_lst_first

    proximo_liberar:
    cmpl	$0, %edx                # 0 representa fim da lista
    je      fim_lst_liberar         # Caso 0, pula para fim_lst

    movl    (%edx), %ebx            # Backup da prox pos da lista

    pushl   %edx                    # Endereço de %edx que se deseja liberar para pilha
    call    free

    movl    %ebx, %edx              # Recupera prox pos da lista

    addl    $4, %esp

    jmp     proximo_liberar

    fim_lst_liberar:
    movl    $0, regs_lst_first      # Restaura regs_lst_first

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

    # Se lista vazia ou chegou no fim, insere na pos atual
    cmpl	$0, %eax                
    je      inserir_na_pos

    ## Calcula quantidade de quartos (simples + suites) do registro atual

    # Calcula posicao da quantidade de quartos simples (%eax) e suites (%ebx)
    addl	$168, %eax
    movl    4(%eax), %ebx

    # Compara %eax com %ebx
    addl    (%eax), %ebx

    movl    qtd_quartos, %eax       # qtd_quartos lido pelo usuario (consultar) ou calculado pela entrada do usuario (insercao)

    # Se qtd_quartos a inserir e menor ou igual do registro atual, pos correta para inserir
    cmpl	%eax, %ebx              # %ebx >= %eax ?, %eax = qtd_quartos_inserir, %ebx = qtd_quartos_atual
    jge     inserir_na_pos          

    # prev_reg_addr <- next_reg_addr; salva next_reg_addr em prev_reg_addr
    movl    next_reg_addr, %eax
    movl    %eax, prev_reg_addr

    # next_reg_addr <- proximo; calcula proximo registro da lista 
    movl    (%eax), %ebx
    movl    %ebx, next_reg_addr

    jmp     proximo_ordenar

    # Registro anterior ao atual passa a apontar para atual e atual ao seu posterior
    inserir_na_pos:
    movl    cur_reg_addr, %eax

    # Anterior aponta para atual
    movl    prev_reg_addr, %ebx
    movl    %eax, (%ebx)

    # Atual aponta para posterior
    movl    next_reg_addr, %ebx
    movl    %ebx, (%eax)

    RET

# Finaliza programa com codigo de erro
fim_erro:
    call    liberar                 # Libera lista de registros

    movl    $1, %eax                # eax <- sair
    movl    $1, %ebx                # ebx <- saída com erro
    int     $0x80                   # Chamada de sistema

# Mostra registro no endereco de cur_reg_addr
mostrar_reg:
    movl    cur_reg_addr, %esi

    addl    $4, %esi                # Desloca para pos de dados do registro

    # Mostra id do registro
    pushl   cont                    # cont representa id do registro atual
    pushl   $mostra_id
    call    printf

    # Mostra nome
    pushl   %esi
    pushl   $mostra_nome
    call    printf

    addl    $50, %esi               # Desloca para prox campo

    # Mostra cidade
    pushl   %esi
    pushl   $mostra_cidade
    call    printf

    addl    $50, %esi               # Desloca para prox campo

    # Mostra bairro
    pushl   %esi
    pushl   $mostra_bairro
    call    printf

    addl    $50, %esi               # Desloca para prox campo

    # Mostra celular
    pushl   %esi
    pushl   $mostra_celular
    call    printf

    addl    $12, %esi               # Desloca para prox campo

    # Mostra tipo
    # 0 = mostra casa, 1 = mostra apto.
    movl    (%esi), %eax

    # Verifica se tipo = casa
    cmpb	$0, %al
	je		casa

    # Se nao for casa, mostra apto.
    pushl   $mostra_apto
    jmp     print_tipo

    casa:
    pushl   $mostra_casa

    print_tipo:
    pushl   $mostra_tipo
    call    printf

    addl    $1, %esi                # Desloca para prox campo

    # Mostra garagem
    # 0 = sem, 1 = mostra com
    movl    (%esi), %eax

    # Verifica se garagem = sem
    cmpb	$0, %al
	je		sem

    # Se nao for sem, mostra com
    pushl   $mostra_com
    jmp     print_garagem

    sem:
    pushl   $mostra_sem

    print_garagem:
    pushl   $mostra_garagem
    call    printf

    addl    $1, %esi                # Desloca para prox campo

    # Mostra quantidade de quartos simples
    pushl   (%esi)
    pushl   $mostra_simples
    call    printf

    addl    $4, %esi                # Desloca para prox campo

    # Mostra quantiade de suites
    pushl   (%esi)
    pushl   $mostra_suites
    call    printf

    addl    $4, %esi                # Desloca para prox campo

    # Mostra metragem
    pushl   (%esi)
    pushl   $mostra_metragem
    call    printf

    addl    $4, %esi                # Desloca para prox campo

    # Mostra aluguel
    flds    (%esi)
    fstpl   (%esp)
    pushl   $mostra_aluguel

    call    printf

    addl    $84, %esp               # 11 x 2 x 4 = 84

    RET
