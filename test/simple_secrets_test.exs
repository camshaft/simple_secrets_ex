defmodule SimpleSecretsTest do
  use ExUnit.Case

  @master_key "5db273e71341fa342b45311c25f1b33e249381570c3c6325625f1524aa7d7576"
  @other_master_key "50f0b9bdd331fa0dac3e86148f92da804d9a710f8e19c1e7c8421c71a2dcd7c0"
  @message %{"u" => 123456, "s" => [1,2,3,4]}

  test "recover text" do
    sender = SimpleSecrets.init(@master_key)
    enc = SimpleSecrets.pack!(@message, sender)
    dec = SimpleSecrets.unpack!(enc, sender)

    assert dec == @message
  end

  test "decrypt from nodejs" do
    sender = SimpleSecrets.init(@master_key)
    enc = "bBDTl5NK8dmoh79nbNGph_2PiHWqS7pBiGzuANuYV3TBuh2hEHBNk2MsGzjYZzS2xEufJmgww5p9nXwzyuBPQfQ6mejIcpHwinccraqKMw4155--9FI"
    dec = SimpleSecrets.unpack!(enc, sender)

    assert dec == @message
  end

  test "unrecoverable text" do
    message = "this is a secret message"

    sender = SimpleSecrets.init(@master_key)
    sender2 = SimpleSecrets.init(@other_master_key)

    enc = SimpleSecrets.pack!(message, sender)
    dec = SimpleSecrets.unpack(enc, sender2)

    assert {:error, :key_mismatch} == dec
  end
end
