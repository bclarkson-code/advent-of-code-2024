defmodule Solution do
  @day 1
  @suffix "_sample"
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    @input_file
    |> read_file()
  end

  def part_2() do
    @input_file
    |> read_file()
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
