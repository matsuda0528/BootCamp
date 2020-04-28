class String
  def extract_numbers
    self.gsub(/[^0-9]/,"").to_i
  end
end
