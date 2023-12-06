defmodule AdventOfCode.Day04 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.reduce(0, fn %{winning_numbers: winning_numbers, your_numbers: your_numbers}, sum ->
      case winning_matches(winning_numbers, your_numbers) do
        [] ->
          sum

        winners ->
          sum + Integer.pow(2, length(winners) - 1)
      end
    end)
  end

  def part2(input) do
    list_of_cards = input |> parse_input()

    cards_by_id =
      Enum.reduce(list_of_cards, %{}, fn %{id: id} = card, acc ->
        Map.put(acc, id, Map.put(card, :copies, 1))
      end)

    list_of_cards
    |> Enum.reduce(cards_by_id, fn %{
                                     id: id,
                                     winning_numbers: winning_numbers,
                                     your_numbers: your_numbers
                                   },
                                   tracking ->
      case winning_matches(winning_numbers, your_numbers) do
        [] ->
          tracking

        winners ->
          1..length(winners)
          |> Enum.reduce(tracking, fn add_to_id, acc ->
            card_as_is = acc[id + add_to_id]

            card_with_new_count =
              Map.put(card_as_is, :copies, card_as_is[:copies] + tracking[id][:copies])

            Map.put(acc, id + add_to_id, card_with_new_count)
          end)
      end
    end)
    |> Enum.reduce(0, fn {_id, %{copies: copies}}, acc -> acc + copies end)
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      {id, winning_numbers, your_numbers} = split_data(line)

      %{id: String.to_integer(id), winning_numbers: winning_numbers, your_numbers: your_numbers}
    end)
  end

  defp split_data("Card " <> rest) do
    [id, data] = String.split(rest, ":")

    [winning_numbers, your_numbers] =
      data
      |> String.trim()
      |> String.split("|")
      |> Enum.map(&String.split(&1, " ", trim: true))

    {String.trim(id), winning_numbers, your_numbers}
  end

  defp winning_matches(winning_numbers, your_numbers) do
    Enum.filter(your_numbers, fn yours ->
      Enum.find(winning_numbers, &(yours == &1))
    end)
  end
end
