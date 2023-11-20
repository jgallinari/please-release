defmodule PleaseReleaseTest do
  use ExUnit.Case
  doctest PleaseRelease

  test "greets the world" do
    assert PleaseRelease.hello() == :world
  end
end
