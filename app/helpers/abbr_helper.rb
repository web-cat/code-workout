module AbbrHelper
  ::States = {
      AK: "Alaska",
      AL: "Alabama",
      AR: "Arkansas",
      AS: "American Samoa",
      AZ: "Arizona",
      CA: "California",
      CO: "Colorado",
      CT: "Connecticut",
      DC: "District of Columbia",
      DE: "Delaware",
      FL: "Florida",
      GA: "Georgia",
      GU: "Guam",
      HI: "Hawaii",
      IA: "Iowa",
      ID: "Idaho",
      IL: "Illinois",
      IN: "Indiana",
      KS: "Kansas",
      KY: "Kentucky",
      LA: "Louisiana",
      MA: "Massachusetts",
      MD: "Maryland",
      ME: "Maine",
      MI: "Michigan",
      MN: "Minnesota",
      MO: "Missouri",
      MS: "Mississippi",
      MT: "Montana",
      NC: "North Carolina",
      ND: "North Dakota",
      NE: "Nebraska",
      NH: "New Hampshire",
      NJ: "New Jersey",
      NM: "New Mexico",
      NV: "Nevada",
      NY: "New York",
      OH: "Ohio",
      OK: "Oklahoma",
      OR: "Oregon",
      PA: "Pennsylvania",
      PR: "Puerto Rico",
      RI: "Rhode Island",
      SC: "South Carolina",
      SD: "South Dakota",
      TN: "Tennessee",
      TX: "Texas",
      UT: "Utah",
      VA: "Virginia",
      VI: "Virgin Islands",
      VT: "Vermont",
      WA: "Washington",
      WI: "Wisconsin",
      WV: "West Virginia",
      WY: "Wyoming"
  }

  ::Lowers = ['the', 'and', 'for', 'at', 'in', 'of']

  def to_title_case(text)
    text = text.titleize
    words = text.split
    words.map do |w|
      if ::Lowers.include?(w.downcase)
        w.downcase!
      end
    end

    return words.join(' ')
  end

  def caps_strategy(text)
    r = /[A-Z\-]/
    matches = text.scan(r)
    if matches.present?
      abbr = matches.join
      return abbr
    end

    return nil
  end

  def states_strategy(text)
    words = text.split
    state_word = nil
    state = nil

    ::States.each do |k, v|
      if text.include?(v)
        state = k.to_s
        state_word = v
        break
      end
    end

    index = -1
    if state
      words.each do |w|
        unless ::Lowers.include?(w)
          index = index + 1
        end
        if state_word.start_with?(w)
          break
        end
      end

      state_removed = text.gsub(state_word, '')
      abbr = caps_strategy(state_removed)
      if abbr
        abbr = abbr.insert(index, state)
        return abbr
      end
    end

    return nil
  end

  def lowers_strategy(text)
    index = 0
    lower_word = nil
    words = text.split
    words.each do |w|
      unless ::Lowers.include?(w)
        index = index + 1
      else
        lower_word = w
        break
      end
    end

    abbr = caps_strategy(text)
    if abbr && lower_word
      abbr = abbr.insert(index, lower_word[0])
      return abbr
    end

    return nil
  end
end
