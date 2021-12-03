defmodule Day3 do
  def read_input_file do
    File.read!("input-3.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn l ->
      l |> String.codepoints() |> Enum.map(&String.to_integer/1)
    end)
  end

  def part1(codes) do
    freqs =
      codes
      |> Enum.zip()
      |> Enum.map(&Tuple.sum/1)

    first = Enum.map(freqs, fn s -> round(s / length(codes)) end)
    second = Enum.map(first, fn s -> 1 - s end)

    convert_bin_list_to_int(first) * convert_bin_list_to_int(second)
  end

  def convert_bits_to_int(bits) do
    bs = bit_size(bits)
    <<val::size(bs)>> = bits
    val
  end

  def convert_bin_list_to_int(bin_list) do
    bin_list
    |> Enum.into(<<>>, fn bit -> <<bit::1>> end)
    |> convert_bits_to_int
  end

  def get_extreme(codes, position, most_or_least) do
    mol =
      case most_or_least do
        :most -> 1
        :least -> 0
      end

    freqs =
      codes
      |> Enum.zip()
      |> Enum.map(&Tuple.sum/1)

    total_num = length(codes)

    case Enum.at(freqs, position) * 2 / total_num >= 1 do
      true -> mol
      false -> 1 - mol
    end
  end

  # Recursively filter to the most extreme until there's a single code
  def find_code(codes, most_or_least), do: find_code(codes, most_or_least, 0)
  def find_code(codes, _most_or_least, _position) when length(codes) == 1, do: codes

  def find_code(codes, most_or_least, position) do
    most = get_extreme(codes, position, most_or_least)

    filtered =
      Enum.filter(codes, fn line ->
        Enum.at(line, position) == most
      end)

    find_code(filtered, most_or_least, position + 1)
  end

  def part2(codes) do
    [code] = find_code(codes, :most)
    oxy = convert_bin_list_to_int(code)

    [code2] = find_code(codes, :least)
    co2 = convert_bin_list_to_int(code2)

    oxy * co2
  end

  def main do
    codes = read_input_file()
    IO.puts(part1(codes))
    IO.puts(part2(codes))
  end

  def test do
    [
      [0, 0, 1, 0, 0],
      [1, 1, 1, 1, 0],
      [1, 0, 1, 1, 0],
      [1, 0, 1, 1, 1],
      [1, 0, 1, 0, 1],
      [0, 1, 1, 1, 1],
      [0, 0, 1, 1, 1],
      [1, 1, 1, 0, 0],
      [1, 0, 0, 0, 0],
      [1, 1, 0, 0, 1],
      [0, 0, 0, 1, 0],
      [0, 1, 0, 1, 0]
    ]
  end
end
