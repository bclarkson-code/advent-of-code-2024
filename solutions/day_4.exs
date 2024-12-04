defmodule Pair do
  defstruct y: nil, x: nil
end

defmodule Char do
  defstruct value: nil, dy: nil, dx: nil
end

defmodule Solution do
  @day 4
  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    {_, completed} =
      @input_file
      |> read_file()
      |> Enum.with_index()
      |> Enum.reduce({%{}, 0}, fn {row, y}, {starts, completed} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(
          {starts, completed},
          fn {char, x}, {starts, completed} ->
            search(char, %Pair{y: y, x: x}, {starts, completed})
          end
        )
      end)

    completed
  end

  def part_2() do
    @input_file
    |> read_file()
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp append(map, key, val) do
    Map.update(map, key, [val], fn existing -> [val | existing] end)
  end

  defp update_match(match, char, loc, {starts, completed}) do
    forward = forward?(match)
    next = next_char(match.value, forward)

    factor =
      if forward do
        1
      else
        -1
      end

    case {char == match.value, next} do
      {false, _} ->
        {starts, completed}

      {true, nil} ->
        {starts, completed + 1}

      {true, _} ->
        starts =
          append(
            starts,
            %Pair{
              y: loc.y + match.dy * factor,
              x: loc.x + match.dx * factor
            },
            %Char{
              value: next,
              dy: match.dy,
              dx: match.dx
            }
          )

        {starts, completed}
    end
  end

  defp update_matches({starts, completed}, matches, char, loc) do
    {starts, completed} =
      matches
      |> Enum.reduce({starts, completed}, fn match, {starts, completed} ->
        update_match(match, char, loc, {starts, completed})
      end)

    {starts, completed}
  end

  defp next_char(val, forward) do
    case {val, forward} do
      {"X", true} -> "M"
      {"M", true} -> "A"
      {"A", true} -> "S"
      {"S", false} -> "A"
      {"A", false} -> "M"
      {"M", false} -> "X"
      _ -> nil
    end
  end

  defp forward?(char) do
    case {char.dy, char.dx} do
      {-1, -1} -> false
      {-1, 0} -> false
      {-1, 1} -> false
      {0, -1} -> false
      {0, 1} -> true
      {1, -1} -> true
      {1, 0} -> true
      {1, 1} -> true
    end
  end

  defp search(char, loc, {starts, completed}) do
    {starts, completed} =
      case Map.get(starts, loc) do
        nil ->
          {starts, completed}

        val ->
          update_matches({starts, completed}, val, char, loc)
      end

    starts = Map.drop(starts, [loc])

    starts =
      case char do
        "X" ->
          starts
          |> append(
            %Pair{y: loc.y + 1, x: loc.x - 1},
            %Char{dy: 1, dx: -1, value: "M"}
          )
          |> append(
            %Pair{y: loc.y + 1, x: loc.x},
            %Char{dy: 1, dx: 0, value: "M"}
          )
          |> append(
            %Pair{y: loc.y + 1, x: loc.x + 1},
            %Char{dy: 1, dx: 1, value: "M"}
          )
          |> append(
            %Pair{y: loc.y, x: loc.x + 1},
            %Char{dy: 0, dx: 1, value: "M"}
          )

        "S" ->
          starts
          |> append(
            %Pair{y: loc.y + 1, x: loc.x - 1},
            %Char{dy: -1, dx: 1, value: "A"}
          )
          |> append(
            %Pair{y: loc.y + 1, x: loc.x},
            %Char{dy: -1, dx: 0, value: "A"}
          )
          |> append(
            %Pair{y: loc.y + 1, x: loc.x + 1},
            %Char{dy: -1, dx: -1, value: "A"}
          )
          |> append(
            %Pair{y: loc.y, x: loc.x + 1},
            %Char{dy: 0, dx: -1, value: "A"}
          )

        _ ->
          starts
      end

    {starts, completed}
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)