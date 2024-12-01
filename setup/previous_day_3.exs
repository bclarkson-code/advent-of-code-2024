defmodule Symbol do
  defstruct value: -1, x: -1, y: -1, length: 0
end

defmodule Solution do
  @day 3

  @suffix ""

  def part_1() do
    {nums, _} =
      read_file("setup/day_#{@day}#{@suffix}_input.txt")
      |> Enum.map_reduce(0, fn row, y -> extract(row, ~r/\d+/, y) end)

    nums =
      nums
      |> List.flatten()
      |> Enum.map(fn num ->
        %Symbol{value: String.to_integer(num.value), x: num.x, y: num.y, length: num.length}
      end)
      |> Enum.reduce(%{}, &store/2)

    {symbols, _} =
      read_file("setup/day_#{@day}#{@suffix}_input.txt")
      |> Enum.map_reduce(0, fn row, y -> extract(row, ~r/[^0-9.]/, y) end)

    symbols
    |> List.flatten()
    |> Enum.map(fn symbol ->
      symbol
      |> neighbours()
      |> Enum.reduce(MapSet.new(), fn {y, x}, next_to ->
        case Map.get(nums, {y, x}) do
          nil -> next_to
          {val, pos} -> MapSet.put(next_to, {val, pos})
        end
      end)
      |> MapSet.to_list()
    end)
    |> List.flatten()
    |> Enum.map(fn {val, _} -> val end)
    |> Enum.sum()
  end

  def part_2() do
    {nums, _} =
      read_file("setup/day_#{@day}#{@suffix}_input.txt")
      |> Enum.map_reduce(0, fn row, y -> extract(row, ~r/\d+/, y) end)

    nums =
      nums
      |> List.flatten()
      |> Enum.map(fn num ->
        %Symbol{value: String.to_integer(num.value), x: num.x, y: num.y, length: num.length}
      end)
      |> Enum.reduce(%{}, &store/2)

    {symbols, _} =
      read_file("setup/day_#{@day}#{@suffix}_input.txt")
      |> Enum.map_reduce(0, fn row, y -> extract(row, ~r/[^0-9.]/, y) end)

    symbols
    |> List.flatten()
    |> Enum.map(fn symbol ->
      symbol
      |> neighbours()
      |> Enum.reduce(MapSet.new(), fn {y, x}, next_to ->
        case Map.get(nums, {y, x}) do
          nil -> next_to
          {val, pos} -> MapSet.put(next_to, {val, pos})
        end
      end)
      |> MapSet.to_list()
    end)
    |> Enum.filter(&(length(&1) == 2))
    |> Enum.map(fn [{val_1, _}, {val_2, _}] -> val_1 * val_2 end)
    |> Enum.sum()
  end

  defp read_file(file_name, limit \\ nil) do
    contents =
      file_name
      |> File.read!()
      |> String.split("\n", trim: true)

    if limit do
      Enum.take(contents, limit)
    else
      contents
    end
  end

  defp extract(row, pattern, y) do
    indices =
      Regex.scan(pattern, row, return: :index)
      |> List.flatten()

    matches =
      Regex.scan(pattern, row)
      |> List.flatten()
      |> Enum.zip(indices)
      |> Enum.map(fn {val, {x, length}} ->
        %Symbol{value: val, x: x, y: y, length: length}
      end)

    {matches, y + 1}
  end

  defp store(num, map) do
    num.x..(num.x + num.length - 1)
    |> Enum.reduce(map, fn x, acc ->
      Map.put(acc, {num.y, x}, {num.value, {num.y, num.x}})
    end)
  end

  defp neighbours(symbol) do
    [
      {symbol.y - 1, symbol.x - 1},
      {symbol.y - 1, symbol.x},
      {symbol.y - 1, symbol.x + 1},
      {symbol.y, symbol.x - 1},
      {symbol.y, symbol.x + 1},
      {symbol.y + 1, symbol.x - 1},
      {symbol.y + 1, symbol.x},
      {symbol.y + 1, symbol.x + 1}
    ]
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
