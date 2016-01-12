defmodule SimpleSecrets.Primatives do
  def nonce() do
    :crypto.strong_rand_bytes(16)
  end

  def derive(master, role) do
    :crypto.hash(:sha256, [master, role])
  end

  def derive_sender_hmac(master) do
    derive(master, "simple-crypto/sender-hmac-key")
  end

  def derive_sender_key(master) do
    derive(master, "simple-crypto/sender-cipher-key")
  end

  def derive_receiver_hmac(master) do
    derive(master, "simple-crypto/receiver-hmac-key")
  end

  def derive_receiver_key(master) do
    derive(master, "simple-crypto/receiver-cipher-key")
  end

  def encrypt(buffer, key) do
    iv = nonce()
    cipher = :crypto.block_encrypt(:aes_cbc256, key, iv, PKCS7.pad(buffer))
    iv <> cipher
  end

  def decrypt(buffer, key, iv) do
    :crypto.block_decrypt(:aes_cbc256, key, iv, buffer)
    |> PKCS7.unpad()
  end

  def identify(buffer) do
    input = [buffer_size(buffer), buffer]
    <<prefix :: binary-size(6), _ :: binary>> = :crypto.hash(:sha256, input)
    prefix
  end

  defp buffer_size(buffer) do
    buffer
    |> byte_size()
    |> :binary.encode_unsigned()
  end

  def mac(buffer, hmac_key) do
    :crypto.hmac(:sha256, hmac_key, buffer)
  end

  for n <- 1..32 do
    def equals?(a, b) when byte_size(a) == unquote(n) and byte_size(b) == unquote(n) do
      :crypto.exor(a, b) == unquote(Stream.repeatedly(fn -> 0 end) |> Enum.take(n) |> :erlang.iolist_to_binary)
    end
  end

  def binify(string) do
    string
    |> pad()
    |> Base.url_decode64!()
  end

  def stringify(buffer) do
    buffer
    |> Base.url_encode64()
    |> unpad()
  end

  def serialize(object) do
    object
    |> Msgpax.pack!()
    |> :erlang.iolist_to_binary()
  end

  def deserialize(binary) do
    Msgpax.unpack!(binary)
  end

  defp pad(buffer) do
    case buffer |> byte_size |> rem(4) do
      0 ->
        buffer
      diff ->
        pad(buffer, 4 - diff)
    end
  end

  for n <- 0..3 do
    def pad(buffer, unquote(n)) do
      buffer <> unquote(Stream.repeatedly(fn -> "=" end) |> Enum.take(n) |> Enum.join())
    end
  end

  defp unpad(string) do
    string
    |> String.replace("=", "")
  end
end
