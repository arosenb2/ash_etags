defmodule Etags.Example.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Etags.Example.Foo
  end
end
