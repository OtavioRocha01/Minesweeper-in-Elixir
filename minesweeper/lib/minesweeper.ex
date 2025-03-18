# TODO: implementar para marcar as minas no tabuleiro
defmodule Minesweeper do
  # PRIMEIRA PARTE - FUNÇÕES PARA MANIPULAR OS TABULEIROS DO JOGO (MATRIZES)
  def get_arr([h|_t], 0), do: h
  def get_arr([_h|t], n), do: get_arr(t, n-1)


  def update_arr([_h|t],0,v), do: [v|t]
  def update_arr([h|t],n,v), do: [h] ++ update_arr(t,n-1,v)


  def get_pos(tab, l, c), do: get_arr(get_arr(tab, l), c)


  def update_pos(tab,l,c,v), do: update_arr(tab, l, update_arr(get_arr(tab, l), c, v))

  # SEGUNDA PARTE: LÓGICA DO JOGO

  #-- is_mine/3: recebe um tabuleiro com o mapeamento das minas, uma linha, uma coluna. Devolve true caso a posição contenha
  # uma mina e false caso contrário. Usar get_pos/3 na implementação
  #
  # Exemplo de tabuleiro de minas:
  #
  # _mines_board = [[false, false, false, false, false, false, false, false, false],
                  #   [false, false, false, false, false, false, false, false, false],
                  #  [false, false, false, false, false, false, false, false, false],
                  #  [false, false, false, false, false, false, false, false, false],
                  #  [false, false, false, false, true , false, false, false, false],
                  #  [false, false, false, false, false, true, false, false, false],
                  #  [false, false, false, false, false, false, false, false, false],
                  #  [false, false, false, false, false, false, false, false, false],
                  #  [false, false, false, false, false, false, false, false, false]]
  #
  # esse tabuleiro possuí minas nas posições 4x4 e 5x5

  def is_mine(tab,l,c), do: get_pos(tab, l, c)


  def is_valid_pos(tamanho,l,c), do: (tamanho - 1) >= l and (tamanho - 1) >= c and l >= 0 and c >= 0


  def valid_moves(tam, l, c) do
    adjacent_positions = [
      {l-1, c-1}, {l-1, c}, {l-1, c+1},
      {l, c-1},           {l, c+1},
      {l+1, c-1}, {l+1, c}, {l+1, c+1}
    ]

    Enum.filter(adjacent_positions, fn {x, y} -> is_valid_pos(tam, x, y) end)
  end


  def conta_minas_adj(tab,l,c) do
    valid_moves(arr_size(tab), l, c)
    |> Enum.reduce(0, fn {x, y}, acc -> if is_mine(tab, x, y), do: acc + 1, else: acc end)
  end


  def arr_size(arr), do: Enum.count(arr)

  # abre_jogada/4: é a função principal do jogo!!
  # recebe uma posição a ser aberta (linha e coluna), o mapa de minas e o tabuleiro do jogo. Devolve como
  # resposta o tabuleiro do jogo modificado com essa jogada.
  # Essa função é recursiva, pois no caso da entrada ser uma posição sem minas adjacentes, o algoritmo deve
  # seguir abrindo todas as posições adjacentes até que se encontre posições adjacentes à minas.
  # Vamos analisar os casos:
  # - Se a posição a ser aberta é uma mina, o tabuleiro não é modificado e encerra
  # - Se a posição a ser aberta já foi aberta, o tabuleiro não é modificado e encerra
  # - Se a posição a ser aberta é adjacente a uma ou mais minas, devolver o tabuleiro modificado com o número de
  # minas adjacentes na posição aberta
  # - Se a posição a ser aberta não possui minas adjacentes, abrimos ela com zero (0) e recursivamente abrimos
  # as outras posições adjacentes a ela
  def abre_jogada(l,c,minas,tab) do
    cond do
      is_mine(minas, l, c) -> tab
      get_pos(tab, l, c) != "-" -> tab
      (minas_adj = conta_minas_adj(minas, l, c)) > 0 ->
        update_pos(tab, l, c, minas_adj)
      true -> valid_moves(arr_size(tab), l, c)
              |> Enum.reduce(update_pos(tab, l, c, 0), fn {l, c}, acc -> abre_jogada(l, c, minas, acc) end)
    end
  end

# abre_posicao/4, que recebe um tabuleiro de jogos, o mapa de minas, uma linha e uma coluna
# Essa função verifica:
# - Se a posição {l,c} já está aberta (contém um número), então essa posição não deve ser modificada
# - Se a posição {l,c} contém uma mina no mapa de minas, então marcar  com "*" no tabuleiro
# - Se a posição {l,c} está fechada (contém "-"), escrever o número de minas adjascentes a esssa posição no tabuleiro (usar conta_minas)
  def abre_posicao(tab,minas,l,c) do
    cond do
      is_mine(minas, l, c) -> update_pos(tab, l, c, "*")
      get_pos(tab, l, c) != "-" -> tab
      true -> update_pos(tab, l, c, conta_minas_adj(minas, l, c))
    end
  end



# abre_tabuleiro/2: recebe o mapa de Minas e o tabuleiro do jogo, e abre todo o tabuleiro do jogo, mostrando
# onde estão as minas e os números nas posições adjecentes às minas.Essa função é usada para mostrar todo o tabuleiro no caso de vitória ou derrota.
# Para implementar esta função, usar a função abre_posicao/4

  def abre_tabuleiro(minas,tab) do
    Enum.reduce(0..(arr_size(tab)-1), tab, fn l, acc_tab ->
      Enum.reduce(0..(arr_size(tab)-1), acc_tab, fn c, acc_tab_inner ->
        abre_posicao(acc_tab_inner, minas, l, c)
      end)
    end)
    tab
  end

