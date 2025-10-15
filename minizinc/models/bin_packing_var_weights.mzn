predicate bin_packing_var_weights(array[int] of int: c,

array[int] of var int: bin,
array[int] of var opt int: w) =
  forall( b in lb_array(bin)..ub_array(bin) ) (
    c[b] >= sum ( i in index_set(bin) ) (
      w[i] * bool2int( bin[i] = b )
    )
  );