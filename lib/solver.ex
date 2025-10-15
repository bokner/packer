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

  def check(instance, solution) do
    check_process_links(instance, solution) and
      check_memory(instance, solution) and
      check_load(instance, solution) and
      check_bandwidth(instance, solution)
  end

  def check_process_links(
        %{
          process_links_from: links_from,
          process_links_to: links_to,
          topology: topology
        } = _instance,
        %{"process_placement" => mapping, "remote_call" => remote_call} = _solution
      ) do
    Enum.all?(Enum.zip([links_from, links_to, remote_call]), fn {from, to, remote_call_flag} ->
      from_node = Enum.at(mapping, from - 1)
      to_node = Enum.at(mapping, to - 1)
      ## nodes are the same or connected
      ## remote calls properly identifies
      (Enum.at(Enum.at(topology, from_node - 1), to_node - 1) and
         remote_call_flag == 0) || (remote_call_flag == 1 and from_node != to_node)
    end)
  end

  def check_load(
        %{
          process_load: process_load,
          node_cpu: node_cpu
        } = _instance,
        %{"processes_on_node" => mapping} = _solution
      ) do
    Enum.all?(
      Enum.zip(node_cpu, mapping),
      fn {node_load, processes} ->
        Enum.sum_by(processes, fn p_id -> Enum.at(process_load, p_id - 1) end) <= node_load
      end
    )
  end

  def check_memory(
        %{
          process_memory: process_memory,
          node_memory: node_memory
        } = _instance,
        %{"processes_on_node" => mapping} = _solution
      ) do
    Enum.all?(
      Enum.zip(node_memory, mapping),
      fn {node_memory, processes} ->
        Enum.sum_by(processes, fn p_id -> Enum.at(process_memory, p_id - 1) end) <= node_memory
      end
    )
  end

  defp check_bandwidth(
         %{
           process_links_from: links_from,
           process_links_to: links_to,
           node_bandwidth_out: node_bandwidth_out,
           process_message_volume: process_message_volume
         } = _instance,
         %{"remote_call" => remote_call_flags, "processes_on_node" => processes_on_node} =
           _solution
       ) do
    callers =
      remote_call_flags
      |> Enum.zip(links_from)
      |> Enum.flat_map(fn {r_flag, from} -> (r_flag == 1 && [from]) || [] end)
      |> MapSet.new()

    caller_volumes =
      process_message_volume
      |> Enum.with_index(1)
      |> Enum.filter(fn {_volume, idx} -> idx in callers end)
      |> Map.new(fn {v, idx} -> {idx, v} end)

    processes_on_node
    |> Enum.zip(node_bandwidth_out)
    |> Enum.all?(fn {processes, node_bandwidth} ->
      callers_on_node = MapSet.intersection(callers, processes)

      node_bandwidth >=  Enum.sum_by(
          callers_on_node,
          fn caller -> Map.get(caller_volumes, caller) end)

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

    Keyword.put(
      opts,
      :solution_handler,
      MinizincSearch.find_k_handler(num_solutions, solution_handler)
    )
  end

  defp build_mzn(instance) do
    File.read!("minizinc/models/main.mzn")
    |> String.split(["include", ";", "\n"], trim: true)
    |> Enum.flat_map(fn mzn ->
      mzn_file = String.replace(String.trim(mzn), "\"", "")

      if admissible?(mzn_file, instance) do
        [Path.join("minizinc/models", mzn_file)]
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
