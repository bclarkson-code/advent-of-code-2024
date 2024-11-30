defmodule Symbol do
  defstruct value: -1, x: -1, y: -1, length: 0
end

defmodule Solution do
  @day 3

  @suffix "_sample"

  def part_1() do
    {nums, _} =
      read_file("setup/day_#{@day}#{@suffix}_input.txt")
      |> Enum.map_reduce(0, fn row, y -> extract(row, ~r/\d+/, y) end)

    nums
    |> List.flatten()
    |> Enum.reduce(%{}, &store/2)
    |> IO.inspect()

    nil
  end

  def part_2() do
    read_file("setup/day_#{@day}#{@suffix}_input.txt")
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
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
        %Symbol{value: String.to_integer(val), x: x, y: y, length: length}
      end)

    {matches, y + 1}
  end

  defp store(num, map) do
    map =
      (num.x - 1)..(num.x + num.length + 1)
      |> Enum.reduce(map, fn i, acc ->
        Map.put(acc, {num.y - 1, i}, num.value)
        |> Map.put({num.y + 1, i}, num.value)
      end)
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
