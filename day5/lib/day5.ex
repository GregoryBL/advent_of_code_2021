defmodule Day5 do
  def read_input_file(name) do
    # The parsing code is always gnarly but whatever
    File.read!(name)
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn l ->
      String.split(l, " -> ", trim: true)
      |> Enum.map(fn p ->
        String.split(p, ",")
        |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.map(&List.to_tuple/1)
    end)
    |> Enum.map(&List.to_tuple/1)
  end

  def is_horiz_vert?({{x1, y1}, {x2, y2}}) do
    x1 == x2 || y1 == y2
  end

  # def make_points([[x1, y1], [x2, y2]]) when x1 == x2 do
  #   0..(y2 - y1) |> Enum.map(fn n -> [x1, y1 + n] end)
  # end

  # def make_points([[x1, y1], [x2, y2]]) when y1 == y2 do
  #   0..(x2 - x1) |> Enum.map(fn n -> [x1 + n, y1] end)
  # end

  def direction(a, b) when a == b, do: 0
  def direction(a, b) when a > b, do: 1
  def direction(a, b) when a < b, do: -1

  def make_points({{x1, y1}, {x2, y2}}) do
    dx = direction(x2, x1)
    dy = direction(y2, y1)

    num_points = max(abs(x2 - x1), abs(y2 - y1))

    0..num_points |> Enum.map(fn n -> {x1 + n * dx, y1 + n * dy} end)
  end

  def part1(lines) do
    lines
    |> Enum.filter(&is_horiz_vert?/1)
    |> Enum.flat_map(&make_points/1)
    |> Enum.frequencies()
    |> Enum.filter(fn {_key, val} -> val > 1 end)
    |> Enum.count()
  end

  def part2(lines) do
    lines
    |> Enum.flat_map(&make_points/1)
    |> Enum.frequencies()
    |> Enum.filter(fn {_key, val} -> val > 1 end)
    |> Enum.count()
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "5")
    IO.puts(part1(test_input))
    IO.puts("Answer Part2 = " <> "12")
    IO.puts(part2(test_input))
  end

  def real_solution do
    test_input = read_input_file("input-5.txt")
    IO.puts(part1(test_input))
    IO.puts(part2(test_input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
