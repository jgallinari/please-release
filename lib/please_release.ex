defmodule PleaseRelease do
  @moduledoc false

  alias Earmark.{Parser, Restructure}

  @changelog "CHANGELOG.md"
  @changelog_api "CHANGELOG.API.md"
  @fibery_feature_url "https://airnity.fibery.io/Work/Feature"
  @fibery_bug_url "https://airnity.fibery.io/Work/Bug"

  @doc """
  Hello world.

  ## Examples

      iex> PleaseRelease.hello()
      :world_war_3

  """
  def hello do
    :world_war_3
  end

  def make_changelog_api do
    {:ok, md} = File.read(@changelog)
    {:ok, ast, []} = Parser.as_ast(md)

    {modified_ast, _} = Restructure.walk_and_modify_ast(ast, nil, &process_changelog_api_item/2)

    modified_md =
      modified_ast
      |> Enum.reverse()
      |> Enum.dedup_by(&dedup_h2/1)
      |> maybe_pop_h2()
      |> Enum.reverse()
      |> EarmarkReversal.markdown_from_ast()

    File.write(@changelog_api, modified_md)
  end

  defp process_changelog_api_item({"h1", _, ["Changelog"], _} = item, _acc) do
    {item, :keep}
  end

  defp process_changelog_api_item({"h2", _, _, _} = item, _acc) do
    {item, :keep}
  end

  # Keep the same emoji as used in the Release Please GitHub action
  defp process_changelog_api_item({"h3", _, ["📚 Documentation"], _} = _item, _acc) do
    {[], :keep}
  end

  defp process_changelog_api_item({"h3", _, _, _} = _item, _acc) do
    {[], :reject}
  end

  @date_regex ~r/.* (\(\d{4}-\d{2}-\d{2}\))/
  @opening_parens_regex ~r/(.*)\($/
  defp process_changelog_api_item(item, :keep) when is_binary(item) do
    new_item =
      cond do
        # Remove space before date
        item =~ @date_regex -> String.replace(item, @date_regex, "\\1")
        # Remove parentheses englobing a link
        # ") ("
        item =~ ~r/^\s*\)\s*\($/ -> ""
        item == ")" -> ""
        # "doc 1 ("
        item =~ @opening_parens_regex -> String.replace(item, @opening_parens_regex, "\\1")
        true -> item
      end

    {new_item, :keep}
  end

  # We don't want links in CHANGELOG.API.md
  defp process_changelog_api_item({"a", _, _, _} = _item, :keep) do
    {"", :keep}
  end

  defp process_changelog_api_item(item, :keep) do
    {item, :keep}
  end

  defp process_changelog_api_item(_item, :reject) do
    {[], :reject}
  end

  defp process_changelog_api_item(item, acc) do
    {item, acc}
  end

  def update_links do
    {:ok, md} = File.read(@changelog)
    {:ok, ast, []} = Parser.as_ast(md)

    {modified_ast, _} = Restructure.walk_and_modify_ast(ast, nil, &process_links_item/2)
    modified_md = EarmarkReversal.markdown_from_ast(modified_ast)

    File.write(@changelog, modified_md)
  end

  @bid_regex ~r/(.*)\(bid$/
  @fid_regex ~r/(.*)\(fid$/
  @pr_regex ~r/(.*)\(pr$/
  # bid, fid and pr are not part of the link in bid#1, fid#1 or pr#1
  # so remove them here and make them part of the link later
  defp process_links_item(item, acc) when is_binary(item) do
    cond do
      item =~ @bid_regex -> {String.replace(item, @bid_regex, "\\1("), :bid}
      item =~ @fid_regex -> {String.replace(item, @fid_regex, "\\1("), :fid}
      item =~ @pr_regex -> {String.replace(item, @pr_regex, "\\1("), :pr}
      true -> {item, acc}
    end
  end

  @generated_url_regex ~r/.*?(\d+)$/
  defp process_links_item({"a", [{"href", url}], [text], annotations}, :fid)
       when is_binary(url) do
    new_url = String.replace(url, @generated_url_regex, "#{@fibery_feature_url}/\\1")
    new_item = {"a", [{"href", new_url}], ["fid#{text}"], annotations}

    {new_item, nil}
  end

  defp process_links_item({"a", [{"href", url}], [text], annotations}, :bid)
       when is_binary(url) do
    new_url = String.replace(url, @generated_url_regex, "#{@fibery_bug_url}/\\1")
    new_item = {"a", [{"href", new_url}], ["bid#{text}"], annotations}

    {new_item, nil}
  end

  defp process_links_item({"a", [{"href", url}], [text], annotations}, :pr) when is_binary(url) do
    new_item = {"a", [{"href", url}], ["pr#{text}"], annotations}

    {new_item, nil}
  end

  defp process_links_item(item, acc) do
    # IO.inspect("item = #{inspect(item)}")
    {item, acc}
  end

  defp dedup_h2({"h2" = type, _, _, _}), do: type
  defp dedup_h2(item), do: item

  defp maybe_pop_h2([{"h2", _, _, _} | tail] = _items), do: tail
  defp maybe_pop_h2(items), do: items
end
