defmodule AdventOfCode.Day7 do
  @day 7

  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    @input_file
    |> read_file()
    |> Enum.map(&parse_row/1)
    |> Enum.filter(fn {target, [head | tail]} ->
      can_make_total?(tail, target, head)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part_2() do
    @input_file
    |> read_file()
    |> Enum.map(&parse_row/1)
    |> Enum.filter(fn {target, [head | tail]} ->
      can_make_total?(tail, target, head, :concat)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp parse_row(row) do
    [target | variables] =
      ~r/\d+/
      |> Regex.scan(row)
      |> Enum.map(fn [val] -> String.to_integer(val) end)

    {target, variables}
  end

  defp can_make_total?(list, target, current, concat \\ nil)

  defp can_make_total?([], target, current, _) do
    target == current
  end

  defp can_make_total?(_, target, current, _) when current > target, do: false

  defp can_make_total?([head | tail], target, current, concat) do
    output =
      can_make_total?(tail, target, current + head, concat) ||
        can_make_total?(tail, target, current * head, concat)

    case concat do
      :concat -> output || can_make_total?(tail, target, concat(current, head), concat)
      _ -> output
    end
  end

  defp concat(left, right) do
    (to_string(left) <> to_string(right))
    |> String.to_integer()
  end
end
