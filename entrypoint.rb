recipes = node['recipes'] || []

recipes.each do |recipe|
  puts "./cookbooks/#{recipe}/install.rb"
end
