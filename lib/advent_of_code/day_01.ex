defmodule AdventOfCode.Day01 do
  def part1(input) do
    input
    |> separate_input()
    |> Enum.map(fn line ->
      numbers = Regex.scan(~r/(\d)/, line)

      [_, first] = List.first(numbers)
      [_, last] = List.last(numbers)

      String.to_integer("#{first}#{last}")
    end)
    |> Enum.sum()
  end

  def part2(input) do
    mapping = %{
      "one" => 1,
      "two" => 2,
      "three" => 3,
      "four" => 4,
      "five" => 5,
      "six" => 6,
      "seven" => 7,
      "eight" => 8,
      "nine" => 9
    }

    regex = ~r/(\d|one|two|three|four|five|six|seven|eight|nine)/

    input
    |> separate_input()
    |> Enum.map(fn line ->
      numbers = Regex.scan(regex, line)

      [_, first] = List.first(numbers)
      [_, last] = List.last(numbers)

      String.to_integer("#{Map.get(mapping, first, first)}#{Map.get(mapping, last, last)}")
    end)
    |> Enum.sum()
  end

  defp separate_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
  end
end
