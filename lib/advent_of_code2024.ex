defmodule AdventOfCode do
  @moduledoc """
  Main module for solving coding challenges
  """

  def solve_day(day_number) do
    solution_module = String.to_existing_atom("Elixir.AdventOfCode.Day#{day_number}")

    IO.puts("Day #{day_number} Solutions:")
    IO.puts("Part 1: #{solution_module.part_1()}")
    IO.puts("Part 2: #{solution_module.part_2()}")
  end
end
