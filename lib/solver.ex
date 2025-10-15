defmodule Packer.Solver do
  def run(instance, opts \\ []) do
    model = build_mzn(instance)
    {:ok, result} = MinizincSolver.solve_sync(model, instance, build_opts(opts))

    summary = Map.get(result, :summary)

    case summary.status do
      :satisfied ->
        {:ok, summary.last_solution.data}

      failure ->
        {:no_solution, failure}
    end
  end

  defp default_opts() do
    [
      model: "minizinc/models/main.mzn",
      num_solutions: 1
    ]
  end

  defp build_opts(opts) do
    opts = Keyword.merge(default_opts(), opts)
    num_solutions = Keyword.get(opts, :num_solutions)
    solution_handler = Keyword.get(opts, :solution_handler, MinizincHandler.Default)

    Keyword.put(
      opts,
      :solution_handler,
      MinizincSearch.find_k_handler(num_solutions, solution_handler)
    )
  end

  defp build_mzn(instance) do
    File.read!("minizinc/models/main.mzn")
    |> String.split("\n", trim: true)
    |> Enum.flat_map(fn line ->
      if String.starts_with?(line, "include ") do
        mzn = String.split(line, ["include", ";"], trim: true) |> hd

        mzn_file = String.replace(String.trim(mzn), "\"", "")

        if admissible?(mzn_file, instance) do
          [Path.join("minizinc/models", mzn_file)]
        else
          []
        end
      else
        []
      end
    end)
  end

  ## Temporary, due to a bug in `solverl` - it generates array0 in dzn
  ## if an array is empty.
  ## So we explicitly skip process_links in this case,
  ## which Minizinc would not do anything with anyway.
  defp admissible?("process_links.mzn", %{num_process_links: 0} = _instance) do
    false
  end

  defp admissible?(_, _), do: true
end
