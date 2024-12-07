defmodule ObstacleGroup do
  defstruct [:rows, :rows_reversed, :cols, :cols_reversed, :height, :width]

  defp append(map, key, val) do
    Map.update(map, key, [val], fn existing -> [val | existing] end)
  end

  def new(obstacles, height, width) do
    rows =
      obstacles
      |> Enum.reduce(%{}, fn {y, x}, group ->
        append(group, y, x)
      end)
      |> then(fn rows ->
        rows
        |> Enum.reduce(%{}, fn {key, values}, acc ->
          Map.put(acc, key, Enum.sort(values))
        end)
      end)

    cols =
      obstacles
      |> Enum.reduce(%{}, fn {y, x}, group ->
        append(group, x, y)
      end)
      |> then(fn rows ->
        rows
        |> Enum.reduce(%{}, fn {key, values}, acc ->
          Map.put(acc, key, Enum.sort(values))
        end)
      end)

    rows_reversed =
      rows
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put(acc, k, Enum.reverse(v))
      end)

    cols_reversed =
      cols
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put(acc, k, Enum.reverse(v))
      end)

    IO.inspect(cols)
    IO.inspect(cols_reversed)

    %__MODULE__{
      rows: rows,
      cols: cols,
      rows_reversed: rows_reversed,
      cols_reversed: cols_reversed,
      height: height,
      width: width
    }
  end

  defp next([], _), do: nil
  defp next(nil, _), do: nil

  defp next([head | tail], val) do
    if head > val do
      head
    else
      next(tail, val)
    end
  end

  defp prev([], _), do: nil
  defp prev(nil, _), do: nil

  defp prev([head | tail], val) do
    if head < val do
      head
    else
      prev(tail, val)
    end
  end

  def next(%__MODULE__{} = group, y, x, direction) do
    case direction do
      "left" ->
        group.rows_reversed
        |> Map.get(y - 1)
        |> prev(x)
        |> then(fn loc ->
          case loc do
            nil -> {:out_of_bounds, {y - 1, 0}}
            loc -> {:in_bounds, {y - 1, loc}}
          end
        end)

      "right" ->
        group.rows
        |> Map.get(y + 1)
        |> next(x)
        |> then(fn loc ->
          case loc do
            nil -> {:out_of_bounds, {y + 1, group.width}}
            loc -> {:in_bounds, {y + 1, loc}}
          end
        end)

      "up" ->
        group.cols_reversed
        |> Map.get(x + 1)
        |> prev(y)
        |> then(fn loc ->
          case loc do
            nil -> {:out_of_bounds, {0, x + 1}}
            loc -> {:in_bounds, {loc, x + 1}}
          end
        end)

      "down" ->
        group.cols
        |> Map.get(x - 1)
        |> next(y)
        |> then(fn loc ->
          case loc do
            nil -> {:out_of_bounds, {group.height, x - 1}}
            loc -> {:in_bounds, {loc, x - 1}}
          end
        end)
    end
  end
end

defmodule AdventOfCode.Day6 do
  @day 6
  @suffix "_sample"
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
    grid = @input_file |> read_file()
    height = length(grid)

    width =
      grid
      |> Enum.at(0)
      |> String.graphemes()
      |> length

    {start, obstacles} = parse(grid)
    group = ObstacleGroup.new(obstacles, height, width)

    n_squares(start, "up", obstacles, height, width, group, 0)
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

  defp next_loc({y, x}, direction) do
    case direction do
      "up" -> {y - 1, x}
      "right" -> {y, x + 1}
      "down" -> {y + 1, x}
      "left" -> {y, x - 1}
    end
  end

  defp step({y, x}, direction, obstacles, height, width) do
    {new_y, new_x} = next_loc({y, x}, direction)

    {next_direction, {new_y, new_x}} =
      if MapSet.member?(obstacles, {new_y, new_x}) do
        {next_direction(direction), {y, x}}
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

  defp can_place({y, x}, height, width, obstacles) do
    cond do
      y < 0 ->
        false

      y >= height ->
        false

      x < 0 ->
        false

      x >= width ->
        false

      MapSet.member?(obstacles, {y, x}) ->
        false

      true ->
        true
    end
  end

  defp makes_loop({y, x}, direction, obstacles, groups, height, width) do
    obstacle = next_loc({y, x}, direction)
    {obs_y, obs_x} = obstacle
    IO.puts("Currently at #{y}, #{x}")
    IO.puts("Placing at #{obs_y}, #{obs_x}")
    IO.puts("Direction #{direction}")
    next_dir = next_direction(direction)

    if can_place(obstacle, height, width, obstacles) do
      obstacles = MapSet.put(obstacles, obstacle)
      follow(obstacle, next_dir, groups, obstacle)
    end

    # {:valid, {final_y, final_x}} <- follow({obs_y, obs_x}, next_dir, groups)
    # IO.puts("-> #{final_y}, #{final_x}")
    #
    # cond do
    #   direction == "up" && final_y < obs_y && final_x == obs_x -> true
    #   direction == "right" && final_x > obs_x && final_y == obs_y -> true
    #   direction == "down" && final_y > obs_y && final_x == obs_x -> true
    #   direction == "left" && final_x < obs_x && final_y == obs_y -> true
    #   true -> false
    # end
  end

  defp n_squares(loc, direction, obstacles, height, width, groups, count) do
    count =
      if makes_loop(loc, direction, obstacles, groups, height, width) do
        IO.inspect(loc)
        count + 1
      else
        count
      end

    IO.puts("\n")

    {state, next_loc, next_direction} = step(loc, direction, obstacles, height, width)

    case state do
      :running -> n_squares(next_loc, next_direction, obstacles, height, width, groups, count)
      :finished -> count
    end
  end

  defp follow({y, x}, direction, groups, until) do
    case ObstacleGroup.next(groups, y, x, direction) do
      {:in_bounds, next_loc} ->
        if next_loc == until do
          {:valid, nil}
        else
          IO.puts("#{y}, #{x} -#{direction}-> #{elem(next_loc, 0)}, #{elem(next_loc, 1)}")
          next_dir = next_direction(direction)
          follow(next_loc, next_dir, groups, until)
        end

      {:out_of_bounds, _} ->
        {:invalid, nil}
    end
  end
end
