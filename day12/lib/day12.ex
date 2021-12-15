defmodule D12 do
  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn l ->
      List.to_tuple(String.split(l, "-", trim: true))
    end)
  end

  def visited_small(curr) do
    Enum.filter(curr, fn c -> String.downcase(c) == c end)
    |> MapSet.new()
  end

  def possible_next(segments, now) do
    Enum.filter(segments, fn {s, _e} ->
      s == now
    end)
    |> Enum.map(fn {_s, e} -> e end)
    |> MapSet.new()
  end

  def paths(["end" | rest], _), do: [["end" | rest]]

  def paths(curr, segments) do
    not_next = visited_small(curr)

    next =
      possible_next(segments, List.first(curr))
      |> MapSet.difference(not_next)

    if MapSet.size(next) == 0 do
      []
    else
      next
      |> Enum.flat_map(fn next ->
        paths([next | curr], segments)
      end)
    end
  end

  def paths2(curr, segments), do: paths2(curr, segments, true)

  def paths2(["end" | rest], _, _), do: [["end" | rest]]

  def paths2(curr, segments, can_visit_twice) do
    not_next = visited_small(curr)

    all_next =
      possible_next(segments, List.first(curr))
      |> MapSet.delete("start")

    next =
      if can_visit_twice do
        all_next
      else
        MapSet.difference(all_next, not_next)
      end

    if MapSet.size(next) == 0 do
      []
    else
      next
      |> Enum.flat_map(fn n ->
        paths2(
          [n | curr],
          segments,
          can_visit_twice && !(Enum.member?(curr, n) && String.downcase(n) == n)
        )
      end)
    end
  end

  def part1(input) do
    mirror = Enum.map(input, fn {a, b} -> {b, a} end)
    Enum.count(paths(["start"], input ++ mirror))
  end

  def part2(input) do
    mirror = Enum.map(input, fn {a, b} -> {b, a} end)

    paths2(["start"], input ++ mirror)
    |> Enum.uniq()
    |> Enum.count()
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "19")
    IO.inspect(part1(test_input))
    IO.puts("Answer Part2 = " <> "36")
    IO.inspect(part2(test_input))
  end

  def real_solution do
    input = read_input_file("input-6.txt")
    IO.puts(part1(input))
    IO.puts(part2(input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
