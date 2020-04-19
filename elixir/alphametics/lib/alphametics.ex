defmodule Alphametics do
  @type puzzle :: binary
  @type solution :: %{required(?A..?Z) => 0..9}

  @doc """
  Takes an alphametics puzzle and returns a solution where every letter
  replaced by its number will make a valid equation. Returns `nil` when
  there is no valid solution to the given puzzle.

  ## Examples

      iex> Alphametics.solve("I + BB == ILL")
      %{?I => 1, ?B => 9, ?L => 0}

      iex> Alphametics.solve("A == B")
      nil
  """
  @spec solve(puzzle) :: solution | nil
  def solve(puzzle) do
    letters = extract_letters(puzzle)
    nonzero = extract_nonzero_letters(puzzle)
    make_solutions(Enum.count(letters))
    |> Enum.find_value(&solves(letters, &1, puzzle, nonzero))
  end

  defp extract_letters(puzzle) do
    puzzle
    |> String.graphemes
    |> Enum.filter(&(&1 >= "A" and &1 <= "Z"))
    |> Enum.uniq
  end

  defp extract_nonzero_letters(puzzle) do
    puzzle
    |> String.split(" == ")
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&hd/1)
    |> Enum.uniq
  end

  defp make_solutions(len) do
    (0..9)
    |> Enum.map(&Integer.to_string/1)
    |> perms(len)
  end

  defp perms([]  , _), do: [[]]
  defp perms(_   , 0), do: [[]]
  defp perms(list, n) do
    Stream.flat_map(list, &prepend_to_subperms(&1, list -- [&1], n - 1))
  end

  defp prepend_to_subperms(first, list, n) do
    Stream.map(perms(list, n), &([first | &1]))
  end

  defp solves(letters, digits, puzzle, nonzero) do
    if no_bad_zero(letters, digits, nonzero) do
      translated = translate(puzzle, letters, digits)
      {res, _} = Code.eval_string(translated)
      if res, do: fixup_solution(letters, digits), else: nil
    else
      nil
    end
  end

  defp no_bad_zero(letters, digits, nonzero) do
    zero = find_zero(letters, digits)
    zero == nil or zero not in nonzero
  end

  defp find_zero([]           , []          ), do: nil
  defp find_zero([letter | _] , ["0" | _]   ), do: letter
  defp find_zero([_ | letters], [_ | digits]), do: find_zero(letters, digits)

  defp translate(puzzle, [],                 []              ), do: puzzle
  defp translate(puzzle, [letter | letters], [digit | digits]),
    do: translate(String.replace(puzzle, letter, digit), letters, digits)

  defp fixup_solution(letters, digits) do
    (for {let, dig} <- Enum.zip(letters, digits) do
       {let
        |> String.to_charlist
        |> hd,
        dig
        |> String.to_integer}
    end)
    |> Map.new
  end
end
