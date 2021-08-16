defmodule Sudoku do
  @moduledoc """
  Sudoku keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defstruct [state: %{}, moves: [], tries: 0]

  @type t :: %Sudoku{state: map(), moves: list(), tries: integer()}

  def new(state) do
    %Sudoku{
      state: state
    }
  end

  @doc """
     0  1  2   3  4  5   6  7  8
  0 ( )( )( )|( )( )( )|( )( )( )
  1 ( )( )( )|( )( )( )|( )( )( )
  2 ( )( )( )|( )( )( )|( )( )( )
    ---------|---------|---------
  3 ( )( )( )|( )( )( )|( )( )( )
  4 ( )( )( )|( )( )( )|( )( )( )
  5 ( )( )( )|( )( )( )|( )( )( )
    ---------|---------|---------
  6 ( )( )( )|( )( )( )|( )( )( )
  7 ( )( )( )|( )( )( )|( )( )( )
  8 ( )( )( )|( )( )( )|( )( )( )
  """
  @spec to_sudoku(String.t(), atom()) :: {:ok, Sudoku.t()} | {:error, String.t()}
  def to_sudoku(string, :grid) do
    matches = Regex.scan(~r/\(([1-9 ]| )\)/, string)
              |> Enum.map(
                   fn
                     [_, " "] -> nil
                     [_, match] -> String.to_integer(match)
                   end
                 )

    coordinates = for x <- 0..8, y <- 0..8, do: {x, y}

    state = Enum.zip(coordinates, matches)
            |> Map.new()

    %Sudoku{state: state}
  end

  def to_sudoku(string, :linear) do
    matches = string
              |> String.graphemes()
              |> Enum.map(
                   fn
                     " " -> nil
                     int -> String.to_integer(int)
                   end
                 )

    coordinates = for x <- 0..8, y <- 0..8, do: {x, y}

    state = Enum.zip(coordinates, matches)
            |> Map.new()

    %Sudoku{state: state}
  end

  def to_string(%Sudoku{state: state}, :grid) do
    state
    |> Enum.sort(fn {{x1, y1}, _}, {{x2, y2}, _} -> x1 < x2 || (x1 == x2 && y1 < y2) end)
    |> IO.inspect()
    |> Enum.reduce(
         [],
         fn {{x, y}, val}, acc ->

           acc = acc ++ if x != 0 && rem(x, 3) == 0 && y == 0 do
             ["---------|---------|---------\n"]
                 else
                   []
                 end

           to_print = case val do
             nil -> "( )"
             x -> "(#{x})"
           end

           acc = acc ++ [to_print] ++
                        case {rem(y + 1, 3), y} do
                          {0, 8} -> ["\n"]
                          {0, _} -> ["|"]
                          _ -> []
                        end
         end
       )
    |> Enum.join()
  end

  def to_string(%Sudoku{state: state}, :linear) do
    state
    |> Enum.sort(fn {{x1, y1}, _}, {{x2, y2}, _} -> x1 < x2 || (x1 == x2 && y1 < y2) end)
    |> IO.inspect()
    |> Enum.reduce(
         [],
         fn {{x, y}, val}, acc ->
           acc ++ case val do
             nil -> [" "]
             x -> ["#{x}"]
           end
         end
       )
    |> Enum.join()
  end

  @options MapSet.new(1..9)

  @doc """

  """
  def solve(sudoku) do
    IO.inspect("iteration")
    solutions = sudoku.state
    |> Enum.map(fn {coordinate, v} -> {coordinate, evaluate(sudoku, coordinate)} end)
    |> Enum.reject(fn
      {_, {:solved, _}} -> true
      {_, options} -> length(options) > 1
    end)
    |> Enum.sort(fn {_, options_a}, {_, options_b} -> length(options_a) < length(options_b) end)

    if length(solutions) == 0 do
      sudoku
    else

      new_state = Enum.reduce(solutions, sudoku.state, fn {coordinate, [val]}, acc -> Map.put(acc, coordinate, val) end)

      sudoku = %Sudoku{state: new_state}

      solve(sudoku)
    end
  end

  @doc """
  For the given coordinate, find the possible options.
  """
  @spec evaluate(Sudoku.t(), {integer(), integer()}) :: list()
  def evaluate(%Sudoku{state: state} = sudoku, {x, y} = coordinate) do
    case Map.get(state, coordinate) do
      x when not is_nil(x) ->
        {:solved, x}
      _ ->
        block = block(sudoku, block_index(x, y))
        column = column(sudoku, x)
        row = row(sudoku, y)

        @options
        |> MapSet.difference(to_set(block))
        |> MapSet.difference(to_set(column))
        |> MapSet.difference(to_set(row))
        |> MapSet.to_list()
    end
  end

  defp to_set(entries) do
    entries
    |> Enum.map(fn {{_,_}, val} -> val end)
    |> MapSet.new()
  end

  @doc """
  0|1|2
  -----
  3|4|5
  -----
  6|7|8
  """
  def block(%Sudoku{state: state}, num) do
    x = rem(num, 3) * 3
    y = floor(num / 3) * 3
    for x1 <- x..(x+2), y1 <- y..(y+2), do: {{x1,y1}, Map.get(state, {x1,y1})}
  end

  def block_index(x, y) do
    x1 = floor(x / 3)
    y1 = floor(y / 3)
    y1 * 3 + x1
  end

  def column(%Sudoku{state: state}, num) do
    Enum.filter(state, fn {{x, _}, _} -> x == num end)
  end

  def row(%Sudoku{state: state}, num) do
    Enum.filter(state, fn {{_, y}, _} -> y == num end)
  end
end
