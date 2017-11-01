require 'ensurance/date'

RSpec.describe Ensurance::Date do
  it "returns nil for nil" do
    expect(described_class.ensure(nil)).to eq(nil)
  end

  it "returns Date for Time" do
    expect(described_class.ensure(Time.now)).to be_a(Date)
  end

  it "returns Date for Int" do
    value = Time.now.to_i
    expect(described_class.ensure(value)).to be_a(Date)
  end

  it "returns Date for Float" do
    value = Time.now.to_f
    expect(described_class.ensure(value)).to be_a(Date)
  end

  it "returns Date for Date" do
    expect(described_class.ensure(Date.today)).to be_a(Date)
  end

  it "returns Date for full time String" do
    str = Time.now.to_s
    expect(described_class.ensure(str)).to be_a(Date)
  end

  it "returns Date for time-as-int String" do
    str = Time.now.to_i.to_s
    expect(described_class.ensure(str)).to be_a(Date)
  end

  it "returns Date for time-as-float String" do
    str = Time.now.to_f.to_s
    expect(described_class.ensure(str)).to be_a(Date)
  end

  it "returns Date for a DateTime" do
    value = DateTime.now
    expect(described_class.ensure(value)).to be_a(Date)
  end

  it "errors if object cannot be cast to a Time" do
    value = 1..20
    expect{described_class.ensure(value)}.to raise_error(ArgumentError)
  end

end
