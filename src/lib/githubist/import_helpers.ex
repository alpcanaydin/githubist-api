defmodule Githubist.ImportHelpers do
  @moduledoc """
  JSON import helpers
  """

  @doc """
  Capitalize a word as Turkish sensetive
  """
  @spec capitalize(String.t()) :: String.t()
  def capitalize(word) do
    word
    |> String.replace_prefix("i", "İ")
    |> String.capitalize()
  end

  @doc """
  Create location slug
  """
  @spec create_location_slug(String.t()) :: String.t()
  def create_location_slug(name) do
    name |> capitalize() |> Slug.slugify()
  end

  @doc """
  Create language slug
  """
  @spec create_language_slug(String.t()) :: String.t()
  def create_language_slug(name) do
    name
    |> String.replace("#", "sharp")
    |> String.replace("+", "plus")
    |> Slug.slugify()
  end
end
