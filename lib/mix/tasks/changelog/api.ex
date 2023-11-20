defmodule Mix.Tasks.Changelog.Api do
  @moduledoc "The changelog.api mix task"
  use Mix.Task

  @shortdoc "Generates CHANGELOG.API.md"
  @impl Mix.Task
  def run(_args) do
    PleaseRelease.make_changelog_api()
  end
end
