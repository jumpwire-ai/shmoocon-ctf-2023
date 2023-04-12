defmodule GreenThumb do
  @issuer "ctf.jumpwire.ai"

  def startup() do
    # Generate the admin's TOTP
    user = "root"
    secret = gen_secret(user)
    NimbleTOTP.otpauth_uri(user, secret, issuer: @issuer)
    :ok
  end

  def valid?(username, code) do
    case GreenThumb.Secrets.fetch(username) do
      {:ok, {_id, secret}} -> NimbleTOTP.valid?(secret, code)
      _ -> false
    end
  end

  @doc """
  Generate and store a secret for the user.
  """
  def gen_secret(username) do
    # size = 24
    secret = GreenThumb.Random.secret()
    GreenThumb.Secrets.put_new(username, secret)
    secret
  end

  def qr_code(username) do
    secret = gen_secret(username)

    # secret in the URL is base32 encoded, no padding
    NimbleTOTP.otpauth_uri(username, secret, issuer: @issuer)
    |> EQRCode.encode()
    |> render()
  end

  @doc """
  Turn a QR code into ASCII.

  Implemented here because EQRCode will only output ASCII directly
  to the terminal, not return the actual binary.
  https://github.com/SiliconJungles/eqrcode/blob/master/lib/eqrcode/render.ex#L19
  """
  def render(%EQRCode.Matrix{matrix: matrix}) do
    Tuple.to_list(matrix)
    |> Stream.map(fn e ->
      Tuple.to_list(e)
      |> Enum.map(&do_render/1)
    end)
    |> Enum.intersperse("\n")
  end

  defp do_render(1), do: "\e[40m  \e[0m"
  defp do_render(0), do: "\e[0;107m  \e[0m"
  defp do_render(nil), do: "\e[0;106m  \e[0m"
  defp do_render(:data), do: "\e[0;102m  \e[0m"
  defp do_render(:reserved), do: "\e[0;104m  \e[0m"
end
