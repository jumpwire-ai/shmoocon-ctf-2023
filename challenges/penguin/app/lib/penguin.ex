defmodule Penguin do
  @block_size 16

  def encrypt(localized) do
    flag = Application.fetch_env!(:penguin, :flag)
    key = Application.fetch_env!(:penguin, :key)

    data = "Here is the #{localized}: #{flag}"

    text_size = byte_size(data)
    pad_size =
      case rem(text_size, @block_size) do
        0 -> @block_size
        n -> @block_size - n
      end

    padding = String.duplicate(<<pad_size>>, pad_size)
    plaintext = data <> padding

    :crypto.crypto_one_time(:aes_128_ecb, key, plaintext, encrypt: true)
    |> Base.encode16(case: :lower)
  end
end
