require 'mechanize'
require 'nokogiri'

class Quiz
  def initialize
    @agent = Mechanize.new
    @page = @agent.get("https://staqresults.herokuapp.com/")
  end

  def run
    sign_in
    parse_results
  end

  private

  def sign_in
    signin_form = @page.forms.first
    signin_form.email = "test@example.com"
    signin_form.password = "secret"
    @page = @agent.submit(signin_form)
  end

  def parse_results
    rows = @page.css("//table.table-striped//tr")
    column_names = rows.shift.css('th.text-right').map {|th| th.text.downcase.to_sym}
    results = rows.css("tr").map do |row|
      row_date = row.css("td.date").text
      row_results = row.css("td.text-right").map(&:text)
      [row_date, column_names.zip(row_results).to_h]
    end
    results.to_h
  end
end