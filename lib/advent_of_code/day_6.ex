defmodule AdventOfCode.Day6 do
  @day 6
  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    grid = @input_file |> read_file()
    height = length(grid)

    width =
      grid
      |> Enum.at(0)
      |> String.graphemes()
      |> length

    {start, obstacles} = parse(grid)
    visited = MapSet.new()
    visited = run(start, "up", obstacles, height, width, visited)
    MapSet.size(visited)
  end

  def part_2() do
  end

  defp read_file(file_name) do
    with {:ok, content} <- File.read(file_name) do
      String.split(content, "\n", trim: true)
    end
  end

  defp parse(grid) do
    {_, start, obstacles} =
      grid
      |> Enum.reduce(
        {0, nil, MapSet.new()},
        fn row, {y, loc, obs} ->
          {_, new_loc, new_obs} =
            row
            |> String.graphemes()
            |> Enum.reduce({0, loc, obs}, fn char, {x, loc, obs} ->
              case char do
                "^" -> {x + 1, {y, x}, obs}
                "#" -> {x + 1, loc, MapSet.put(obs, {y, x})}
                _ -> {x + 1, loc, obs}
              end
            end)

          {y + 1, new_loc || loc, new_obs}
        end
      )

    {start, obstacles}
  end

  defp step({y, x}, direction, obstacles, height, width) do
    {new_y, new_x} =
      case direction do
        "up" -> {y - 1, x}
        "right" -> {y, x + 1}
        "down" -> {y + 1, x}
        "left" -> {y, x - 1}
      end

    {next_direction, {new_y, new_x}} =
      if MapSet.member?(obstacles, {new_y, new_x}) do
        case direction do
          "up" -> {"right", {y, x}}
          "right" -> {"down", {y, x}}
          "down" -> {"left", {y, x}}
          "left" -> {"up", {y, x}}
        end
      else
        {direction, {new_y, new_x}}
      end

    if new_y < 0 || new_y >= height || new_x < 0 || new_x >= width do
      {:finished, {new_y, new_x}, next_direction}
    else
      {:running, {new_y, new_x}, next_direction}
    end
  end

  defp run(loc, direction, obstacles, height, width, visited) do
    visited = MapSet.put(visited, loc)
    {state, next_loc, next_direction} = step(loc, direction, obstacles, height, width)

    case state do
      :running -> run(next_loc, next_direction, obstacles, height, width, visited)
      :finished -> visited
    end
  end
end
