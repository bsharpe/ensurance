require 'ensurance/hash_ensure'

RSpec.describe ::Hash do
  it 'returns nil for nil' do
    expect(described_class.ensure(nil)).to eq(nil)
  end

  it 'returns Hash for Hash' do
    value = { a: 1, b: 2 }
    expect(described_class.ensure(value)).to be_a(Hash)
  end

  it 'returns Hash for Hash' do
    value = { a: 1, b: 2 }.with_indifferent_access
    expect(described_class.ensure(value)).to be_a(Hash)
  end

  it 'returns Hash for JSON string' do
    value = { a: 1, b: 2 }.to_json
    expect(described_class.ensure(value)).to be_a(Hash)
  end

  it 'returns Hash for Array' do
    value = [['a', 2], ['b', 3]]
    expect(described_class.ensure(value)).to be_a(Hash)
  end

  it 'errors if object cannot be cast to a Hash' do
    value = 1..20
    expect { described_class.ensure(value) }.to raise_error(ArgumentError)
  end
end
