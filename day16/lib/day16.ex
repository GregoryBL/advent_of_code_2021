defmodule D16 do
  def parse_version(bits) do
    <<version::size(3), rest::bitstring>>
    {version, rest}
  end

  def parse_type(bits) do
    <<type_code::size(3), rest::bitstring>>

    if type_code == 4 do
      {:literal, 4, rest}
    else
      {:operator, type_code, rest}
    end
  end

  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> Base.decode16!()
  end

  def part1(input) do
    input
  end

  def part2(input) do
    input
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "1588")
    IO.inspect(part1(test_input))
    # IO.puts("Answer Part2 = " <> "2188189693529")
    # IO.inspect(part2(test_input))
  end

  def real_solution do
    # input = read_input_file("input-9.txt")
    # IO.puts(part1(input))
    # IO.inspect(part2(input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
