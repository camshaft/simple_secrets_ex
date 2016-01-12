defmodule SimpleSecrets do
  @key_hex_size 512
  @key_size 256

  alias SimpleSecrets.Primatives
  alias SimpleSecrets.Sender

  def init(key) when bit_size(key) == @key_hex_size do
    key
    |> String.upcase()
    |> Base.decode16!()
    |> init()
  end
  def init(key) when bit_size(key) == @key_size do
    %Sender{master: key,
            key_id: Primatives.identify(key)}
  end

  def pack(data, sender) do
    {:ok, pack!(data, sender)}
  rescue
    e in SimpleSecrets.Exception ->
      {:error, e.code}
  end

  def pack!(data, %Sender{master: master, key_id: key_id}) do
    data
    |> build_body()
    |> encrypt_body(master)
    |> authenticate(master, key_id)
    |> Primatives.stringify()
  end

  def unpack(websafe, sender) do
    {:ok, unpack!(websafe, sender)}
  rescue
    e in SimpleSecrets.Exception ->
      {:error, e.code}
  end

  def unpack!(websafe, %Sender{master: master, key_id: key_id}) do
    websafe
    |> Primatives.binify()
    |> verify(master, key_id)
    |> decrypt_body(master)
    |> body_to_data()
  end

  defp build_body(data) do
    nonce = Primatives.nonce()
    bindata = Primatives.serialize(data)
    nonce <> bindata
  end

  defp body_to_data(data) do
    <<_ :: binary-size(16), bindata :: binary>> = data
    Primatives.deserialize(bindata)
  end

  defp encrypt_body(body, master) do
    key = Primatives.derive_sender_key(master)
    Primatives.encrypt(body, key)
  end

  defp decrypt_body(cipher_data, master) do
    key = Primatives.derive_sender_key(master)
    <<iv :: binary-size(16), encrypted :: binary>> = cipher_data
    Primatives.decrypt(encrypted, key, iv)
  end

  defp authenticate(data, master, key_id) do
    hmac_key = Primatives.derive_sender_hmac(master)
    auth = key_id <> data
    mac = Primatives.mac(auth, hmac_key)
    auth <> mac
  end

  defp verify(packet, master, key_id) do
    <<packet_key_id :: binary-size(6), _ :: binary>> = packet

    if !Primatives.equals?(packet_key_id, key_id) do
      raise SimpleSecrets.Exception, code: :key_mismatch
    end

    packet_size = byte_size(packet)
    data = :binary.part(packet, {0, packet_size - 32})
    packet_hmac = :binary.part(packet, {packet_size, -32})
    hmac_key = Primatives.derive_sender_hmac(master)
    mac = Primatives.mac(data, hmac_key)

    if !Primatives.equals?(packet_hmac, mac) do
      raise SimpleSecrets.Exception, code: :mac_mismatch
    end

    <<_ :: binary-size(6), body :: binary>> = data
    body
  end
end
