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

  def process_line(num, line) do
    Enum.filter(line, fn item -> item != num end)
  end

  def process_board(num, board_c) do
    Enum.map(board_c, fn board ->
      Enum.map(board, fn l -> process_line(num, l) end)
    end)
  end

  def score_board(num, board) do
    b = Enum.at(board, 0)
    board_score = List.flatten(b) |> Enum.map(&String.to_integer/1) |> Enum.sum()
    board_score * String.to_integer(num)
  end

  def check_board_for_win(board_c) do
    Enum.any?(board_c, fn board ->
      Enum.any?(board, &Enum.empty?/1)
    end)
  end

  def add_flipped_boards(boards) do
    Enum.map(boards, fn b ->
      [Enum.zip(b) |> Enum.map(&Tuple.to_list/1), b]
    end)
  end

  def find_best_board(inputs, boards) when length(inputs) == 0, do: boards

  def find_best_board(inputs, boards) do
    [num | rest] = inputs
    # Remove all examples of "num"
    res = Enum.map(boards, fn b -> process_board(num, b) end)

    # If a board won, score it, else continue
    case Enum.find(res, false, &check_board_for_win/1) do
      false -> find_best_board(rest, res)
      win -> score_board(num, win)
    end
  end

  def find_worst_board(inputs, boards) when length(inputs) == 0, do: boards

  def find_worst_board(input, boards) do
    [num | rest] = input
    # Remove all examples of "num"
    res = Enum.map(boards, fn b -> process_board(num, b) end)

    # Filter out won boards
    remaining = Enum.filter(res, fn b -> not check_board_for_win(b) end)

    # If we've none left, the board when we started was the winner. Score it
    case length(remaining) do
      0 -> score_board(num, Enum.at(res, 0))
      _ -> find_worst_board(rest, remaining)
    end
  end

  def part2(input, boards) do
    # Boards in this step need to actually be connected. We store [ original, zipped ] for each board
    all_boards = add_flipped_boards(boards)
    find_worst_board(input, all_boards)
  end

  def part1(input, boards) do
    # This part didn't need them connected (just find the first completed), but was updated to use the same
    # data structure as part 2
    all_boards = add_flipped_boards(boards)
    find_best_board(input, all_boards)
  end

  def main do
    [input | boards] = read_input_file("input-4.txt")
    IO.puts(part1(input, boards))
    IO.puts(part2(input, boards))
  end
end
