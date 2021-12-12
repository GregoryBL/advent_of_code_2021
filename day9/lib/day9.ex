defmodule Day9 do
  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn l ->
      String.split(l, "", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def check_low(point) when length(point) == 3 do
    [a, b, c] = point

    cond do
      b < c and b < a -> 1
      true -> 0
    end
  end

  def check_low(point) when length(point) == 2 do
    [a, b] = point

    cond do
      b < a -> 1
      true -> 0
    end
  end

  defp find_low_points_1d(rows) do
    mask =
      chunk(rows)
      |> Enum.map(fn r -> Enum.map(r, &check_low/1) end)
  end

  def find_low_points(input) do
    mask =
      find_low_points_1d(input)
      |> List.flatten()

    other_axis_mask =
      Enum.zip(input)
      |> Enum.map(&Tuple.to_list/1)
      |> find_low_points_1d()
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> List.flatten()

    [List.flatten(input), mask, other_axis_mask]
    |> Enum.zip()
    |> Enum.reduce(0, fn {a, b, c}, acc ->
      case b * c do
        1 -> a + 1 + acc
        _ -> acc
      end
    end)
  end

  def chunk(rows) do
    Enum.map(rows, fn r ->
      Enum.chunk_every([10000 | r], 3, 1)
    end)
  end

  def part1(input) do
    find_low_points(input)
  end

  def part2(input) do
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "15")
    IO.puts(part1(test_input))
    # IO.puts("Answer Part2 = " <> "")
    # IO.puts(part2(test_input))
  end

  def real_solution do
    test_input = read_input_file("input-3.txt")
    IO.puts(part1(test_input))
    # IO.puts(part2(test_input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
