/- This example shows why the type universe of `Functor` is `max (u+1) v`. -/

class Functor' (f : Type u → Type v) : Type (max (u+1) v) where
  /-- If `f : α → β` and `x : F α` then `f <$> x : F β`. -/
  map : {α β : Type u} → (α → β) → f α → f β

/- Recall that a type class is analogous to a `strcuture`, so the structure only
has to reside in a universe that contains all of its members. In this case the
member is `Functor'.map` -/

section

universe u v
variable (α : Type u) (β : Type u)
variable (f : Type u -> Type v)
#check α → β
#check f α → f β
#check (α → β) → f α → f β
-- Type of `map` with explicit currying
#check {α β : Type u} → ((α → β) → (f α → f β))

end
