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
    check_process_links(instance, solution) and
    check_memory(instance, solution) and
    check_load(instance, solution)
  end

  def check_process_links(%{
        process_links_from: links_from,
        process_links_to: links_to,
        topology: topology
      } = _instance, %{"process_placement" => mapping} = _solution) do

     Enum.all?(Enum.zip(links_from, links_to), fn {from, to} ->
      from_node = Enum.at(mapping, from - 1)
      to_node = Enum.at(mapping, to - 1)
      Enum.at(Enum.at(topology, from_node - 1), to_node - 1)
     end)
  end

  def check_load(
    %{
      process_load: process_load,
      node_cpu: node_cpu
      } = _instance, %{"processes_on_node" => mapping} = _solution) do
    Enum.all?(Enum.zip(node_cpu, mapping),
    fn {node_load, processes} ->
      Enum.sum_by(processes, fn p_id -> Enum.at(process_load, p_id - 1) end) <= node_load
    end)
  end

  def check_memory(
    %{
      process_memory: process_memory,
      node_memory: node_memory
      } = _instance, %{"processes_on_node" => mapping} = _solution) do
    Enum.all?(Enum.zip(node_memory, mapping),
    fn {node_memory, processes} ->
      Enum.sum_by(processes, fn p_id -> Enum.at(process_memory, p_id - 1) end) <= node_memory
    end)
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
