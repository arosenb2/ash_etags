# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Etags.Example.Foo.create!(%{title: "Example"})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
1..10
|> Enum.map(fn num -> Etags.Example.Foo.create(%{title: "Example - #{num}"}) end)
