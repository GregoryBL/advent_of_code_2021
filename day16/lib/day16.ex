defmodule D16 do
  defmodule Packet do
    defstruct [:version, :type, value: nil, subpackets: []]
  end

  def parse_header(stream) do
    <<version::size(3), type_code::size(3), rest::bitstring>> = stream

    type =
      case type_code do
        0 -> :sum
        1 -> :product
        2 -> :minimum
        3 -> :maximum
        4 -> :literal
        5 -> :greater
        6 -> :less
        7 -> :equal
      end

    {version, type, rest}
  end

  def parse_literal(stream) do
    {lit_bits, rest} = _parse_literal_packet(stream)

    len = bit_size(lit_bits)

    <<lit::integer-size(len)>> = lit_bits

    {lit, rest}
  end

  def _parse_literal_packet(stream) do
    <<more?::1, nibble::bitstring-size(4), rest::bitstring>> = stream

    if more? == 1 do
      {subs, leftover} = _parse_literal_packet(rest)

      new = <<nibble::bitstring, subs::bitstring>>

      {new, leftover}
    else
      {nibble, rest}
    end
  end

  def parse_operator(stream) do
    <<op_len_type::bitstring-size(1), rest::bitstring>> = stream

    {type, num, rest} =
      if op_len_type == <<0::1>> do
        <<op_len_bits::bitstring-size(15), rest::bitstring>> = rest
        <<op_len::integer-size(15)>> = op_len_bits
        {:bits, op_len, rest}
      else
        <<op_pkts_bits::bitstring-size(11), rest::bitstring>> = rest
        <<op_pkts::integer-size(11)>> = op_pkts_bits
        {:packets, op_pkts, rest}
      end

    parse_subpackets(rest, type, num)
  end

  def parse_subpackets(stream, :bits, num_bits) do
    <<internal_bits::bitstring-size(num_bits), rest::bitstring>> = stream

    {parse_multiple(internal_bits), rest}
  end

  def parse_subpackets(stream, :packets, num_packets) do
    parse_n_packets(stream, num_packets)
  end

  def parse_single_packet(stream) do
    {version, type, rest} = parse_header(stream)

    if type == :literal do
      {lit, rem} = parse_literal(rest)

      {%Packet{
         version: version,
         type: type,
         value: lit
       }, rem}
    else
      {subp, rem} = parse_operator(rest)

      {%Packet{
         version: version,
         type: type,
         subpackets: subp
       }, rem}
    end
  end

  def parse_multiple(stream) do
    {packet, rem} = parse_single_packet(stream)

    remaining_bits = bit_size(rem)

    if remaining_bits == 0 do
      [packet]
    else
      [packet | parse_multiple(rem)]
    end
  end

  def parse_n_packets(stream, 0), do: {[], stream}

  def parse_n_packets(stream, n) do
    {pkt, rem} = parse_single_packet(stream)
    {rest_of_packets, rest} = parse_n_packets(rem, n - 1)
    {[pkt | rest_of_packets], rest}
  end

  def parse(stream) do
    {packet, _rem} = parse_single_packet(stream)
    packet
  end

  def sum_versions(packet) do
    Enum.reduce(packet.subpackets, packet.version, fn p, acc ->
      acc + sum_versions(p)
    end)
  end

  def evaluate(packet) do
  end

  def packet_value(p) do
    if p.type == :literal do
      p.value
    else
      combine_packets(p.subpackets, p.type)
    end
  end

  def combine_packets(pkts, :sum) do
    Enum.reduce(pkts, 0, fn p, acc ->
      acc + packet_value(p)
    end)
  end

  def combine_packets(pkts, :product) do
    Enum.reduce(pkts, 1, fn p, acc ->
      acc * packet_value(p)
    end)
  end

  def combine_packets(pkts, :minimum) do
    Enum.reduce(pkts, nil, fn p, acc ->
      min(acc, packet_value(p))
    end)
  end

  def combine_packets(pkts, :maximum) do
    Enum.reduce(pkts, -1, fn p, acc ->
      max(acc, packet_value(p))
    end)
  end

  def combine_packets([p1, p2], :greater) do
    if packet_value(p1) > packet_value(p2) do
      1
    else
      0
    end
  end

  def combine_packets([p1, p2], :less) do
    if packet_value(p1) < packet_value(p2) do
      1
    else
      0
    end
  end

  def combine_packets([p1, p2], :equal) do
    if packet_value(p1) == packet_value(p2) do
      1
    else
      0
    end
  end

  ######################################

  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> Base.decode16!()
  end

  ######################################

  def part1(input) do
    parse(input)
    |> sum_versions()
  end

  def part2(input) do
    parse(input)
    |> packet_value()
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "16")
    IO.inspect(part1(test_input))
    IO.puts("Answer Part2 = " <> "1")
    IO.inspect(part2(test_input))
  end

  def real_solution do
    input = read_input_file("input-10.txt")
    IO.puts(part1(input))
    IO.inspect(part2(input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
