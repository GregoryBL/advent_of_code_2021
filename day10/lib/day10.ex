defmodule Day10 do
  defmodule Parser do
    defstruct [:name, :repr, :parser]
  end

  def parser(name, repr, parser) do
    %Parser{
      name: name,
      repr: repr,
      parser: parser
    }
  end

  defimpl String.Chars, for: Parser do
    def to_string(term) do
      term.repr
    end
  end

  defmodule ParseResult do
    defstruct [:status, :match_list, :remainder, errors: []]
  end

  def parse_result(status, match_list, remainder, errors \\ []) do
    %ParseResult{
      status: status,
      match_list: match_list,
      remainder: remainder,
      errors: errors
    }
  end

  defmodule ParseError do
    defstruct [:type, :fail_char, :fail_parser, :num_matched]
  end

  def parse_error(type, fail_char, fail_parser, num_matched) do
    %ParseError{
      type: type,
      fail_char: fail_char,
      fail_parser: fail_parser,
      num_matched: num_matched
    }
  end

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

  # Creates Parsers
  def exact(find) do
    repr = "Exact(#{find})"

    parser("exact", repr, fn stream ->
      case stream do
        [] ->
          parse_result(
            :error,
            [],
            [],
            [parse_error(:eoi, nil, repr, 0)]
          )

        [^find | rest] ->
          parse_result(:ok, [find], rest)

        [first | rest] ->
          parse_result(:error, [], [first | rest], [
            parse_error(
              :matchfail,
              first,
              repr,
              0
            )
          ])
      end
    end)
  end

  def end_of_input() do
    repr = "$"

    parser("end_of_input", repr, fn stream ->
      case stream do
        [] ->
          parse_result(:ok, [], stream, [])

        [first | _] ->
          parse_result(
            :error,
            [],
            stream,
            [
              parse_error(
                :matchfail,
                first,
                repr,
                0
              )
            ]
          )
      end
    end)
  end

  # Combinators

  def bind(p) do
    fn parse_result ->
      %ParseResult{status: status} = parse_result

      case status do
        :ok ->
          res = p.parser.(parse_result.remainder)

          case res.status do
            :ok ->
              parse_result(
                :ok,
                parse_result.match_list ++ res.match_list,
                res.remainder,
                parse_result.errors ++ add_match_to_errors(parse_result, res.errors)
              )

            :error ->
              parse_result(
                :error,
                parse_result.match_list ++ res.match_list,
                parse_result.remainder,
                parse_result.errors ++ add_match_to_errors(parse_result, res.errors)
              )
          end

        :error ->
          parse_result
      end
    end
  end

  def add_match_to_errors(result, errors) do
    IO.puts("ADD")
    IO.inspect(result)
    IO.inspect(errors)

    Enum.map(errors, fn err ->
      parse_error(
        err.type,
        err.fail_char,
        err.fail_parser,
        err.num_matched + length(result.match_list)
      )
    end)
  end

  def _zero_or_more(parser, input) do
    res = run(parser, input)

    case res.status do
      :ok ->
        in_res = _zero_or_more(parser, res.remainder)

        parse_result(
          :ok,
          res.match_list ++ in_res.match_list,
          in_res.remainder,
          add_match_to_errors(res, in_res.errors) ++ res.errors
        )

      :error ->
        parse_result(:ok, res.match_list, res.remainder, res.errors)
    end
  end

  def zero_or_more(parser) do
    repr = "#{parser}*"

    parser(
      "zero_or_more",
      repr,
      fn input ->
        res = _zero_or_more(parser, input)

        case res.status do
          :ok ->
            res

          :error ->
            IO.puts("outer error")

            longest_error =
              Enum.max(res.errors, fn a, b ->
                a.num_matched >= b.num_matched
              end)

            parse_result(
              :error,
              res.match_list,
              res.remainder,
              parse_error(
                longest_error.type,
                longest_error.fail_char,
                repr,
                longest_error.num_matched
              )
            )
        end
      end
    )
  end

  def oneOf(parsers) do
    repr = "OneOf(#{Enum.join(parsers, ", ")})"

    parser(
      "oneOf",
      repr,
      fn input ->
        res =
          Enum.reduce(parsers, parse_result(:error, nil, input, []), fn p, acc ->
            case acc.status do
              :ok ->
                acc

              :error ->
                result = p.parser.(input)

                case result.status do
                  :ok ->
                    result

                  :error ->
                    parse_result(
                      :error,
                      [],
                      input,
                      result.errors ++ acc.errors
                    )
                end
            end
          end)

        # Give a better error saying we failed OneOf
        case res.status do
          :ok ->
            res

          :error ->
            longest_error =
              Enum.max(res.errors, fn a, b ->
                a.num_matched >= b.num_matched
              end)

            parse_result(
              :error,
              [],
              input,
              [
                parse_error(
                  longest_error.type,
                  longest_error.fail_char,
                  repr,
                  longest_error.num_matched
                )
              ]
            )
        end
      end
    )
  end

  def run(parser, input) do
    parser.parser.(input)
  end

  def andThen(p1, p2) do
    %Parser{
      name: "andThen",
      repr: "And(#{p1.repr}, #{p2.repr})",
      parser: fn input ->
        bind(p2).(p1.parser.(input))
      end
    }
  end

  def return(input) do
    parse_result(:ok, [], input)
  end

  def null_parser() do
    parser("", "", &return/1)
  end

  def sequence(parsers) do
    repr = "Sequence(#{Enum.join(parsers, ", ")})"

    parser(
      "sequence",
      repr,
      fn input ->
        res =
          Enum.reduce(parsers, null_parser().parser.(input), fn p, acc ->
            bind(p).(acc)
          end)

        case res.status do
          :ok ->
            res

          :error ->
            last_err = Enum.at(res.errors, 0)
            IO.inspect(res)

            parse_result(
              res.status,
              [],
              input,
              [
                parse_error(
                  last_err.type,
                  last_err.fail_char,
                  repr,
                  length(res.match_list)
                )
              ]
            )
        end
      end
    )
  end

  def end_pair(left_char) do
    right_char = left_to_right(left_char)

    sequence([zero_or_more(pair()), exact(right_char)])
  end

  def pair() do
    parser(
      "pair",
      "pair",
      fn input ->
        result = run(oneOf(Enum.map(["(", "{", "[", "<"], &exact/1)), input)

        case result.status do
          :ok ->
            res = bind(end_pair(Enum.at(result.match_list, 0))).(result)
            IO.puts("HI")
            IO.inspect(res)

            case res.status do
              :ok ->
                res

              :error ->
                err = Enum.at(res.errors, 0)

                parse_result(
                  :error,
                  [],
                  input,
                  [
                    parse_error(
                      err.type,
                      err.fail_char,
                      "pair",
                      err.num_matched + length(res.match_list)
                    )
                  ]
                )
            end

          :error ->
            err = Enum.at(result.errors, 0)

            parse_result(
              :error,
              [],
              input,
              [
                parse_error(
                  err.type,
                  err.fail_char,
                  "pair",
                  0
                )
              ]
            )
        end
      end
    )
  end

  def find_best_error(errors) do
    Enum.reduce(errors, parse_error(:matchfail, nil, "null", 0), fn e, acc ->
      cond do
        acc.type == :eoi -> acc
        e.type == :eoi -> e
        e.num_matched > acc.num_matched -> e
        true -> acc
      end
    end)
  end

  def value_letter(let) do
    case let do
      ")" -> 3
      "]" -> 57
      "}" -> 1197
      ">" -> 25137
    end
  end

  def part1(input) do
    Enum.map(input, fn line ->
      res = run(zero_or_more(pair()), line)

      # case res.status do
      #   :ok ->
      #     {:ok, 0}

      #   :error ->
      #     err = find_best_error(res.errors)

      #     case err.type do
      #       :eoi -> {:ok, 0}
      #       :matchfail -> {:err, value_letter(err.fail_char)}
      #     end
      # end
    end)
  end

  def part2(input) do
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "26397")
    IO.inspect(part1(test_input))
    # IO.puts("Answer Part2 = " <> "")
    # IO.puts(part2(test_input))
  end

  def real_solution do
    # test_input = read_input_file("input-2.txt")
    # IO.puts(part1(test_input))
    # IO.puts(part2(test_input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
