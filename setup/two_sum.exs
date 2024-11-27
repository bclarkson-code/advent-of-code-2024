defmodule Solution do
  @spec two_sum(nums :: [integer], target :: integer) :: [integer]
  def two_sum(nums, target) do
    nums
    |> Enum.with_index()
    |> Enum.reduce_while(%{}, fn {num, idx}, seen ->
      case Map.get(seen, target - num) do
        nil -> {:cont, Map.put(seen, num, idx)}
        other_idx -> {:halt, [other_idx, idx]}
      end
    end)
  end
end

# Add ExUnit tests
ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  test "example 1: finds numbers that sum to target" do
    assert Solution.two_sum([2, 7, 11, 15], 9) == [0, 1]
  end

  test "example 2: works with numbers not at start" do
    assert Solution.two_sum([3, 2, 4], 6) == [1, 2]
  end

  test "example 3: handles same number used twice" do
    assert Solution.two_sum([3, 3], 6) == [0, 1]
  end

  test "larger example with negative numbers" do
    assert Solution.two_sum([1, -2, 5, -3, 7, 2], 4) == [3, 4]
  end
end
