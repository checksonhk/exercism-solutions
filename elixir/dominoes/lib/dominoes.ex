defmodule Dominoes do
  @type domino :: {1..6, 1..6}

  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino] | []) :: boolean
  def chain?([]), do: true
  def chain?([{ender, starter} | tail]), do: any_chains?(tail, starter, ender)

  defp any_chains?([], starter, starter), do: true
  defp any_chains?([], _, _), do: false  # redundant but efficient & logical
  defp any_chains?(pool, starter, ender),
    do: Enum.any?(pool, &do_chain(&1, List.delete(pool, &1), starter, ender))

  # if the first one matches our needs, look for ways to make further progress
  defp do_chain({starter, other}, rest, starter, ender),
    do: any_chains?(rest, other, ender)

  # else if it matches backwards, defer to forward case
  defp do_chain({other, starter}, rest, starter, ender),
    do: do_chain({starter, other}, rest, starter, ender)

  # else this chain attempt is a dead end
  defp do_chain(_, _, _, _), do: false

end
