defmodule ClusterMap.Instance do
  @doc """
    Generates instance of cluster data.
    It's a map with

    :topology - the adjacency matrix of topology graph (connections between nodes);
    :process_links - the adjacency matrix of link graph (pairs of processes that have to communicate);
    :nodes - map `node => data`;
    :processes - map `process => data`;
  """
  @spec generate(pos_integer(), pos_integer(), Keyword.t()) :: map()
  def generate(num_nodes, num_processes, opts \\ []) do
    opts = Keyword.merge(default_opts(), opts)
    %{
    topology: generate_topology(num_nodes, opts),
    process_links: generate_process_links(num_processes, opts),
    nodes: generate_nodes(num_nodes, opts),

    processes: generate_processes(num_processes, opts)
    }

  end

  # Generates adjacency matrix for topology graph
  defp generate_topology(num_nodes, _opts) do
    generate_adjacency_matrix(num_nodes)
  end

  defp generate_process_links(num_processes, _opts) do
    generate_adjacency_matrix(num_processes)
  end

  defp generate_adjacency_matrix(num_vertices) do
    Enum.map(1..num_vertices * num_vertices,
    fn _ ->
      hd(Enum.take_random([true, false], 1))
    end)
    |> Enum.chunk_every(num_vertices)
  end

  defp generate_nodes(num_nodes, opts) do
    Map.new(1..num_nodes, fn n ->
      {n, %{
        memory: Enum.take_random(opts[:node_memory_range], 1) |> hd,
        cpu: Enum.take_random(opts[:node_cpu_range], 1) |> hd
      }} end)
  end

  def generate_processes(num_processes, opts) do
    Map.new(1..num_processes, fn n ->
      {n, %{
        memory: Enum.take_random(opts[:process_memory_range], 1) |> hd,
        load: Enum.take_random(opts[:process_cpu_load_range], 1) |> hd
      }} end)
  end

  defp default_opts() do
    [
      node_memory_range: 512..2048,
      node_cpu_range: 500..1000,
      process_memory_range: 10..512,
      process_cpu_load_range: 100..600
    ]
  end
end
