defmodule AdventOfCode.Day10 do
  @day 10
  @suffix "_sample"
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    @input_file
    |> read_file()
  end

  def part_2() do
    @input_file
    |> read_file()

    ""
  end

  defp read_file(file_name) do
    with {:ok, content} <- File.read(file_name) do
      content
      |> String.graphemes()
    end
  end
end
