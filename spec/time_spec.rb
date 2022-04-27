require 'ensurance/time_ensure'

RSpec.describe ::Time do
  before do
    Time.zone = 'Eastern Time (US & Canada)'
  end

  it 'returns nil for nil' do
    expect(described_class.ensure(nil)).to eq(nil)
  end

  it 'returns nil for empty string' do
    expect(described_class.ensure(' ')).to eq(nil)
  end

  it 'returns Time for Time' do
    expect(described_class.ensure(Time.now)).to be_a(Time)
  end

  it 'returns Time for Int' do
    value = Time.now.to_i
    result = described_class.ensure(value)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'returns Time for Millisecond Int' do
    value = (Time.now.to_f * 1000).to_i
    result = described_class.ensure(value)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'returns Time for Microsecond Int' do
    value = (Time.now.to_f * 1000000000).to_i
    result = described_class.ensure(value)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'returns Time for Float' do
    value = Time.now.to_f
    result = described_class.ensure(value)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'returns Time for Date' do
    expect(described_class.ensure(Date.today)).to be_a(Time)
  end

  it 'returns Time for full time String' do
    str = Time.now.to_s
    result = described_class.ensure(str)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'returns Time for time-as-int String' do
    str = Time.now.to_i.to_s
    result = described_class.ensure(str)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'returns Time for millisecond-as-int String' do
    str = (Time.now.to_f * 1000).to_i.to_s
    result = described_class.ensure(str)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'returns Time for microsecond-as-int String' do
    str = (Time.now.to_f * 1000000).to_i.to_s
    result = described_class.ensure(str)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'returns Time for time-as-float String' do
    str = Time.now.to_f.to_s
    result = described_class.ensure(str)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'returns Time for a DateTime' do
    value = DateTime.now
    result = described_class.ensure(value)
    expect(result).to be_a(Time)
    expect(result.year).to eq(Time.now.year)
  end

  it 'errors if object cannot be cast to a Time' do
    value = 1..20
    expect { described_class.ensure(value) }.to raise_error(ArgumentError)
  end
end
