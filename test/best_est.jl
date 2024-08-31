# %%
function print_subtypes(T, indent_level=0)
  println(" "^indent_level, T)
  for S in subtypes(T)
    print_subtypes(S, indent_level + 2)
  end
  return nothing
end
# %%
print_subtypes(Integer)

# %%
function print_supertypes(T)
  println(T)
  T == Any || print_supertypes(supertype(T))
  return nothing
end

print_supertypes(Int64)

# %%
print_supertypes(typeof([1.0, 2.0, 3.0]))
# %%
