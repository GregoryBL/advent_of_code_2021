defmodule Day4 do
  def read_input_file(name) do
    [input | boards] =
      File.read!(name)
      |> String.trim()
      |> String.split("\n\n")

    i = String.split(input, ",")

    bs =
      Enum.map(boards, fn l ->
        String.split(l, "\n")
        |> Enum.map(fn ns ->
          String.split(ns, " ")
          |> Enum.filter(fn c -> c != "" end)
        end)
      end)

    [i | bs]
  end

  def test_boards do
    [
      [
        ["88", "3", "15", "45", "95"],
        ["59", "2", "58", "98", "77"],
        ["62", "89", "80", "11", "74"],
        ["10", "49", "48", "72", "76"],
        ["86", "61", "53", "60", "44"]
      ],
      [
        ["77", "85", "1", "3", "76"],
        ["94", "30", "83", "6", "39"],
        ["80", "92", "24", "31", "46"],
        ["64", "47", "65", "7", "84"],
        ["23", "86", "79", "82", "34"]
      ]
    ]
  end

  def check_line(num, line) do
    Enum.filter(line, fn item -> item != num end)
  end

  def check_board(num, board) do
    Enum.map(board, fn l -> check_line(num, l) end)
  end

  def check_boards(inputs, boards) when length(inputs) == 0, do: boards

  def check_boards(inputs, boards) do
    [num | rest] = inputs
    res = Enum.map(boards, fn b -> check_board(num, b) end)

    case Enum.find(res, false, &check_board_for_win/1) do
      false -> check_boards(rest, res)
      win -> score_board(num, win)
    end
  end

  def score_board(num, board) do
    IO.inspect(board)
    board_score = List.flatten(board) |> Enum.map(&String.to_integer/1) |> Enum.sum()
    board_score * String.to_integer(num)
  end

  def check_board_for_win(board) do
    flipped = Enum.zip(board) |> Enum.map(&Tuple.to_list/1)
    Enum.any?(board, &Enum.empty?/1) || Enum.any?(flipped, &Enum.empty?/1)
  end

  def add_flipped_boards(boards) do
    flipped =
      Enum.map(boards, fn b ->
        Enum.zip(b) |> Enum.map(&Tuple.to_list/1)
      end)

    boards ++ flipped
  end

  def check_board_connected(num, board_c) do
    IO.inspect(board_c)

    Enum.map(board_c, fn board ->
      Enum.map(board, fn l -> check_line(num, l) end)
    end)
  end

  def score_board_connected(num, board) do
    IO.puts(num)
    b = Enum.at(board, 0)
    IO.inspect(b)
    board_score = List.flatten(b) |> Enum.map(&String.to_integer/1) |> Enum.sum()
    IO.puts(board_score)
    board_score * String.to_integer(num)
  end

  def check_board_for_win_connected(board_c) do
    Enum.any?(board_c, fn board ->
      Enum.any?(board, &Enum.empty?/1)
    end)
  end

  def check_boards_connected(inputs, boards) when length(inputs) == 0, do: boards

  def check_boards_connected(inputs, boards) do
    [num | rest] = inputs
    res = Enum.map(boards, fn b -> check_board_connected(num, b) end)

    case Enum.find(res, false, &check_board_for_win_connected/1) do
      false -> check_boards_connected(rest, res)
      win -> score_board_connected(num, win)
    end
  end

  def add_flipped_boards_connected(boards) do
    flipped =
      Enum.map(boards, fn b ->
        [Enum.zip(b) |> Enum.map(&Tuple.to_list/1), b]
      end)
  end

  def check_boards_lose(input, boards) do
    [num | rest] = input
    IO.inspect(boards)
    IO.puts(num)
    res = Enum.map(boards, fn b -> check_board_connected(num, b) end)

    remaining = Enum.filter(res, fn b -> not check_board_for_win_connected(b) end)
    IO.inspect(remaining)

    case length(remaining) do
      0 -> score_board_connected(num, Enum.at(res, 0))
      _ -> check_boards_lose(rest, remaining)
    end
  end

  def part2(input, boards) do
    all_boards = add_flipped_boards_connected(boards)
    check_boards_lose(input, all_boards)
  end

  def part1(input, boards) do
    # all_boards = add_flipped_boards_connected(boards)
    check_boards(input, boards)
  end

  def main do
    [input | boards] = read_input_file("input-4.txt")
    part1(input, boards)
    part2(input, boards)
  end
end
