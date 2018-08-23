require 'ensurance/time_ensure'

RSpec.describe ::Time do
  it 'returns nil for nil' do
    expect(described_class.ensure(nil)).to eq(nil)
  end

  it 'returns Time for Time' do
    expect(described_class.ensure(Time.now)).to be_a(Time)
  end

  it 'returns Time for Int' do
    value = Time.now.to_i
    expect(described_class.ensure(value)).to be_a(Time)
  end

  it 'returns Time for Float' do
    value = Time.now.to_f
    expect(described_class.ensure(value)).to be_a(Time)
  end

  it 'returns Time for Date' do
    expect(described_class.ensure(Date.today)).to be_a(Time)
  end

  it 'returns Time for full time String' do
    str = Time.now.to_s
    expect(described_class.ensure(str)).to be_a(Time)
  end

  it 'returns Time for time-as-int String' do
    str = Time.now.to_i.to_s
    expect(described_class.ensure(str)).to be_a(Time)
  end

  it 'returns Time for time-as-float String' do
    str = Time.now.to_f.to_s
    expect(described_class.ensure(str)).to be_a(Time)
  end

  it 'returns Time for a DateTime' do
    value = DateTime.now
    expect(described_class.ensure(value)).to be_a(Time)
  end

  it 'errors if object cannot be cast to a Time' do
    value = 1..20
    expect { described_class.ensure(value) }.to raise_error(ArgumentError)
  end
end
