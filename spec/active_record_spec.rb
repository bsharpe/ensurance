require 'ensurance/date'
require 'active_record'
require 'globalid'
require 'awesome_print'

GlobalID.app = :test

class TestRecord < ActiveRecord::Base
  include Ensurance::ActiveRecord
  include GlobalID::Identification

  ensure_by [:id, :parent_type]
end

RSpec.describe Ensurance::ActiveRecord do
  before(:all) do
    # Setup tables in sqlite mem
    if defined?(ActiveRecord::VERSION) &&
      ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR >= 2

      # Was removed in Rails 5 and is effectively true.
      ActiveRecord::Base.raise_in_transactional_callbacks = true
    end

    db_config = YAML.load_file(File.expand_path("../database.yml", __FILE__)).fetch(ENV["DB"] || "sqlite")
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

    parent_types = %w(a b c d e f)
    5.times do |value|
      TestRecord.create(parent_type: parent_types[value])
    end
  end

  after(:all) do
    # teardown db
    if ActiveRecord::VERSION::MAJOR >= 5
      tables = ActiveRecord::Base.connection.data_sources
    else
      tables = ActiveRecord::Base.connection.tables
    end

    tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  it "ensures by record_id" do
    value = 3
    expect(TestRecord.ensure(3)).to be_a(TestRecord)
  end

  it "ensures by full_record" do
    value = TestRecord.first
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it "ensures by a global_id string" do
    value = TestRecord.first.to_global_id.to_s
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it "ensures by a global_id" do
    value = TestRecord.first.to_global_id
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it "ensures by a hash" do
    value = { id: 2 }
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it "ensures by a parent_type" do
    value = "b"
    result = TestRecord.ensure(value)
    expect(result).to be_a(TestRecord)
    expect(result.parent_type).to eq(value)
  end


end
