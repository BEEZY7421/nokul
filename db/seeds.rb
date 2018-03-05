# This file is used to create initial data, that is needed for app to live.

# Create countries
File.open("#{Rails.root}/db/countries.yml") do |countries|
  countries.read.each_line do |country|
    iso, name, code = country.chomp.split("|")

    begin
      c = Country.create!(name: name, iso: iso, code: code)
      puts "Country created => #{c.name}"
    rescue ActiveModel::StrictValidationFailed
      puts "Invalid record, skipping!"
    end
  end
end

# Create regions
File.open("#{Rails.root}/db/regions.yml") do |regions|
  regions.read.each_line do |region|
    name, nuts_code = region.chomp.split("|")
    country = Country.find_by(iso: nuts_code[0..1])

    begin
      region = country.regions.create!(name: name, nuts_code: nuts_code)
      puts "Region created => #{region.name}"
    rescue ActiveModel::StrictValidationFailed
      puts "Invalid record, skipping!"
    end
  end
end

# Create cities
File.open("#{Rails.root}/db/cities.yml") do |cities|
  cities.read.each_line do |city|
    name, iso, nuts_code = city.chomp.split("|")
    region = Region.find_by(nuts_code: nuts_code[0..2])

    begin
      city = region.cities.create!(name: name, iso: iso, nuts_code: nuts_code, country: region.country)
      puts "City created => #{city.name}"
    rescue ActiveModel::StrictValidationFailed
      puts "Invalid record, skipping!"
    end
  end
end

# Create academic staff
# client = Services::Yoksis::V1::AkademikPersonel.new
# number_of_pages = client.number_of_pages

# for i in 1..number_of_pages
#   client.list_academic_staff(i).each do |academic_staff|
#     foo = academic_staff[:tc_kimlik_no]
#     bar = academic_staff[:adi]
#     baz = academic_staff[:soyadi]
#     taz = academic_staff[:kadro_unvan]
#     kaz = academic_staff[:birim_id]
#   end
# end