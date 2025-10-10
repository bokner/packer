defmodule ClusterMap.Instance do
  @doc """
    Generates instance of cluster data.
    It's a map with:

    :topology - the adjacency matrix of topology graph (connections between nodes);
    :process_links - the adjacency matrix of link graph (pairs of processes that have to communicate);
    :nodes - map `node => data`;
    :processes - map `process => data`;
  """
  @spec generate(pos_integer(), pos_integer(), Keyword.t()) :: map()
  def generate(num_nodes, num_processes, opts \\ []) do
    opts = Keyword.merge(default_opts(), opts)

    %{
      num_nodes: num_nodes,
      num_processes: num_processes,
      topology: generate_topology(num_nodes, opts),
      process_links: generate_process_links(num_processes, opts),
      nodes: generate_nodes(num_nodes, opts),
      processes: generate_processes(num_processes, opts)
    }
    |> then(fn instance ->
      case Keyword.get(opts, :handler) do
        nil -> instance
        handler_fun -> handler_fun.(instance, opts)
      end
    end)
  end

  # Generates adjacency matrix for topology graph
  defp generate_topology(num_nodes, _opts) do
    generate_adjacency_matrix(num_nodes)
  end

  defp generate_process_links(num_processes, _opts) do
    generate_adjacency_matrix(num_processes)
  end

  defp generate_adjacency_matrix(num_vertices) do
    Enum.map(
      1..(num_vertices * num_vertices),
      fn _ ->
        hd(Enum.take_random([true, false], 1))
      end
    )
    |> Enum.chunk_every(num_vertices)
  end

  defp generate_nodes(num_nodes, opts) do
    Enum.map(1..num_nodes, fn n ->
      %{
        node_id: n,
        memory: Enum.take_random(opts[:node_memory_range], 1) |> hd,
        cpu: Enum.take_random(opts[:node_cpu_range], 1) |> hd
      }
    end)
  end

  def generate_processes(num_processes, opts) do
    Enum.map(1..num_processes, fn n ->
       %{
         process_id: n,
         memory: Enum.take_random(opts[:process_memory_range], 1) |> hd,
         load: Enum.take_random(opts[:process_cpu_load_range], 1) |> hd
       }
    end)
  end

  defp default_opts() do
    [
      node_memory_range: 512..2048,
      node_cpu_range: 500..1000,
      process_memory_range: 10..512,
      process_cpu_load_range: 100..600,
      handler: &to_minizinc/2
    ]
  end

  defp to_minizinc(instance, opts) do
    {process_memory, process_load} =
      Enum.reduce(instance[:processes], {[], []}, fn %{memory: memory, load: load},
                                                     {m_acc, l_acc} ->
        {[memory | m_acc], [load | l_acc]}
      end)

    {node_memory, node_cpu} =
      Enum.reduce(instance[:nodes], {[], []}, fn %{memory: memory, cpu: cpu}, {m_acc, l_acc} ->
        {[memory | m_acc], [cpu | l_acc]}
      end)

    MinizincData.to_dzn(
      %{
        num_nodes: Map.get(instance, :num_nodes),
        num_processes: Map.get(instance, :num_processes),
        process_links: Map.get(instance, :process_links),
        topology: Map.get(instance, :topology),
        process_memory: Enum.reverse(process_memory),
        process_load: Enum.reverse(process_load),
        node_memory: Enum.reverse(node_memory),
        node_cpu: node_cpu
    })
  end
end
