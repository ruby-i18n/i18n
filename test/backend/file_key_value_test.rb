require 'test_helper'

class FileKeyValueTest < I18n::TestCase
  class SimpleHashStore < Hash
    attr_reader :transactions, :reads, :writes

    def initialize
      super
      @transactions = @reads = @writes = 0
    end

    def transaction
      yield.tap { @transactions += 1 }
    end

    def [](key)
      super.tap { @reads += 1 }
    end

    def []=(key, value)
      super.tap { @writes += 1 }
    end
  end

  def setup_backend!(subtrees = false)
    @store = SimpleHashStore.new
    I18n.backend = I18n::Backend::FileKeyValue.new(@store, subtrees, [locales_dir])
  end

  test 'basic store_translations functionality' do
    setup_backend!
    store_translations(:en, :foo => { :baz => 'BAZ'})
    assert_equal('BAZ', I18n.t('foo.baz'))
    assert_equal 1, @store.writes
    assert_equal 1, @store.reads
    assert_equal 0, @store.transactions
  end

  test 'store_translations with subtrees disabled' do
    setup_backend!
    store_translations(:en, foo: { bar: { baz: 'BAZ' } })
    assert_equal('translation missing: en.foo', I18n.t('foo'))
    assert_raise I18n::MissingTranslationData do
      I18n.t('foo', raise: true)
    end
  end

  test 'store_translations with subtrees enabled' do
    setup_backend!(true)
    store_translations(:en, foo: { baa: 'BAB' })
    store_translations(:en, foo: { bar: {baz: 'BAZ'} })
    assert_equal({ bar: {baz: 'BAZ' }, baa: 'BAB' }, I18n.t('foo'))
    assert_equal 4, @store.reads
    assert_equal 5, @store.writes
  end

  test 'load_translations' do
    setup_backend!
    I18n.load_path = [locales_dir + '/en.yml']
    assert_equal('baz', I18n.t('foo.bar'))
    assert_equal 2, @store.writes
    assert_equal 1, @store.transactions

    I18n.backend.reload!
    assert_equal 2, @store.writes
    assert_equal 1, @store.transactions
  end
  
  test 'hash store without #transaction' do
    setup_backend!
    I18n.backend.store = {}
    I18n.load_path = [locales_dir + '/en.yml']
    assert_equal('baz', I18n.t('foo.bar'))
  end
end if I18n::TestCase.key_value?
