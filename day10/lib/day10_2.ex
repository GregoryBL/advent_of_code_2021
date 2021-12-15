defmodule D10 do
  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn l ->
      String.split(l, "", trim: true)
    end)
  end

  def left_to_right(c) do
    case c do
      "{" ->
        "}"

      "(" ->
        ")"

      "[" ->
        "]"

      "<" ->
        ">"

      _ ->
        IO.puts("Tried to match: " <> c)
        :error
    end
  end

  def parse_letter([], stack), do: {:ok, stack}

  def parse_letter([first | rest], []) do
    case first do
      left when left in ["(", "{", "[", "<"] ->
        parse_letter(rest, [left])

      _ ->
        {:err, first}
    end
  end

  def parse_letter([first | rest], stack) do
    [top | more] = stack

    match = left_to_right(top)

    case first do
      left when left in ["(", "{", "[", "<"] ->
        parse_letter(rest, [left | stack])

      ^match ->
        parse_letter(rest, more)

      _ ->
        {:err, first}
    end
  end

  def value_letter(let) do
    case let do
      ")" -> 3
      "]" -> 57
      "}" -> 1197
      ">" -> 25137
    end
  end

  def value_letter_p2(let) do
    case let do
      ")" -> 1
      "]" -> 2
      "}" -> 3
      ">" -> 4
    end
  end

  def part1(input) do
    Enum.map(input, fn l -> parse_letter(l, []) end)
    |> Enum.filter(fn r ->
      case r do
        {:ok, _} -> false
        {:err, _} -> true
      end
    end)
    |> Enum.map(fn {:err, l} -> l end)
    |> Enum.frequencies()
    |> Enum.reduce(0, fn {l, f}, acc ->
      acc + value_letter(l) * f
    end)
  end

  def part2(input) do
    sorted =
      Enum.map(input, fn l -> parse_letter(l, []) end)
      |> Enum.filter(fn r ->
        case r do
          {:ok, _} -> true
          {:err, _} -> false
        end
      end)
      |> Enum.map(fn {:ok, s} -> s end)
      |> Enum.map(fn l ->
        Enum.reduce(l, 0, fn c, acc ->
          acc * 5 + value_letter_p2(left_to_right(c))
        end)
      end)
      |> Enum.sort()

    Enum.at(sorted, floor((length(sorted) - 1) / 2))
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "26397")
    IO.inspect(part1(test_input))
    IO.puts("Answer Part2 = " <> "288957")
    IO.inspect(part2(test_input))
  end

  def real_solution do
    test_input = read_input_file("input-4.txt")
    IO.puts(part1(test_input))
    IO.puts(part2(test_input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
