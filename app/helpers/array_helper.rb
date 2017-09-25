module ArrayHelper

  # Converts an array of the form
  # [[k1, val1],[k2, val2]] to a hash of the form
  # { k1: val, k2: val2}
  # val1 and val2 can be inner arrays
  #----------------------------------
  def array_to_hash(a)
    h = {}
    a.each do |i|
      key = i.first
      value = i.last
      h[key] = value
    end
    h
  end
end
