defmodule AdventOfCode.Day10 do
  @day 10
  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"
  @directions [
    {-1, 0},
    {1, 0},
    {0, -1},
    {0, 1}
  ]

  def part_1() do
    {grid, shape} =
      @input_file
      |> read_file()

    count(grid, shape)
  end

  def part_2() do
    {grid, shape} =
      @input_file
      |> read_file()

    count_unique(grid, shape)
  end

  defp read_file(file_name) do
    with {:ok, content} <- File.read(file_name) do
      content =
        content
        |> String.split("\n", trim: true)

      grid =
        content
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {row, y}, acc ->
          row
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce(acc, fn {val, x}, map ->
            Map.put(map, {y, x}, String.to_integer(val))
          end)
        end)

      height = length(content)
      width = String.length(List.first(content))
      {grid, {height, width}}
    end
  end

  defp count(grid, shape) do
    grid
    |> Map.keys()
    |> Enum.filter(fn key -> Map.get(grid, key) == 0 end)
    |> Enum.map(fn loc ->
      {_, n} = n_trails(loc, grid, shape)
      n
    end)
    |> Enum.sum()
  end

  defp count_unique(grid, shape) do
    grid
    |> Map.keys()
    |> Enum.filter(fn key -> Map.get(grid, key) == 0 end)
    |> Enum.map(fn loc ->
      n_unique_trails(loc, grid, shape)
    end)
    |> Enum.sum()
  end

  def n_trails(loc, grid, shape, visited \\ MapSet.new(), prev \\ -1)

  def n_trails({y, _}, _, _, visited, _) when y < 0, do: {visited, 0}
  def n_trails({_, x}, _, _, visited, _) when x < 0, do: {visited, 0}
  def n_trails({y, _}, _, {height, _}, visited, _) when y >= height, do: {visited, 0}
  def n_trails({_, x}, _, {_, width}, visited, _) when x >= width, do: {visited, 0}

  def n_trails({y, x}, grid, shape, visited, prev) do
    current = Map.get(grid, {y, x})

    if MapSet.member?(visited, {y, x}) || current != prev + 1 do
      {visited, 0}
    else
      updated_visited = MapSet.put(visited, {y, x})

      case current do
        9 ->
          {updated_visited, 1}

        _ ->
          @directions
          |> Enum.reduce({updated_visited, 0}, fn {dy, dx}, {temp_visited, n} ->
            {temp_visited, temp_n} =
              n_trails({y + dy, x + dx}, grid, shape, temp_visited, current)

            {temp_visited, n + temp_n}
          end)
      end
    end
  end

  def n_unique_trails(loc, grid, shape, visited \\ MapSet.new(), prev \\ -1)

  def n_unique_trails({y, _}, _, _, _, _) when y < 0, do: 0
  def n_unique_trails({_, x}, _, _, _, _) when x < 0, do: 0
  def n_unique_trails({y, _}, _, {height, _}, _, _) when y >= height, do: 0
  def n_unique_trails({_, x}, _, {_, width}, _, _) when x >= width, do: 0

  def n_unique_trails({y, x}, grid, shape, visited, prev) do
    current = Map.get(grid, {y, x})

    if MapSet.member?(visited, {y, x}) || current != prev + 1 do
      0
    else
      updated_visited = MapSet.put(visited, {y, x})

      case current do
        9 ->
          1

        _ ->
          @directions
          |> Enum.reduce(0, fn {dy, dx}, n ->
            n + n_unique_trails({y + dy, x + dx}, grid, shape, updated_visited, current)
          end)
      end
    end
  end
end
