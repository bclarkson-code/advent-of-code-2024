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
    {:no_loop, visited} = run(start, "up", obstacles, height, width, visited)

    visited
    |> Enum.map(&elem(&1, 0))
    |> MapSet.new()
    |> MapSet.size()
  end

  def part_2() do
    grid = @input_file |> read_file()
    height = length(grid)

    width =
      grid
      |> Enum.at(0)
      |> String.graphemes()
      |> length

    {start, obstacles} = parse(grid)
    visited = MapSet.new()
    {:no_loop, count} = n_squares(start, "up", obstacles, height, width, visited, 0)
    count
  end

  defp read_file(file_name) do
    with {:ok, content} <- File.read(file_name) do
      String.split(content, "\n", trim: true)
    end
  end

  defp parse_row(row, {y, loc, obs}) do
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

  defp parse(grid) do
    grid
    |> Enum.reduce(
      {0, nil, MapSet.new()},
      &parse_row/2
    )
    |> then(fn {_, start, obstacles} -> {start, obstacles} end)
  end

  defp next_direction(direction) do
    case direction do
      "up" -> "right"
      "right" -> "down"
      "down" -> "left"
      "left" -> "up"
    end
  end

  defp next_location({y, x}, direction) do
    case direction do
      "up" -> {y - 1, x}
      "right" -> {y, x + 1}
      "down" -> {y + 1, x}
      "left" -> {y, x - 1}
    end
  end

  defp in_bounds?({y, x}, height, width) do
    cond do
      y < 0 -> false
      y >= height -> false
      x < 0 -> false
      x >= width -> false
      true -> true
    end
  end

  defp step({y, x}, direction, obstacles, height, width, visited) do
    next_loc = next_location({y, x}, direction)

    in_bounds = in_bounds?(next_loc, height, width)
    is_obstacle = MapSet.member?(obstacles, next_loc)
    is_visited = MapSet.member?(visited, {next_loc, direction})

    cond do
      not in_bounds -> {:out_of_bounds, nil, nil}
      is_obstacle -> {:in_bounds, next_direction(direction), {y, x}}
      is_visited -> {:loop, nil, nil}
      true -> {:in_bounds, direction, next_loc}
    end
  end

  defp run(loc, direction, obstacles, height, width, visited) do
    visited = MapSet.put(visited, {loc, direction})

    case step(loc, direction, obstacles, height, width, visited) do
      {:out_of_bounds, _, _} ->
        {:no_loop, visited}

      {:in_bounds, next_dir, next_loc} ->
        run(next_loc, next_dir, obstacles, height, width, visited)

      {:loop, _, _} ->
        {:loop, nil}
    end
  end

  defp visited_square?(loc, visited) do
    MapSet.member?(visited, {loc, "up"})
    |> Kernel.||(MapSet.member?(visited, {loc, "right"}))
    |> Kernel.||(MapSet.member?(visited, {loc, "down"}))
    |> Kernel.||(MapSet.member?(visited, {loc, "left"}))
  end

  defp creates_loop?(loc, direction, obstacles, height, width, visited) do
    next_loc = next_location(loc, direction)
    in_bounds = in_bounds?(next_loc, height, width)
    is_obstacle = MapSet.member?(obstacles, next_loc)
    is_visited = visited_square?(next_loc, visited)
    can_place = in_bounds && not is_obstacle && not is_visited

    if can_place do
      temp_obstacles = MapSet.put(obstacles, next_loc)

      case run(loc, next_direction(direction), temp_obstacles, height, width, visited) do
        {:loop, _} ->
          true

        _ ->
          false
      end
    else
      false
    end
  end

  defp n_squares(loc, direction, obstacles, height, width, visited, count) do
    count =
      if creates_loop?(loc, direction, obstacles, height, width, visited) do
        count + 1
      else
        count
      end

    visited = MapSet.put(visited, {loc, direction})

    case step(loc, direction, obstacles, height, width, visited) do
      {:out_of_bounds, _, _} ->
        {:no_loop, count}

      {:in_bounds, next_dir, next_loc} ->
        n_squares(next_loc, next_dir, obstacles, height, width, visited, count)

      {:loop, _, _} ->
        {:loop, nil}
    end
  end
end
