defmodule Solution do
  @day 2

  @suffix "_sample"

  def part_1() do
    read_file("setup/day_#{@day}#{@suffix}_input.txt")
  end

  def part_2() do
    read_file("setup/day_#{@day}#{@suffix}_input.txt")
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
