defmodule Solution do
  @day 2
  @suffix "_sample"
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    @input_file
    |> read_file()
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&ascending?/1)
    |> IO.inspect()
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

  defp safe?(row) do
    ascending?(row)
  end

  defp ascending?(row) do
    [_ | tail] = row

    Enum.zip(row, tail)
    |> Enum.map(fn {l, r} -> l < r end)
    |> Enum.all?()
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
