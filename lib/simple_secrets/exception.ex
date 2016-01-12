defmodule SimpleSecrets.Exception do
  defexception [:code]

  def message(%{code: code}) do
    code |> to_string
  end
end
