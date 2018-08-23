require 'active_record'
require 'globalid'
require 'awesome_print'

GlobalID.app = :test

class TestRecord < ActiveRecord::Base
  include Ensurance
  include GlobalID::Identification

  ensure_by :parent_type, :id
end

RSpec.describe Ensurance do
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
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
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

  it "ensures by a VALID hash" do
    value = { id: 2 }
    expect(TestRecord.ensure(value)).to be_a(TestRecord)

    value = { "id" => 2 }
    expect(TestRecord.ensure(value)).to be_a(TestRecord)

    value = { "parent_type" => "b" }
    expect(TestRecord.ensure(value)).to be_a(TestRecord)

    value = { parent_type: "b"}
    expect(TestRecord.ensure(value)).to be_a(TestRecord)
  end

  it "fails to ensure with an INVALID hash" do
    value = { a: 2 }
    expect(TestRecord.ensure(value)).to be_nil
  end

  it "succeeds with an array" do
    value = [1,2,3]
    expect(TestRecord.ensure(value).size).to eq(3)
  end

  it "ensures by a parent_type" do
    value = "b"
    result = TestRecord.ensure(value)
    expect(result).to be_a(TestRecord)
    expect(result.parent_type).to eq(value)
  end

  it "raises exception if record not found when calling ensure!" do
    value = "z"
    expect{ TestRecord.ensure!(value) }.to raise_error(ActiveRecord::RecordNotFound)
  end

end