# board_to_string/1: -- Recebe o tabuleiro do jogo e devolve uma string que é a representação visual desse tabuleiro.
  def board_to_string(tab) do
    IO.write("  ")
    for i <- 0..(arr_size(tab)-1) do
      IO.write("  " <> Integer.to_string(i) <> " ")
    end
    IO.write("\n")
    print_separador(arr_size(tab))
    for i <- 0..(arr_size(tab)-1) do
      print_linha(tab, i)
    end
    print_separador(arr_size(tab))
  end

  def print_linha(tab, l) do
    IO.write(Integer.to_string(l) <> " ")
    for i <- 0..(arr_size(tab)-1) do
      IO.write("| ")
      IO.write(get_pos(tab, l, i))
      IO.write(" ")
    end
    IO.puts("|")
  end

  def print_separador(tam) do
    IO.write("  ")
    for _i <- 0..(tam - 1) do
      IO.write("----")
    end
    IO.write("-\n")
  end

# gera_lista/2: recebe um inteiro n, um valor v, e gera uma lista contendo n vezes o valor v
  def gera_lista(0,_v), do: []
  def gera_lista(n,v), do: [v] ++ gera_lista(n-1,v)

# -- gera_tabuleiro/1: recebe o tamanho do tabuleiro de jogo e gera um tabuleiro  novo, todo fechado (todas as posições
# contém "-"). Usar gera_lista
  def gera_tabuleiro(n), do: gera_lista(n, gera_lista(n, "-"))



# -- gera_mapa_de_minas/1: recebe o tamanho do tabuleiro e gera um mapa de minas zero, onde todas as posições contém false
  def gera_mapa_de_minas(n), do: gera_lista(n, gera_lista(n, false))


# conta_fechadas/1: recebe um tabueleiro de jogo e conta quantas posições fechadas existem no tabuleiro (posições com "-")
  def conta_fechadas(tab) do
    Enum.reduce(tab, 0, fn l, acc -> acc + Enum.count(l, fn x -> x == "-" end) end)
  end

# -- conta_minas/1: Recebe o tabuleiro de Minas (MBoard) e conta quantas minas existem no jogo
  def conta_minas(minas) do
    Enum.reduce(minas, 0, fn l, acc -> acc + Enum.count(l, fn x -> x == true end) end)
  end

  def conta_marcadas(tab) do
    Enum.reduce(tab, 0, fn l, acc -> acc + Enum.count(l, fn x -> x == "*" end) end)
  end

# end_game?/2: recebe o tabuleiro de minas, o tauleiro do jogo, e diz se o jogo acabou.
# O jogo acabou quando o número de casas fechadas é igual ao numero de minas
  def end_game(minas,tab), do: conta_fechadas(tab) + conta_marcadas(tab) == conta_minas(minas)

#### fim do módulo
end

###################################################################
###################################################################

# A seguir está o motor do jogo!

defmodule Motor do
  def main() do
   v = IO.gets("Digite o tamanho do tabuleiro: \n")
   {size,_} = Integer.parse(v)
   minas = gen_mines_board(size)
   IO.inspect minas # descomente para ver onde estão as minas
   tabuleiro = Minesweeper.gera_tabuleiro(size)
   game_loop(minas,tabuleiro)
  end
  def game_loop(minas,tabuleiro) do
    IO.puts Minesweeper.board_to_string(tabuleiro)
    opt = IO.gets("Digite 'm' para marcar uma mina, 'a' para abrir uma posição: \n")
    v = IO.gets("Digite uma linha: \n")
    {linha,_} = Integer.parse(v)
    v = IO.gets("Digite uma coluna: \n")
    {coluna,_} = Integer.parse(v)
    if opt == "m\n" do # marcar mina
      game_loop(minas,Minesweeper.update_pos(tabuleiro,linha,coluna,"*"))
    else
      if (linha < 0) or (linha >= Minesweeper.arr_size(tabuleiro)) or (coluna < 0) or (coluna >= Minesweeper.arr_size(tabuleiro)) do
        IO.puts "Posição inválida"
        game_loop(minas,tabuleiro)
      else
        if (Minesweeper.get_pos(tabuleiro, linha, coluna) == "*") do
          game_loop(minas,tabuleiro)
        else
          if (Minesweeper.is_mine(minas,linha,coluna)) do
            IO.puts "VOCÊ PERDEU!!!!!!!!!!!!!!!!"
            IO.puts Minesweeper.board_to_string(Minesweeper.abre_tabuleiro(minas,tabuleiro))
            IO.puts "TENTE NOVAMENTE!!!!!!!!!!!!"
          else
            novo_tabuleiro = Minesweeper.abre_jogada(linha,coluna,minas,tabuleiro)
            if (Minesweeper.end_game(minas,novo_tabuleiro)) do
                IO.puts "VOCÊ VENCEU!!!!!!!!!!!!!!"
                IO.puts Minesweeper.board_to_string(Minesweeper.abre_tabuleiro(minas,novo_tabuleiro))
                IO.puts "PARABÉNS!!!!!!!!!!!!!!!!!"
            else
                game_loop(minas,novo_tabuleiro)
            end
          end
        end
      end
    end
  end
  def gen_mines_board(size) do
    add_mines(ceil(size*size*0.15), size, Minesweeper.gera_mapa_de_minas(size))
  end
  def add_mines(0,_size,mines), do: mines
  def add_mines(n,size,mines) do
    linha = :rand.uniform(size-1)
    coluna = :rand.uniform(size-1)
    if Minesweeper.is_mine(mines,linha,coluna) do
      add_mines(n,size,mines)
    else
      add_mines(n-1,size,Minesweeper.update_pos(mines,linha,coluna,true))
    end
  end
end

Motor.main()
