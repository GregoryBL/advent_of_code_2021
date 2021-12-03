defmodule Day3 do

  def read_input_file do
    File.read!("input-3.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn l ->
      l |> String.codepoints |> Enum.map(&String.to_integer/1)
    end)
  end

  def part1(codes) do
    freqs = codes
    |> Enum.zip
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
    |> Enum.into(<<>>, fn bit -> <<bit :: 1>> end)
    |> convert_bits_to_int
  end

  # 1 if "most" 0 if "least"
  def get_extreme(codes, position, most_or_least) do
    freqs = codes
    |> Enum.zip
    |> Enum.map(&Tuple.sum/1)

    total_num = length(codes)

    case (Enum.at(freqs, position) * 2 / total_num) >= 1 do
      true -> most_or_least
      false -> (1 - most_or_least)
    end
  end

  # Recursively filter to the most extreme until there's a single code
  def find_code(codes, position, most_or_least) do
    most = get_extreme(codes, position, most_or_least)

    filtered = Enum.filter(codes, fn line ->
      Enum.at(line, position) == most
    end)

    if length(filtered) > 1 do
      find_code(filtered, position + 1, most_or_least)
    else
      filtered
    end
  end

  def part2(codes) do
    [code] = find_code(codes, 0, 1)
    oxy = convert_bin_list_to_int(code)

    [code2] = find_code(codes, 0, 0)
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
    [1,1,1,1,0],
    [1,0, 1, 1, 0],
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
