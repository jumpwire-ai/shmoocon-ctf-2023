# Define a module to be used as base
defmodule Reflection.Schema do
  # from https://stackoverflow.com/questions/58206597/how-to-set-datetime-in-ecto-schemas-and-timestamp-with-time-zone-timestamp
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      # In case one uses UUIDs
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      # ------------------------------------
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
