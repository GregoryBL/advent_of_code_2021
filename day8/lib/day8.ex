defmodule Day8 do
  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn l ->
      String.split(l, " | ", trim: true)
      |> Enum.map(fn s -> String.split(s, " ") end)
    end)
  end

  def part1(input) do
    input
    |> Enum.map(fn [a, b] -> b end)
    |> Enum.map(fn cs ->
      Enum.reduce(cs, 0, fn c, acc ->
        case String.length(c) do
          2 -> acc + 1
          3 -> acc + 1
          4 -> acc + 1
          7 -> acc + 1
          _ -> acc
        end
      end)
    end)
    |> Enum.sum()
  end

  def blank do
    0..6
    |> Enum.map(fn _ ->
      MapSet.new(["a", "b", "c", "d", "e", "f", "g"])
    end)
  end

  def mask(to_mask, allows, indices) do
    to_mask
    |> Enum.with_index()
    |> Enum.map(fn {st, idx} ->
      if MapSet.member?(indices, idx) do
        MapSet.intersection(st, allows)
      else
        MapSet.difference(st, allows)
      end
    end)
  end

  def find_codes(patterns, len) do
    Enum.filter(patterns, fn p -> String.length(p) == len end)
    |> Enum.map(fn p ->
      p
      |> String.split("", trim: true)
      |> MapSet.new()
    end)
  end

  def find_code(patterns, len) do
    Enum.at(find_codes(patterns, len), 0)
  end

  def filter_1(options, patterns) do
    one = find_code(patterns, 2)

    mask(options, one, MapSet.new([2, 5]))
  end

  def filter_7(options, patterns) do
    seven = find_code(patterns, 3)
    one = find_code(patterns, 2)

    top = MapSet.difference(seven, one)
    mask(options, top, MapSet.new([0]))
  end

  def filter_4(options, patterns) do
    four = find_code(patterns, 4)
    one = find_code(patterns, 2)

    remaining = MapSet.difference(four, one)
    mask(options, remaining, MapSet.new([1, 3]))
  end

  def filter_6_9(options, patterns) do
    six_nine_zero = find_codes(patterns, 6)
    one = find_code(patterns, 2)

    idx =
      Enum.map(six_nine_zero, &MapSet.difference(&1, one))
      |> Enum.find_index(fn n -> MapSet.size(n) == 5 end)

    six = Enum.at(six_nine_zero, idx)

    top = MapSet.difference(one, six)
    bottom = MapSet.intersection(one, six)

    five_three_two = find_codes(patterns, 5)

    five_idx =
      Enum.map(five_three_two, fn n ->
        MapSet.difference(six, n)
      end)
      |> Enum.find_index(fn n -> MapSet.size(n) == 1 end)

    five = Enum.at(five_three_two, five_idx)
    bottom_left = MapSet.difference(six, five)

    three_idx =
      Enum.map(five_three_two, fn n ->
        MapSet.difference(five, n)
      end)
      |> Enum.find_index(fn n -> MapSet.size(n) == 1 end)

    three = Enum.at(five_three_two, three_idx)
    top_left = MapSet.difference(five, three)

    mask(options, top, MapSet.new([2]))
    |> mask(bottom, MapSet.new([5]))
    |> mask(bottom_left, MapSet.new([4]))
    |> mask(top_left, MapSet.new([1]))
  end

  def solve_puzzle(patterns, codes) do
    num_map =
      filter_1(blank(), patterns)
      |> filter_7(patterns)
      |> filter_4(patterns)
      |> filter_6_9(patterns)
      |> read_out()

    codes
    |> Enum.map(fn c ->
      code =
        String.split(c, "", trim: true)
        |> Enum.sort()
        |> Enum.join("")

      num_map[code]
    end)
    |> Enum.join("")
    |> String.to_integer()
  end

  defp mk(pips, nums) do
    gt = &Enum.at(pips, &1)

    nums
    |> Enum.map(gt)
    |> Enum.sort()
    |> Enum.join("")
  end

  def read_out(options) do
    pips =
      Enum.map(options, &MapSet.to_list/1)
      |> Enum.map(&Enum.at(&1, 0))

    m = &mk(pips, &1)

    %{
      m.([2, 5]) => 1,
      m.([0, 2, 3, 4, 6]) => 2,
      m.([0, 2, 3, 5, 6]) => 3,
      m.([1, 2, 3, 5]) => 4,
      m.([0, 1, 3, 5, 6]) => 5,
      m.([0, 1, 3, 4, 5, 6]) => 6,
      m.([0, 2, 5]) => 7,
      m.([0, 1, 2, 3, 4, 5, 6]) => 8,
      m.([0, 1, 2, 3, 5, 6]) => 9,
      m.([0, 1, 2, 4, 5, 6]) => 0
    }
  end

  def part2(input) do
    Enum.map(input, fn [pats, codes] ->
      solve_puzzle(pats, codes)
    end)
    |> Enum.sum()
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "26")
    IO.puts(part1(test_input))
    IO.puts("Answer Part2 = " <> "")
    IO.puts(part2(test_input))
  end

  def real_solution do
    test_input = read_input_file("input-2.txt")
    IO.puts(part1(test_input))
    IO.puts(part2(test_input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
