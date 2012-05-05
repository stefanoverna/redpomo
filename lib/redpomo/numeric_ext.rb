class Numeric
  module Units
    Sec        = 1
    Min        = Sec     * 60
    Hour       = Min     * 60
    Day        = Hour    * 24
    Week       = Day     * 7
    Month      = Week    * 4
    Year       = Day     * 365
    Decade     = Year    * 10
    Century    = Decade  * 10
    Millennium = Century * 10
    Eon        = 1.0/0
  end

  def seconds_in_words
    unit = get_unit(self)
    unit_difference = self / Units.const_get(unit.capitalize)
    unit = unit.to_s.downcase + ('s' if self > 1)
    "#{unit_difference.to_i} #{unit}"
  end

  private
  def get_unit(time_difference)
    Units.constants.each_cons(2) do |con|
      return con.first if (Units.const_get(con[0])...Units.const_get(con[1])) === time_difference
    end
  end
end
