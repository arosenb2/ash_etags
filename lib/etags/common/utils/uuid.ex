defmodule Etags.Common.Utils.UUID do
  @base62_alphabet '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  @base62_uuid_length 22
  @separator "_"

  for {digit, idx} <- Enum.with_index(@base62_alphabet) do
    # Wow! Who knew you could call defp in a loop?
    defp base62_encode(unquote(idx)), do: unquote(<<digit>>)
  end

  defp base62_encode(number) do
    base62_encode(div(number, unquote(length(@base62_alphabet)))) <>
      base62_encode(rem(number, unquote(length(@base62_alphabet))))
  end

  def generate(type) do
    id =
      UUIDv7.generate()
      |> String.replace("-", "")
      |> String.to_integer(16)
      |> base62_encode()
      |> String.pad_leading(@base62_uuid_length, "0")

    "#{type}#{@separator}#{id}"
  end
end
