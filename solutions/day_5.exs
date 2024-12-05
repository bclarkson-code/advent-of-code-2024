defmodule Solution do
  @day 5
  @suffix "_sample"
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    {first, second} =
      @input_file
      |> read_file()

    order = first |> build_order
    lists = second |> build_lists
    in_order = second |> Enum.map(&in_order?(order, &1))

    lists
    |> Enum.zip(in_order)
    |> Enum.filter(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&middle_number/1)
    |> Enum.sum()
  end

  def part_2() do
    {first, second} =
      @input_file
      |> read_file()

    order = first |> build_order
    lists = second |> build_lists
    in_order = second |> Enum.map(&in_order?(order, &1))

    lists
    |> Enum.zip(in_order)
    |> Enum.filter(&(not elem(&1, 1)))
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&reorder(order, &1))
    |> Enum.map(&middle_number/1)
    |> Enum.sum()
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n\n")
    |> then(fn [first, second] ->
      first = first |> String.split("\n", trim: true)
      second = second |> String.split("\n", trim: true)
      {first, second}
    end)
  end

  defp build_order(rows) do
    rows
    |> Enum.map(&String.split(&1, "|"))
    |> Enum.map(fn [l, r] -> {String.to_integer(l), String.to_integer(r)} end)
    |> MapSet.new()
  end

  defp build_lists(rows) do
    rows
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
    |> Enum.map(&in_order?(order, &1))
    |> Enum.all?()
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

  defp reorder(order, row) do
    row
    |> Enum.sort(fn l, r ->
      in_order?(order, {l, r})
    end)
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
