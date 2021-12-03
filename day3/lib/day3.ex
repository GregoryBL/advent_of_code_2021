defmodule Day3 do

  def read_input_file do
    File.read!("input-3.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn l ->
      [_| arr ] = String.split(l, "")
      Enum.drop(arr, -1) |> Enum.map(&String.to_integer/1)

    end)
  end

  def part1(dirs) do
    start_values = for _ <- 1..12, do: {0, 0}

    freqs = dirs
    |> Enum.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.sum/1)

    <<first::12>> = freqs
    |> Enum.map(fn s ->
      if s > length(dirs) / 2 do
        1
      else
        0
      end
    end)
    |> Enum.into(<<>>, fn bit -> <<bit :: 1>> end)

    second = freqs
    |> Enum.map(fn s ->
      if s > length(dirs) / 2 do
        0
      else
        1
      end
    end)
    |> convert_bin_list_to_int

    # IO.puts(first)
    # IO.puts(second)
    # IO.puts(first * second)

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

  # Big is 1 if "most" 0 if "least"
  def get_most_common(codes, position, big) do
    freqs = codes
    |> Enum.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.sum/1)

    total_num = length(codes)

    case (Enum.at(freqs, position) * 2 / total_num) >= 1 do
      true -> big
      false -> (1 - big)
    end
  end

  def filter_by_most_common(codes, position, big) do
    most = get_most_common(codes, position, big)
    filtered = Enum.filter(codes, fn line ->
      Enum.at(line, position) == most
    end)

    if length(filtered) > 1 do
      filter_by_most_common(filtered, position + 1, big)
    else
      filtered
    end
  end

  def part2(dirs) do
    [code] = filter_by_most_common(dirs, 0, 1)
    oxy = convert_bin_list_to_int(code)

    [code2] = filter_by_most_common(dirs, 0, 0)
    co2 = convert_bin_list_to_int(code2)

    oxy * co2


    # d1 = get_most_common(dirs, 0)
    # Enum.filter(dirs, fn line ->
    #   Enum.at(line, 0) == d1
    # end)
    # get_most_common(lines, 1)
  end

  def main do
    dirs = read_input_file()
    IO.puts(part1(dirs))
    IO.puts(part2(dirs))
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
