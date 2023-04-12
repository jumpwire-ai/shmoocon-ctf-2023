defmodule ReflectionWeb.ApiController do
  use ReflectionWeb, :controller

  @ascii_flag ~S"""
     _    _.--.____.--._
  ( )=.-":;:;:;;':;:;:;"-._
   \\\:;:;:;:;:;;:;::;:;:;:\
    \\\:;:;:;:;:;;:;:;:;:;:;\
     \\\:;::;:;:;:;:;::;:;:;:\
      \\\:;:;:;:;:;;:;::;:;:;:\
       \\\:;::;:;:;:;:;::;:;:;:\
        \\\;;:;:_:--:_:_:--:_;:;\
         \\\_.-"             "-._\
          \\
           \\
            \\
             \\
              \\
               \\
  """

  def index(conn, _) do
    data =
      case conn.assigns.user do
        %{is_admin: true} ->
          flag = Application.get_env(:reflection, :flag)
          %{flag: flag}

        _ ->
          %{flag: @ascii_flag}
      end

    json(conn, data)
  end
end
