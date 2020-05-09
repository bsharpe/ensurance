require 'active_record'
require 'globalid'
require 'awesome_print'

GlobalID.app = :test

class TestRecord < ActiveRecord::Base
  include Ensurance
  include GlobalID::Identification

  ensure_by :parent_type, :id
end

class UuidRecord < ActiveRecord::Base
  include Ensurance

  # It's important that non-id columns come before the id column
  ensure_by :uuid, :id
end

RSpec.describe Ensurance do
  before(:all) do
    # Setup tables in sqlite mem
    if defined?(ActiveRecord::VERSION) &&
       ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR >= 2

      # Was removed in Rails 5 and is effectively true.
      ActiveRecord::Base.raise_in_transactional_callbacks = true
    end

    db_config = YAML.load_file(File.expand_path('database.yml', __dir__)).fetch(ENV['DB'] || 'sqlite')
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Schema.verbose = false

    # AR caches columns options like defaults etc. Clear them!
    ActiveRecord::Base.connection.create_table :test_records do |t|
      t.column :active, :boolean, default: true
      t.column :parent_id, :integer
      t.column :parent_type, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :state, :integer
    end

      # AR caches columns options like defaults etc. Clear them!
    ActiveRecord::Base.connection.create_table :uuid_records do |t|
      t.column :uuid, :uuid
    end

    parent_types = %w[a b c d e f]
    5.times do |value|
      TestRecord.create(parent_type: parent_types[value])
    end

    # It's important that a non-digit starts the uuid of the first record
    UuidRecord.create(uuid: "c69c60ac-bfd1-4832-b8a7-cc2b60306368")
    UuidRecord.create(uuid: "1a7ebd41-4856-44cb-867c-47a07c473fc4")
  end

  after(:all) do
    # teardown db
    tables = if ActiveRecord::VERSION::MAJOR >= 5
               ActiveRecord::Base.connection.data_sources
             else
               ActiveRecord::Base.connection.tables
             end

    tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  it 'ensures by record_id' do
    value = 3
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it 'ensures by uuid first' do
    value = "1a7ebd41-4856-44cb-867c-47a07c473fc4"
    expect(UuidRecord.ensure(value).uuid).to eq(value)
  end

  it 'ensures that a non-matching uuid doesnt return a bad record' do
    value = "1c0ffee-4856-44cb-867c-47a07c473fc4"
    expect(UuidRecord.ensure(value)).to eq(nil)
  end

  it 'ensures by id second' do
    value = 1
    expect(UuidRecord.ensure(value).uuid).to eq("c69c60ac-bfd1-4832-b8a7-cc2b60306368")
  end

  it 'ensures by full_record' do
    value = TestRecord.first
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it 'ensures by a global_id string' do
    value = TestRecord.first.to_global_id.to_s
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it 'ensures by a global_id' do
    value = TestRecord.first.to_global_id
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it 'ensures by a VALID hash' do
    value = { id: 2 }
    expect(TestRecord.ensure(value)).to be_a(TestRecord)

    value = { 'id' => 2 }
    expect(TestRecord.ensure(value)).to be_a(TestRecord)

    value = { 'parent_type' => 'b' }
    expect(TestRecord.ensure(value)).to be_a(TestRecord)

    value = { parent_type: 'b' }
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it 'fails to ensure with an INVALID hash' do
    value = { a: 2 }
    expect(TestRecord.ensure(value)).to be_nil
  end

  it 'succeeds with an array' do
    value = [1, 2, 3]
    expect(TestRecord.ensure(value).size).to eq(3)
  end

  it 'ensures by a parent_type' do
    value = 'b'
    result = TestRecord.ensure(value)
    expect(result).to be_a(TestRecord)
    expect(result.parent_type).to eq(value)
  end

  it 'raises exception if record not found when calling ensure!' do
    value = 'z'
    expect { TestRecord.ensure!(value) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
