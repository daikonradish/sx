# Sx

Welcome to Sx! 📊📈📉

Sx is a statistical library written entirely in Elixir. 
 
Wherever possible, Sx is:

1. 🥚 Simple to use, with a consistent interface.
    1. _Stat_ contains the functions for dealing with sample statistics of a dataset, like `mean`, `variance`, `histogram`.
    2. _Dist_ contains statistical distributions and the functions for interacting with them, including `pdf` (probability density/mass function), `cdf` (cumulative distribution function), `icdf` (inverse cumulative distribution functon) and `rand_gen` (generating a `Stream` of random variables)
    3. _Test_ contains statistical tests, including parametric and nonparametric tests.
2. ⭐ Purely functional. Wherever possible, the `reduce` and `unfold` combinators are used, revealing the elegant overlap between mathematics and functional programming.
3. 🦦 Efficient. Sx endeavors to perform numerically stable one-pass algorithms over the dataset. If sorting is required, Gelman sorts only once, unless _absolutely_ necessary.
4. 🧪 Extensively tested. Tests are borrowed from `scipy/stats` and `R` base, and so the results are guaranteed to be at least as accurate Python/R implementations. If deterministic tests are not possible, probabilistic tests are run to assure that the statistical properties are upheld.
5. 🧫 Reproducible. Sx wraps Erlang's `rand` library in an opinionated fashion that will help you write reproducible (and hence _debuggable_) simulations.
 6. ⚗️ Pure Elixir. The APIs are designed to work seamlessly with Elixir pipes. Functions are designed to work with any `Enumerable.t(number)`, so these functions will work with `List`s and `Stream`s, without need for explicit conversion to between the two.

This library might be of interest to Elixir programmers who:

1. Need access to battle-tested statistical functions
2. Wish to perform statistical tests without having to set up a own Python/R service
3. Are running statistical simulations
4. Are developing games and require a pure Elixir implementation of random number generators (e.g. getting numbers from an exponential distribution to model time between encountering Pokémon in the wild)



## Installation
(NOT TESTED YET!!!!)
If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sx, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/sx>.
