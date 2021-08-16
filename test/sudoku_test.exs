defmodule SudokuTest do
  use ExUnit.Case

  @example_linear "     5 73 3 26  4 9   3    16 9  2    98 15    3  6 97    1   8 1  89 2 35 6     "

  @example_grid """
  ( )( )( )|( )( )(5)|( )(7)(3)
  ( )(3)( )|(2)(6)( )|( )(4)( )
  (9)( )( )|( )(3)( )|( )( )( )
  ---------|---------|---------
  (1)(6)( )|(9)( )( )|(2)( )( )
  ( )( )(9)|(8)( )(1)|(5)( )( )
  ( )( )(3)|( )( )(6)|( )(9)(7)
  ---------|---------|---------
  ( )( )( )|( )(1)( )|( )( )(8)
  ( )(1)( )|( )(8)(9)|( )(2)( )
  (3)(5)( )|(6)( )( )|( )( )( )
  """

  describe "#to_state" do
    test "grid to string" do
      from_grid = Sudoku.to_sudoku(@example_grid, :grid)
      from_linear = Sudoku.to_sudoku(@example_linear, :linear)
      assert from_grid == from_linear
      assert Sudoku.to_string(from_grid, :linear) == Sudoku.to_string(from_linear, :linear)
    end
  end
end