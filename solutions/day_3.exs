defmodule Solution do
  @day 3
  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    data =
      @input_file
      |> read_file()

    pattern = ~r/mul\(\d+,\d+\)/

    pattern
    |> Regex.scan(data)
    |> Enum.map(fn [val] -> val end)
    |> Enum.map(&parse_mul/1)
    |> Enum.sum()
  end

  def part_2() do
    data =
      @input_file
      |> read_file()

    pattern = ~r/mul\(\d+,\d+\)|do\(\)|don\'t\(\)/

    {out, _} =
      pattern
      |> Regex.scan(data)
      |> Enum.map(fn [val] -> val end)
      |> Enum.reduce({0, true}, &parse/2)

    out
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
  end

  defp parse_mul(mul) do
    ~r/\d+/
    |> Regex.scan(mul)
    |> Enum.map(fn [l] -> String.to_integer(l) end)
    |> Enum.product()
  end

  defp parse(val, {total, active}) do
    case {val, active} do
      {"do()", _} -> {total, true}
      {"don't()", _} -> {total, false}
      {mul, true} -> {parse_mul(mul) + total, true}
      {_, false} -> {total, false}
    end
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
