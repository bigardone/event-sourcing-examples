#---
# Excerpted from "Real-World Event Sourcing",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/khpes for more book information.
#---
defmodule LunarFrontiersTest do
  use ExUnit.Case
  doctest LunarFrontiers

  test "greets the world" do
    assert LunarFrontiers.hello() == :world
  end
end
