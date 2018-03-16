require_relative "test_helper"

class ModelTest < Minitest::Test
  def test_disable_callbacks_model
    store_names ["product a"]

    Searchkick.callbacks(false) do
      store_names ["product b"]
    end
    assert_search "product", ["product a"]

    Product.reindex

    assert_search "product", ["product a", "product b"]
  end

  def test_disable_callbacks_global
    # make sure callbacks default to on
    assert Searchkick.callbacks?

    store_names ["product a"]

    Searchkick.disable_callbacks
    assert !Searchkick.callbacks?

    store_names ["product b"]
    assert_search "product", ["product a"]

    Product.reindex

    Searchkick.enable_callbacks
    store_names ["product c"]

    assert_search "product", ["product a", "product b", "product c"]
  end

  def test_model_with_async_callbacks
    store_names ["animal a"], Animal

    Animal.reindex

    assert_search "animal", ["animal a"], {}, Animal

    Searchkick.callbacks(false) do
      store_names ["animal b"], Animal
    end
    assert_search "animal", ["animal a"], {}, Animal

    Searchkick.callbacks(true) do
      store_names ["animal c"], Animal
    end

    assert_search "animal", ["animal a", "animal c"], {}, Animal
  end

  def test_global_async_callbacks
  #   # make sure callbacks default to on
    assert Searchkick.callbacks?

    store_names ["animal a"], Animal
    assert_search "animal", ["animal a"], {}, Animal

    Searchkick.disable_callbacks
    assert !Searchkick.callbacks?

    store_names ["animal b"]
    assert_search "animal", ["animal a"], {}, Animal


    Searchkick.enable_callbacks
    Animal.first.update(name: "animal c")
    assert_search "animal", ["animal a", "animal c"], {}, Animal
  end

  def test_multiple_models
    store_names ["Product A"]
    store_names ["Product B"], Speaker
    assert_equal Product.all.to_a + Speaker.all.to_a, Searchkick.search("product", index_name: [Product, Speaker], fields: [:name], order: "name").to_a
  end
end
