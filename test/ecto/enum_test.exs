defmodule Ecto.EnumTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias Ecto.TestRepo

  defmodule EnumSchema do
    use Ecto.Schema

    schema "my_schema" do
      field :my_enum, Ecto.Enum, values: [:foo, :bar, :baz]
      field :my_enums, {:array, Ecto.Enum}, values: [:foo, :bar, :baz]
      field :my_integer_enum, Ecto.Enum, values: [foo: 1, bar: 2, baz: 5]
      field :my_integer_enums, {:array, Ecto.Enum}, values: [foo: 1, bar: 2, baz: 5]
      field :my_string_enum, Ecto.Enum, values: [foo: "fooo", bar: "baar", baz: "baaz"]
      field :my_string_enums, {:array, Ecto.Enum}, values: [foo: "fooo", bar: "baar", baz: "baaz"]
      field :virtual_enum, Ecto.Enum, values: [:foo, :bar, :baz], virtual: true
      field :not_enum, :string

      embeds_one :embed, Embed do
        field :dumped_enum, Ecto.Enum, values: [foo: 1, bar: 2], embed_as: :dumped
        field :non_dumped_enum, Ecto.Enum, values: [foo: 1, bar: 2], embed_as: :values
      end
    end
  end

  @schemaless_types %{
    my_enum: Ecto.ParameterizedType.init(Ecto.Enum, values: [:foo, :bar, :baz]),
    my_enums: {:array, Ecto.ParameterizedType.init(Ecto.Enum, values: [:foo, :bar, :baz])},
    my_integer_enum: Ecto.ParameterizedType.init(Ecto.Enum, values: [foo: 1, bar: 2, baz: 5]),
    my_integer_enums:
      {:array, Ecto.ParameterizedType.init(Ecto.Enum, values: [foo: 1, bar: 2, baz: 5])},
    my_string_enum:
      Ecto.ParameterizedType.init(Ecto.Enum, values: [foo: "fooo", bar: "baar", baz: "baaz"]),
    my_string_enums:
      {:array,
       Ecto.ParameterizedType.init(Ecto.Enum, values: [foo: "fooo", bar: "baar", baz: "baaz"])}
  }

  describe "Ecto.Enum" do
    test "schema" do
      assert EnumSchema.__schema__(:type, :my_enum) ==
               {:parameterized,
                {Ecto.Enum,
                 %{
                   on_dump: %{bar: "bar", baz: "baz", foo: "foo"},
                   on_load: %{"bar" => :bar, "baz" => :baz, "foo" => :foo},
                   on_cast: %{"bar" => :bar, "baz" => :baz, "foo" => :foo},
                   mappings: [foo: "foo", bar: "bar", baz: "baz"],
                   type: :string,
                   embed_as: :self
                 }}}

      assert EnumSchema.__schema__(:type, :my_enums) ==
               {
                 :array,
                 {:parameterized,
                  {Ecto.Enum,
                   %{
                     on_dump: %{bar: "bar", baz: "baz", foo: "foo"},
                     on_load: %{"bar" => :bar, "baz" => :baz, "foo" => :foo},
                     on_cast: %{"bar" => :bar, "baz" => :baz, "foo" => :foo},
                     mappings: [foo: "foo", bar: "bar", baz: "baz"],
                     type: :string,
                     embed_as: :self
                   }}}
               }

      assert EnumSchema.__schema__(:type, :my_integer_enum) ==
               {:parameterized,
                {Ecto.Enum,
                 %{
                   on_dump: %{bar: 2, baz: 5, foo: 1},
                   on_load: %{2 => :bar, 5 => :baz, 1 => :foo},
                   on_cast: %{"bar" => :bar, "baz" => :baz, "foo" => :foo},
                   mappings: [foo: 1, bar: 2, baz: 5],
                   type: :integer,
                   embed_as: :self
                 }}}

      assert EnumSchema.__schema__(:type, :my_integer_enums) ==
               {
                 :array,
                 {:parameterized,
                  {Ecto.Enum,
                   %{
                     on_dump: %{bar: 2, baz: 5, foo: 1},
                     on_load: %{2 => :bar, 5 => :baz, 1 => :foo},
                     on_cast: %{"bar" => :bar, "baz" => :baz, "foo" => :foo},
                     mappings: [foo: 1, bar: 2, baz: 5],
                     type: :integer,
                     embed_as: :self
                   }}}
               }

      assert EnumSchema.__schema__(:type, :my_string_enum) ==
               {:parameterized,
                {Ecto.Enum,
                 %{
                   on_dump: %{bar: "baar", baz: "baaz", foo: "fooo"},
                   on_load: %{"baar" => :bar, "baaz" => :baz, "fooo" => :foo},
                   on_cast: %{"bar" => :bar, "baz" => :baz, "foo" => :foo},
                   mappings: [foo: "fooo", bar: "baar", baz: "baaz"],
                   type: :string,
                   embed_as: :self
                 }}}

      assert EnumSchema.__schema__(:type, :my_string_enums) ==
               {
                 :array,
                 {:parameterized,
                  {Ecto.Enum,
                   %{
                     on_dump: %{bar: "baar", baz: "baaz", foo: "fooo"},
                     on_load: %{"baar" => :bar, "baaz" => :baz, "fooo" => :foo},
                     on_cast: %{"bar" => :bar, "baz" => :baz, "foo" => :foo},
                     mappings: [foo: "fooo", bar: "baar", baz: "baaz"],
                     type: :string,
                     embed_as: :self
                   }}}
               }

      assert EnumSchema.Embed.__schema__(:type, :non_dumped_enum) ==
               {:parameterized,
                {Ecto.Enum,
                 %{
                   on_dump: %{foo: 1, bar: 2},
                   on_load: %{1 => :foo, 2 => :bar},
                   on_cast: %{"foo" => :foo, "bar" => :bar},
                   mappings: [foo: 1, bar: 2],
                   type: :integer,
                   embed_as: :self
                 }}}

      assert EnumSchema.Embed.__schema__(:type, :dumped_enum) ==
               {:parameterized,
                {Ecto.Enum,
                 %{
                   on_dump: %{foo: 1, bar: 2},
                   on_load: %{1 => :foo, 2 => :bar},
                   on_cast: %{"foo" => :foo, "bar" => :bar},
                   mappings: [foo: 1, bar: 2],
                   type: :integer,
                   embed_as: :dump
                 }}}
    end

    test "type" do
      assert Ecto.Type.type(EnumSchema.__schema__(:type, :my_enum)) == :string
      assert Ecto.Type.type(EnumSchema.__schema__(:type, :my_enums)) == {:array, :string}
      assert Ecto.Type.type(EnumSchema.__schema__(:type, :my_integer_enum)) == :integer
      assert Ecto.Type.type(EnumSchema.__schema__(:type, :my_integer_enums)) == {:array, :integer}
      assert Ecto.Type.type(EnumSchema.__schema__(:type, :my_string_enum)) == :string
      assert Ecto.Type.type(EnumSchema.__schema__(:type, :my_string_enums)) == {:array, :string}
    end

    test "bad values" do
      message = ~r"Ecto.Enum types must have a values option specified as a list of atoms"

      assert_raise ArgumentError, message, fn ->
        defmodule SchemaInvalidEnumValues do
          use Ecto.Schema

          schema "invalidvalues" do
            field :name, Ecto.Enum
          end
        end
      end

      assert_raise ArgumentError, message, fn ->
        defmodule SchemaInvalidEnumValues do
          use Ecto.Schema

          schema "invalidvalues" do
            field :name, Ecto.Enum, values: ["foo", "bar"]
          end
        end
      end

      assert_raise ArgumentError, message, fn ->
        defmodule SchemaInvalidEnumValues do
          use Ecto.Schema

          schema "invalidvalues" do
            field :name, Ecto.Enum, values: [a: 1, b: "2"]
          end
        end
      end
    end

    test "repeated values" do
      message = ~r"Ecto.Enum type values must be unique"

      assert_raise ArgumentError, message, fn ->
        defmodule SchemaDuplicateEnumValues do
          use Ecto.Schema

          schema "duplicate_values" do
            field :name, Ecto.Enum, values: [:foo, :foo]
          end
        end
      end

      assert_raise ArgumentError, message, fn ->
        defmodule SchemaDuplicateEnumKeys do
          use Ecto.Schema

          schema "duplicate_values" do
            field :name, Ecto.Enum, values: [foo: 1, foo: 2]
          end
        end
      end

      assert_raise ArgumentError, message, fn ->
        defmodule SchemaDuplicateEnumMappings do
          use Ecto.Schema

          schema "duplicate_values" do
            field :name, Ecto.Enum, values: [foo: 1, bar: 1]
          end
        end
      end
    end

    test "invalid `:embed_as` option" do
      message = """
      the `:embed_as` option for `Ecto.Enum` accepts either `:values` or `:dumped`,
      received: `:invalid`
      """

      assert_raise ArgumentError, message, fn ->
        defmodule SchemaDuplicateEnumMappings do
          use Ecto.Schema

          schema "duplicate_values" do
            embeds_one :embed, Embed do
              field :name, Ecto.Enum, values: [:foo, :bar], embed_as: :invalid
            end
          end
        end
      end
    end
  end

  describe "cast" do
    test "casts null" do
      assert %Changeset{valid?: true} = Changeset.cast(%EnumSchema{}, %{my_enum: nil}, [:my_enum])
    end

    test "casts strings" do
      assert %Changeset{valid?: true, changes: %{my_enum: :foo}} =
               Changeset.cast(%EnumSchema{}, %{my_enum: "foo"}, [:my_enum])

      assert %Changeset{valid?: true, changes: %{my_enums: [:foo]}} =
               Changeset.cast(%EnumSchema{}, %{my_enums: ["foo"]}, [:my_enums])

      assert %Changeset{valid?: true, changes: %{my_string_enum: :foo}} =
               Changeset.cast(%EnumSchema{}, %{my_string_enum: "fooo"}, [:my_string_enum])

      assert %Changeset{valid?: true, changes: %{my_string_enums: [:foo]}} =
               Changeset.cast(%EnumSchema{}, %{my_string_enums: ["fooo"]}, [:my_string_enums])
    end

    test "casts integers" do
      assert %Changeset{valid?: true, changes: %{my_integer_enum: :foo}} =
               Changeset.cast(%EnumSchema{}, %{my_integer_enum: 1}, [:my_integer_enum])

      assert %Changeset{valid?: true, changes: %{my_integer_enums: [:foo]}} =
               Changeset.cast(%EnumSchema{}, %{my_integer_enums: [1]}, [:my_integer_enums])
    end

    test "casts atoms" do
      assert %Changeset{valid?: true, changes: %{my_enum: :bar}} =
               Changeset.cast(%EnumSchema{}, %{my_enum: :bar}, [:my_enum])

      assert %Changeset{valid?: true, changes: %{my_enums: [:bar]}} =
               Changeset.cast(%EnumSchema{}, %{my_enums: [:bar]}, [:my_enums])
    end

    test "cast string representation of atoms" do
      assert %Changeset{valid?: true, changes: %{my_string_enum: :foo}} =
               Changeset.cast(%EnumSchema{}, %{my_string_enum: "foo"}, [:my_string_enum])

      assert %Changeset{valid?: true, changes: %{my_string_enums: [:foo]}} =
               Changeset.cast(%EnumSchema{}, %{my_string_enums: ["foo"]}, [:my_string_enums])

      assert %Changeset{valid?: true, changes: %{my_integer_enum: :foo}} =
               Changeset.cast(%EnumSchema{}, %{my_integer_enum: "foo"}, [:my_integer_enum])

      assert %Changeset{valid?: true, changes: %{my_integer_enums: [:foo]}} =
               Changeset.cast(%EnumSchema{}, %{my_integer_enums: ["foo"]}, [:my_integer_enums])
    end

    test "rejects bad strings" do
      type = EnumSchema.__schema__(:type, :my_enum)

      {:parameterized, {Ecto.Enum, %{on_cast: on_cast}}} = type
      enum = Map.keys(on_cast)

      assert %Changeset{
               valid?: false,
               changes: %{},
               errors: [my_enum: {"is invalid", [type: ^type, validation: :inclusion, enum: ^enum]}]
             } = Changeset.cast(%EnumSchema{}, %{my_enum: "bar2"}, [:my_enum])

      type = EnumSchema.__schema__(:type, :my_enums)

      {:array, {:parameterized, {Ecto.Enum, %{on_cast: on_cast}}}} = type
      enum = Map.keys(on_cast)

      assert %Changeset{
               valid?: false,
               changes: %{},
               errors: [my_enums: {"is invalid", [type: ^type, validation: :inclusion, enum: ^enum, source: [0]]}]
             } = Changeset.cast(%EnumSchema{}, %{my_enums: ["bar2"]}, [:my_enums])

      type = EnumSchema.__schema__(:type, :my_string_enum)

      {:parameterized, {Ecto.Enum, %{on_cast: on_cast}}} = type
      enum = Map.keys(on_cast)

      assert %Changeset{
               valid?: false,
               changes: %{},
               errors: [my_string_enum: {"is invalid", [type: ^type, validation: :inclusion, enum: ^enum]}]
             } = Changeset.cast(%EnumSchema{}, %{my_string_enum: "baar2"}, [:my_string_enum])

      type = EnumSchema.__schema__(:type, :my_string_enums)

      {:array, {:parameterized, {Ecto.Enum, %{on_cast: on_cast}}}} = type
      enum = Map.keys(on_cast)

      assert %Changeset{
               valid?: false,
               changes: %{},
               errors: [my_string_enums: {"is invalid", [type: ^type, validation: :inclusion, enum: ^enum, source: [0]]}]
             } = Changeset.cast(%EnumSchema{}, %{my_string_enums: ["baar2"]}, [:my_string_enums])
    end

    test "rejects bad integers" do
      type = EnumSchema.__schema__(:type, :my_integer_enum)

      {:parameterized, {Ecto.Enum, %{on_cast: on_cast}}} = type
      enum = Map.keys(on_cast)

      assert %Changeset{
               valid?: false,
               changes: %{},
               errors: [my_integer_enum: {"is invalid", [type: ^type, validation: :inclusion, enum: ^enum]}]
             } = Changeset.cast(%EnumSchema{}, %{my_integer_enum: 7}, [:my_integer_enum])

      type = EnumSchema.__schema__(:type, :my_integer_enums)

      {:array, {:parameterized, {Ecto.Enum, %{on_cast: on_cast}}}} = type
      enum = Map.keys(on_cast)

      assert %Changeset{
               valid?: false,
               changes: %{},
               errors: [my_integer_enums: {"is invalid", [type: ^type, validation: :inclusion, enum: ^enum, source: [0]]}]
             } = Changeset.cast(%EnumSchema{}, %{my_integer_enums: [7]}, [:my_integer_enums])
    end

    test "rejects bad atoms" do
      type = EnumSchema.__schema__(:type, :my_enum)

      {:parameterized, {Ecto.Enum, %{on_cast: on_cast}}} = type
      enum = Map.keys(on_cast)

      assert %Changeset{
               valid?: false,
               changes: %{},
               errors: [my_enum: {"is invalid", [type: ^type, validation: :inclusion, enum: ^enum]}]
             } = Changeset.cast(%EnumSchema{}, %{my_enum: :bar2}, [:my_enum])

      type = EnumSchema.__schema__(:type, :my_enums)

      assert %Changeset{
               valid?: false,
               changes: %{},
               errors: [my_enums: {"is invalid", [type: ^type, validation: :cast]}]
             } = Changeset.cast(%EnumSchema{}, %{my_enums: :bar2}, [:my_enums])
    end
  end

  describe "dump" do
    test "accepts valid values" do
      assert %EnumSchema{my_enum: :foo} = TestRepo.insert!(%EnumSchema{my_enum: :foo})
      assert_receive {:insert, %{fields: [my_enum: "foo"]}}

      assert %EnumSchema{my_enums: [:foo]} = TestRepo.insert!(%EnumSchema{my_enums: [:foo]})
      assert_receive {:insert, %{fields: [my_enums: ["foo"]]}}

      assert %EnumSchema{my_string_enum: :foo} =
               TestRepo.insert!(%EnumSchema{my_string_enum: :foo})

      assert_receive {:insert, %{fields: [my_string_enum: "fooo"]}}

      assert %EnumSchema{my_string_enums: [:foo]} =
               TestRepo.insert!(%EnumSchema{my_string_enums: [:foo]})

      assert_receive {:insert, %{fields: [my_string_enums: ["fooo"]]}}

      assert %EnumSchema{my_integer_enum: :foo} =
               TestRepo.insert!(%EnumSchema{my_integer_enum: :foo})

      assert_receive {:insert, %{fields: [my_integer_enum: 1]}}

      assert %EnumSchema{my_integer_enums: [:foo]} =
               TestRepo.insert!(%EnumSchema{my_integer_enums: [:foo]})

      assert_receive {:insert, %{fields: [my_integer_enums: [1]]}}

      assert %EnumSchema{embed: %{dumped_enum: :foo}} =
               TestRepo.insert!(%EnumSchema{embed: %EnumSchema.Embed{dumped_enum: :foo}})

      assert_receive {:insert, %{fields: [embed: %{dumped_enum: 1}]}}

      assert %EnumSchema{embed: %{non_dumped_enum: :foo}} =
               TestRepo.insert!(%EnumSchema{embed: %EnumSchema.Embed{non_dumped_enum: :foo}})

      assert_receive {:insert, %{fields: [embed: %{non_dumped_enum: :foo}]}}
    end

    test "rejects invalid atom" do
      msg =
        ~r"value `:foo2` for `Ecto.EnumTest.EnumSchema.my_enum` in `insert` does not match type #Ecto\.Enum<values: \[:foo, :bar, :baz\]>"

      assert_raise Ecto.ChangeError, msg, fn ->
        TestRepo.insert!(%EnumSchema{my_enum: :foo2})
      end

      refute_received _
    end

    test "rejects invalid value" do
      msg =
        ~r"value `\[:a, :b, :c\]` for `Ecto.EnumTest.EnumSchema.my_enum` in `insert` does not match type #Ecto\.Enum<values: \[:foo, :bar, :baz\]>"

      assert_raise Ecto.ChangeError, msg, fn ->
        TestRepo.insert!(%EnumSchema{my_enum: [:a, :b, :c]})
      end

      refute_received _
    end

    test "rejects invalid mapped string value" do
      msg =
        ~r"value `\[:a, :b, :c\]` for `Ecto.EnumTest.EnumSchema.my_string_enum` in `insert` does not match type #Ecto\.Enum<values: \[:foo, :bar, :baz\]>"

      assert_raise Ecto.ChangeError, msg, fn ->
        TestRepo.insert!(%EnumSchema{my_string_enum: [:a, :b, :c]})
      end

      refute_received _
    end

    test "rejects invalid integer value" do
      msg =
        ~r"value `\[1, 2, 3\]` for `Ecto.EnumTest.EnumSchema.my_integer_enum` in `insert` does not match type #Ecto\.Enum<values: \[:foo, :bar, :baz\]>"

      assert_raise Ecto.ChangeError, msg, fn ->
        TestRepo.insert!(%EnumSchema{my_integer_enum: [1, 2, 3]})
      end

      refute_received _
    end
  end

  describe "load" do
    test "loads valid values" do
      Process.put(:test_repo_all_results, {1, [[1, "foo", nil, nil, nil, nil, nil, nil, %{}]]})
      assert [%Ecto.EnumTest.EnumSchema{my_enum: :foo}] = TestRepo.all(EnumSchema)

      Process.put(:test_repo_all_results, {1, [[1, nil, ["foo"], nil, nil, nil, nil, nil, %{}]]})
      assert [%Ecto.EnumTest.EnumSchema{my_enums: [:foo]}] = TestRepo.all(EnumSchema)

      Process.put(:test_repo_all_results, {1, [[1, nil, nil, 1, nil, nil, nil, nil, %{}]]})
      assert [%Ecto.EnumTest.EnumSchema{my_integer_enum: :foo}] = TestRepo.all(EnumSchema)

      Process.put(:test_repo_all_results, {1, [[1, nil, nil, nil, [1], nil, nil, nil, %{}]]})
      assert [%Ecto.EnumTest.EnumSchema{my_integer_enums: [:foo]}] = TestRepo.all(EnumSchema)

      Process.put(:test_repo_all_results, {1, [[1, nil, nil, nil, nil, "fooo", nil, nil, %{}]]})
      assert [%Ecto.EnumTest.EnumSchema{my_string_enum: :foo}] = TestRepo.all(EnumSchema)

      Process.put(
        :test_repo_all_results,
        {1, [[1, nil, nil, nil, nil, nil, ["fooo"], nil, nil, %{}]]}
      )

      assert [%Ecto.EnumTest.EnumSchema{my_string_enums: [:foo]}] = TestRepo.all(EnumSchema)

      Process.put(
        :test_repo_all_results,
        {1, [[1, nil, nil, nil, nil, nil, nil, nil, %{"dumped_enum" => 1}]]}
      )

      assert [%Ecto.EnumTest.EnumSchema{embed: %{dumped_enum: :foo}}] = TestRepo.all(EnumSchema)

      Process.put(
        :test_repo_all_results,
        {1, [[1, nil, nil, nil, nil, nil, nil, nil, %{"non_dumped_enum" => "foo"}]]}
      )

      assert [%Ecto.EnumTest.EnumSchema{embed: %{non_dumped_enum: :foo}}] =
               TestRepo.all(EnumSchema)
    end

    test "reject invalid values" do
      Process.put(:test_repo_all_results, {1, [[1, "foo2", nil]]})

      assert_raise ArgumentError,
                   ~r/cannot load `\"foo2\"` as type #Ecto\.Enum<values: \[:foo, :bar, :baz\]>/,
                   fn ->
                     TestRepo.all(EnumSchema)
                   end
    end
  end

  describe "values/2" do
    test "returns correct values" do
      assert Ecto.Enum.values(EnumSchema, :my_enum) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(EnumSchema, :my_enums) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(EnumSchema, :my_string_enum) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(EnumSchema, :my_string_enums) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(EnumSchema, :my_integer_enum) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(EnumSchema, :my_integer_enums) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(EnumSchema, :virtual_enum) == [:foo, :bar, :baz]

      assert Ecto.Enum.values(@schemaless_types, :my_enum) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(@schemaless_types, :my_enums) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(@schemaless_types, :my_integer_enum) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(@schemaless_types, :my_integer_enums) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(@schemaless_types, :my_string_enum) == [:foo, :bar, :baz]
      assert Ecto.Enum.values(@schemaless_types, :my_string_enums) == [:foo, :bar, :baz]
    end
  end

  describe "dump_values/2" do
    test "returns correct values" do
      assert Ecto.Enum.dump_values(EnumSchema, :my_enum) == ["foo", "bar", "baz"]
      assert Ecto.Enum.dump_values(EnumSchema, :my_enums) == ["foo", "bar", "baz"]
      assert Ecto.Enum.dump_values(EnumSchema, :my_string_enum) == ["fooo", "baar", "baaz"]
      assert Ecto.Enum.dump_values(EnumSchema, :my_string_enums) == ["fooo", "baar", "baaz"]
      assert Ecto.Enum.dump_values(EnumSchema, :my_integer_enum) == [1, 2, 5]
      assert Ecto.Enum.dump_values(EnumSchema, :my_integer_enums) == [1, 2, 5]
      assert Ecto.Enum.dump_values(EnumSchema, :virtual_enum) == ["foo", "bar", "baz"]

      assert Ecto.Enum.dump_values(@schemaless_types, :my_enum) == ["foo", "bar", "baz"]
      assert Ecto.Enum.dump_values(@schemaless_types, :my_enums) == ["foo", "bar", "baz"]
      assert Ecto.Enum.dump_values(@schemaless_types, :my_string_enum) == ["fooo", "baar", "baaz"]

      assert Ecto.Enum.dump_values(@schemaless_types, :my_string_enums) == [
               "fooo",
               "baar",
               "baaz"
             ]

      assert Ecto.Enum.dump_values(@schemaless_types, :my_integer_enum) == [1, 2, 5]
      assert Ecto.Enum.dump_values(@schemaless_types, :my_integer_enums) == [1, 2, 5]
    end
  end

  describe "cast_value/3" do
    test "returns correct values" do
      assert Ecto.Enum.cast_value(EnumSchema, :my_enum, "foo") == {:ok, :foo}
      assert Ecto.Enum.cast_value(EnumSchema, :my_enum, :foo) == {:ok, :foo}
      assert Ecto.Enum.cast_value(EnumSchema, :my_enum, "qux") == :error
      assert Ecto.Enum.cast_value(EnumSchema, :my_enum, :qux) == :error

      assert Ecto.Enum.cast_value(EnumSchema, :my_integer_enum, 1) == {:ok, :foo}
      assert Ecto.Enum.cast_value(EnumSchema, :my_integer_enum, :foo) == {:ok, :foo}
      assert Ecto.Enum.cast_value(EnumSchema, :my_integer_enum, 6) == :error
      assert Ecto.Enum.cast_value(EnumSchema, :my_integer_enum, "qux") == :error
      assert Ecto.Enum.cast_value(EnumSchema, :my_integer_enum, :qux) == :error

      assert Ecto.Enum.cast_value(EnumSchema, :my_string_enum, "fooo") == {:ok, :foo}
      assert Ecto.Enum.cast_value(EnumSchema, :my_string_enum, :foo) == {:ok, :foo}
      assert Ecto.Enum.cast_value(EnumSchema, :my_string_enum, "quux") == :error
      assert Ecto.Enum.cast_value(EnumSchema, :my_string_enum, :qux) == :error
    end
  end

  describe "mappings/2" do
    test "returns correct values" do
      assert Ecto.Enum.mappings(EnumSchema, :my_enum) == [foo: "foo", bar: "bar", baz: "baz"]
      assert Ecto.Enum.mappings(EnumSchema, :my_enums) == [foo: "foo", bar: "bar", baz: "baz"]

      assert Ecto.Enum.mappings(EnumSchema, :my_string_enum) == [
               foo: "fooo",
               bar: "baar",
               baz: "baaz"
             ]

      assert Ecto.Enum.mappings(EnumSchema, :my_string_enums) == [
               foo: "fooo",
               bar: "baar",
               baz: "baaz"
             ]

      assert Ecto.Enum.mappings(EnumSchema, :my_integer_enum) == [foo: 1, bar: 2, baz: 5]
      assert Ecto.Enum.mappings(EnumSchema, :my_integer_enums) == [foo: 1, bar: 2, baz: 5]
      assert Ecto.Enum.mappings(EnumSchema, :virtual_enum) == [foo: "foo", bar: "bar", baz: "baz"]

      assert Ecto.Enum.mappings(@schemaless_types, :my_enum) == [
               foo: "foo",
               bar: "bar",
               baz: "baz"
             ]

      assert Ecto.Enum.mappings(@schemaless_types, :my_enums) == [
               foo: "foo",
               bar: "bar",
               baz: "baz"
             ]

      assert Ecto.Enum.mappings(@schemaless_types, :my_string_enum) == [
               foo: "fooo",
               bar: "baar",
               baz: "baaz"
             ]

      assert Ecto.Enum.mappings(@schemaless_types, :my_string_enums) == [
               foo: "fooo",
               bar: "baar",
               baz: "baaz"
             ]

      assert Ecto.Enum.mappings(@schemaless_types, :my_integer_enum) == [foo: 1, bar: 2, baz: 5]
      assert Ecto.Enum.mappings(@schemaless_types, :my_integer_enums) == [foo: 1, bar: 2, baz: 5]
    end

    test "raises on bad schema" do
      assert_raise ArgumentError, "NotASchema is not an Ecto schema or types map", fn ->
        Ecto.Enum.mappings(NotASchema, :foo)
      end
    end

    test "raises on bad fields" do
      assert_raise ArgumentError, "not_enum is not an Ecto.Enum field", fn ->
        Ecto.Enum.mappings(EnumSchema, :not_enum)
      end

      assert_raise ArgumentError, "foo does not exist", fn ->
        Ecto.Enum.mappings(EnumSchema, :foo)
      end
    end
  end
end
