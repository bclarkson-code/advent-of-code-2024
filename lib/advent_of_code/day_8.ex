defmodule AdventOfCode.Day8 do
  @day 8

  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    {values, shape} =
      @input_file
      |> read_file()
      |> parse

    values
    |> Enum.map(fn {_, val} ->
      val
      |> MapSet.to_list()
      |> pairs([])
    end)
    |> Enum.concat()
    |> Enum.map(fn {left, right} ->
      antinodes(left, right)
    end)
    |> Enum.concat()
    |> Enum.filter(&in_bounds?(&1, shape))
    |> Enum.uniq()
    |> Enum.count()
  end

  def part_2() do
    {values, shape} =
      @input_file
      |> read_file()
      |> parse

    values
    |> Enum.map(fn {_, val} ->
      val
      |> MapSet.to_list()
      |> pairs([])
    end)
    |> Enum.concat()
    |> Enum.map(fn {left, right} ->
      extended_antinodes(left, right, shape)
    end)
    |> Enum.concat()
    |> Enum.filter(&in_bounds?(&1, shape))
    |> Enum.uniq()
    |> Enum.count()
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp append(map, key, val) do
    Map.update(map, key, MapSet.new([val]), fn existing ->
      MapSet.put(existing, val)
    end)
  end

  defp parse_row({row, y}, acc) do
    row
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(acc, fn
      {".", _}, map -> map
      {char, x}, map -> append(map, char, {y, x})
    end)
  end

  defp parse(grid) do
    values =
      grid
      |> Enum.with_index()
      |> Enum.reduce(%{}, &parse_row/2)

    {values, get_dimensions(grid)}
  end

  def get_dimensions([head | _] = grid) do
    {length(grid), String.length(head)}
  end

  def pairs([], prev), do: List.flatten(prev)
  def pairs([_], prev), do: List.flatten(prev)

  def pairs([head | tail], prev) do
    current =
      tail
      |> Enum.map(&{head, &1})

    pairs(tail, [current | prev])
  end

  def antinodes({y_left, x_left}, {y_right, x_right}) do
    dy = y_right - y_left
    dx = x_right - x_left

    [{y_left - dy, x_left - dx}, {y_right + dy, x_right + dx}]
  end

  defp extended_antinodes(left, right, shape, step \\ 0)

  defp extended_antinodes({y_left, x_left}, {y_right, x_right}, shape, step) do
    dy = y_right - y_left
    dx = x_right - x_left
    next_left = {y_left - dy * step, x_left - dx * step}
    next_right = {y_right + dy * step, x_right + dx * step}

    if in_bounds?(next_left, shape) || in_bounds?(next_right, shape) do
      next_antinodes =
        extended_antinodes({y_left, x_left}, {y_right, x_right}, shape, step + 1)

      [next_left, next_right | next_antinodes]
    else
      []
    end
  end

  def in_bounds?({y, x}, {height, width}) do
    cond do
      y < 0 -> false
      y >= height -> false
      x < 0 -> false
      x >= width -> false
      true -> true
    end
  end
end
