require File.dirname(__FILE__)+'/base'

module GData

  class Spreadsheet < GData::Base
    attr_accessor :worksheet_id
    
    def initialize(spreadsheet_id)
      @spreadsheet_id = spreadsheet_id
      @worksheet_id = 1
      super 'wise', 'gdata-ruby', 'spreadsheets.google.com'
    end

    def evaluate_cell(cell)
      path = "/feeds/cells/#{@spreadsheet_id}/#{@worksheet_id}/#{@headers ? "private" : "public"}/basic/#{cell}"
      request(path)
      doc = Hpricot(request(path))
      result = (doc/"content[@type='text']").inner_html
    end

    def save_entry(entry)
      path = "/feeds/cells/#{@spreadsheet_id}/#{@worksheet_id}/#{@headers ? 'private' : 'public'}/full"
      post(path, entry)
    end

    def entry(data)
      value = @formula ? '='+data : data
      <<XML
  <entry xmlns="http://www.w3.org/2005/Atom" xmlns:gs="http://schemas.google.com/spreadsheets/2006">
    <gs:cell row="#{@row}" col="#{@col}" inputValue="#{value}" />
  </entry>
XML
    end
    
    # def add_to_cell(data, cell, options = {})
    #   convert_to_row_col(cell)
    #   save_entry( entry(data, options) )
    # end
    
    def add(data, options = {})
      raise GData::Exceptions::Spreadsheet::UnspecifiedCell if options[:to].nil?
      @cell = options[:to] 
      @formula = ( options[:formula] || false ) 
      convert_to_row_col
      save_entry(entry(data))
    end
    
    def convert_to_row_col
      @cell.match(/^R(\d+)C(\d+)$/)
      @row, @col = $1, $2
    end
    
  end

end
