defmodule Packer.Solver do
  def run(instance, opts \\ []) do
    model = build_mzn()
    {:ok, result} = MinizincSolver.solve_sync(model, instance, build_opts(opts))

    summary = Map.get(result, :summary)
    case summary.status do
      :satisfied ->
        {:ok, summary.last_solution.data}
      failure -> {:no_solution, failure}
    end

  end

  def check(instance, solution) do
    
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
    Keyword.put(opts, :solution_handler, MinizincSearch.find_k_handler(num_solutions, solution_handler))
  end

  ## This is a hack due to how the current solverl implementation
  ## deals with passing instances to MiniZinc
  defp build_mzn() do
    File.read!("minizinc/models/main.mzn")
    |> String.split(["include", ";", "\n"],trim: true)
    |> Enum.map(fn mzn ->
      Path.join("minizinc/models", String.replace(String.trim(mzn), "\"", "")) end)
  end
end
