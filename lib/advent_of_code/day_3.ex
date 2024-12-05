defmodule AdventOfCode.Day3 do
  @day 3
  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1 do
    @input_file
    |> read_file
    |> extract_multiplications
    |> Enum.sum()
  end

  def part_2 do
    @input_file
    |> read_file
    |> extract_operations
    |> apply_operations
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
  end

  defp extract_multiplications(data) do
    ~r/mul\(\d+,\d+\)/
    |> Regex.scan(data)
    |> Enum.map(&hd/1)
    |> Enum.map(&apply_multiplication/1)
  end

  defp apply_multiplication(mul) do
    ~r/\d+/
    |> Regex.scan(mul)
    |> Enum.flat_map(& &1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.product()
  end

  defp extract_operations(data) do
    ~r/mul\(\d+,\d+\)|do\(\)|don\'t\(\)/
    |> Regex.scan(data)
    |> Enum.map(&hd/1)
  end

  defp apply_operations(ops) do
    ops
    |> Enum.reduce({0, true}, &apply_operation/2)
    |> elem(0)
  end

  defp apply_operation(op, {total, active}) do
    case {op, active} do
      {"do()", _} -> {total, true}
      {"don't()", _} -> {total, false}
      {mul, true} -> {apply_multiplication(mul) + total, true}
      {_, false} -> {total, false}
    end
  end
end
