defmodule TupleDataTest do
  use ExUnit.Case
  alias Subscribers.Postgres.TupleData
  alias Subscribers.Postgres.Column

  doctest TupleData

  test "get_tuple_data" do
    message =
      <<6::16, "n", "b", 5::32, "Filip", "u", "b", 1::32, "D", "t", 5::32, "Juraj", "n", 55::32,
        1::16, "n">>

    assert {:ok, tuple_data, rest} = TupleData.get_tuple_data(message)

    assert tuple_data == %TupleData{
             num_of_cols: 6,
             columns: [
               %Column{kind: ?n, value: nil},
               %Column{kind: ?b, value: "Filip"},
               %Column{kind: ?u, value: nil},
               %Column{kind: ?b, value: "D"},
               %Column{kind: ?t, value: "Juraj"},
               %Column{kind: ?n, value: nil}
             ]
           }

    assert rest == <<55::32, 1::16, "n">>
  end

  test "get_tuple_data_empty" do
    message = <<0::16, "Juraj", "n", 55::32, 1::16, "n">>
    assert {:ok, tuple_data, rest} = TupleData.get_tuple_data(message)
    assert tuple_data == %TupleData{num_of_cols: 0, columns: []}
    assert rest == <<"Juraj", "n", 55::32, 1::16, "n">>
  end

  test "get_tuple_data_invalid_col_type" do
    message = <<1::16, "x">>
    assert {:error, result} = TupleData.get_tuple_data(message)
    assert result == {:unsupported_column_type, ?x}
  end

  test "get_tuple_data_invalid_col_len" do
    message = <<1::16, "t", 5::16>>
    assert {:error, result} = TupleData.get_tuple_data(message)
    assert result == {:invalid_column_length_prefix, <<0, 5>>}
  end

  test "get_tuple_data_invalid_col_val" do
    message = <<1::16, "t", 5::32, "Fili">>
    assert {:error, result} = TupleData.get_tuple_data(message)
    assert result == {:incomplete_column_value, 5, <<"Fili">>}

    message = <<1::16, "t", 5::16, "Filip">>
    assert {:error, result} = TupleData.get_tuple_data(message)
    assert result == {:incomplete_column_value, 345_705, <<"lip">>}
  end

  test "get_tuple_data_invalid_length" do
    message = <<1::8>>
    assert {:error, result} = TupleData.get_tuple_data(message)
    assert result == {:invalid_data_length, message}
  end

  test "get_tuple_data_invalid_length_kind" do
    message = <<1::16>>
    assert {:error, result} = TupleData.get_tuple_data(message)
    assert result == {:invalid_kind_length, <<>>}
  end
end
