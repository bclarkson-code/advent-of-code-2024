defmodule Pair do
  defstruct y: nil, x: nil
end

defmodule Char do
  defstruct value: nil, dy: nil, dx: nil
end

defmodule XPiece do
  defstruct value: nil, type: nil, idx: nil, loc: nil
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
            search_for_x(char, %Pair{y: y, x: x}, {starts, completed})
          end
        )
      end)

    completed
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

  defp next_x(%{idx: 4}), do: nil

  defp next_x(x) do
    {dy, dx} =
      case x.idx do
        0 -> {0, 2}
        1 -> {1, -1}
        2 -> {1, -1}
        3 -> {0, 2}
      end

    next_loc = %Pair{y: x.loc.y + dy, x: x.loc.x + dx}
    next_piece = %XPiece{value: nil, idx: x.idx + 1, loc: next_loc, type: x.type}

    case {x.idx, x.type} do
      {1, _} -> %{next_piece | value: "A"}
      {2, "MM"} -> %{next_piece | value: "S"}
      {2, "MS"} -> %{next_piece | value: "M"}
      {2, "SM"} -> %{next_piece | value: "S"}
      {2, "SS"} -> %{next_piece | value: "M"}
      {3, "MM"} -> %{next_piece | value: "S"}
      {3, "MS"} -> %{next_piece | value: "S"}
      {3, "SM"} -> %{next_piece | value: "M"}
      {3, "SS"} -> %{next_piece | value: "M"}
    end
  end

  defp search_for_x(char, loc, {starts, completed}) do
    {starts, completed} =
      case Map.get(starts, loc) do
        nil ->
          {starts, completed}

        val ->
          update_x_matches({starts, completed}, val, char)
      end

    starts = Map.drop(starts, [loc])

    next_loc = %Pair{y: loc.y, x: loc.x + 2}

    starts =
      case char do
        "M" ->
          starts
          |> append(next_loc, %XPiece{value: "M", idx: 1, loc: next_loc, type: "MM"})
          |> append(next_loc, %XPiece{value: "S", idx: 1, loc: next_loc, type: "MS"})

        "S" ->
          starts
          |> append(next_loc, %XPiece{value: "M", idx: 1, loc: next_loc, type: "SM"})
          |> append(next_loc, %XPiece{value: "S", idx: 1, loc: next_loc, type: "SS"})

        _ ->
          starts
      end

    {starts, completed}
  end

  defp update_x_match(match, char, {starts, completed}) do
    next = next_x(match)

    case {char == match.value, next} do
      {false, _} ->
        {starts, completed}

      {true, nil} ->
        {starts, completed + 1}

      {true, _} ->
        starts =
          append(starts, next.loc, next)

        {starts, completed}
    end
  end

  defp update_x_matches({starts, completed}, matches, char) do
    {starts, completed} =
      matches
      |> Enum.reduce({starts, completed}, fn match, {starts, completed} ->
        update_x_match(match, char, {starts, completed})
      end)

    {starts, completed}
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
