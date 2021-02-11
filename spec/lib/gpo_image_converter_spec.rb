require 'spec_helper'

describe Paperclip::GpoImageConverter do

  def stub_full_page_pixel_width(pixels)
    allow_any_instance_of(Paperclip::GpoImageConverter).to receive(:full_page_pixel_width_in_print).and_return(pixels)
  end

  def stub_max_desired_pixel_width(pixels)
    allow_any_instance_of(Paperclip::GpoImageConverter).to receive(:max_desired_pixel_width).and_return(pixels)
  end

  def stub_paperclip_style(style_name)
    allow_any_instance_of(Paperclip::GpoImageConverter).to receive(:paperclip_style).and_return(style_name)
  end

  before(:each) do
    stub_paperclip_style(:large)
  end

  it "calculates resize_options correctly for images less than the max_desired_pixel_width (eg the full width of the image's HTML container)" do
    allow_any_instance_of(Paperclip::GpoImageConverter).to receive(:sourced_via_ecfr_dot_gov_options?).and_return(true)
    stub_full_page_pixel_width(351)
    stub_max_desired_pixel_width(823)

    # Original resolution: 126x28
    file = File.open('spec/fixtures/ec10oc91.003.pdf')

    resize_options = Paperclip::GpoImageConverter.new(file).send(:resize_options)

    expect(resize_options).to eq('-resize 295x66')
  end

  it "calculates resize_options correctly for images greater than the max_desired_pixel_width (eg the full width of the image's HTML container)" do
    allow_any_instance_of(Paperclip::GpoImageConverter).to receive(:sourced_via_ecfr_dot_gov_options?).and_return(true)
    stub_full_page_pixel_width(351)
    stub_max_desired_pixel_width(823)

    # Original resolution: 391x105
    file = File.open('spec/fixtures/er02my11.048.pdf')

    resize_options = Paperclip::GpoImageConverter.new(file).send(:resize_options)

    expect(resize_options).to eq('-resize 823x221')
  end

  it "creates the historically-used source_file options for the :original_png style" do
    stub_paperclip_style(:original_png)
    file = File.open('spec/fixtures/er02my11.048.pdf')
    converter = Paperclip::GpoImageConverter.new(file)
    expect(converter.send(:resize_options)).to eq(nil)
    expect(converter.send(:additional_options)).to eq(nil)
  end

end

