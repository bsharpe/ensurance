require 'ensurance/array_ensure'

RSpec.describe ::Array do
  it 'returns nil for nil' do
    expect(described_class.ensure(nil)).to eq(nil)
  end

  it 'returns Array for String' do
    expect(described_class.ensure('1,2,3,4')).to eq(%w[1 2 3 4])
  end

  it 'returns Array for Array' do
    value = [1, 2, 3]
    expect(described_class.ensure(value)).to eq(value)
  end

  it 'returns Array for Number' do
    value = 1
    expect(described_class.ensure(value)).to eq([1])
  end
end
