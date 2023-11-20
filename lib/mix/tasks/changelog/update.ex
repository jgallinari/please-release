defmodule Mix.Tasks.Changelog.Update do
  @moduledoc "The changelog.update mix task"
  use Mix.Task

  @shortdoc "Updates links in CHANGELOG.md"
  @impl Mix.Task
  def run(_args) do
    PleaseRelease.update_links()
  end
end
