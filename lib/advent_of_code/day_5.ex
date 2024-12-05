defmodule AdventOfCode.Day5 do
  @day 5
  @suffix "_sample"
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    {order, lists} = @input_file |> read_file()

    lists
    |> Stream.map(&{&1, in_order?(order, &1)})
    |> Stream.filter(&elem(&1, 1))
    |> Stream.map(&elem(&1, 0))
    |> Stream.map(&middle_number/1)
    |> Enum.sum()
  end

  def part_2() do
    {order, lists} = @input_file |> read_file()

    lists
    |> Stream.map(&{&1, in_order?(order, &1)})
    |> Stream.reject(&elem(&1, 1))
    |> Stream.map(&elem(&1, 0))
    |> Stream.map(&reorder(order, &1))
    |> Stream.map(&middle_number/1)
    |> Enum.sum()
  end

  defp read_file(file_name) do
    with {:ok, content} <- File.read(file_name),
         [first, second] <- String.split(content, "\n\n") do
      {build_order(first), build_lists(second)}
    end
  end

  defp build_order(rows) do
    rows
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "|"))
    |> Enum.map(fn [l, r] -> {String.to_integer(l), String.to_integer(r)} end)
    |> MapSet.new()
  end

  defp build_lists(rows) do
    rows
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn row ->
      Enum.map(row, &String.to_integer/1)
    end)
  end

  defp pairs(row) do
    row
    |> Enum.with_index()
    |> Enum.flat_map(fn {x, idx} ->
      row
      |> Enum.drop(idx + 1)
      |> Enum.map(&{x, &1})
    end)
  end

  defp in_order?(order, {left, right}) do
    not MapSet.member?(order, {right, left})
  end

  defp in_order?(order, row) do
    row
    |> pairs
    |> Enum.all?(&in_order?(order, &1))
  end

  defp reorder(order, row) do
    row
    |> Enum.sort(fn l, r ->
      in_order?(order, {l, r})
    end)
  end

  defp middle_number(row) do
    middle_number(row, row)
  end

  defp middle_number([_ | fast], [slow_val | slow]) do
    case fast do
      [] -> slow_val
      [_ | fast] -> middle_number(fast, slow)
    end
  end

  defp middle_number([], [val | _]) do
    val
  end
end
