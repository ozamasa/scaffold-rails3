# encoding: utf-8
class ApplicationExcel

  require 'spreadsheet'

  attr_reader :book, :sheet

  def initialize
    Spreadsheet.client_encoding = 'cp932'
    @book = Spreadsheet::Workbook.new
  end

  def create_worksheet(title)
    @sheet = @book.create_worksheet
    @sheet.name = Kconv.tosjis(title)
  end

  def write(alls, opt={})
    alls.each_with_index do |row, i|
      row.attributes.each_with_index do |col, j|
        col[1] = col[1].strftime("%Y/%m/%d %H:%M:%S") if col[1].class.to_s == "Time"
        cell(    1, j, (col[0] rescue nil), :top => :medium, :right => :thin, :bottom => :medium, :left => :thin) if i == 0
        cell(i + 2, j, (col[1] rescue nil), :top => :thin,   :right => :thin, :bottom => :thin,   :left => :thin)
      end
    end
  end

  def cell(row, col, val, opt={})
    @sheet[row, col] = Kconv.tosjis(Kconv.tosjis(val)) rescue @sheet[row, col] = val.to_i unless val.blank?
    rule(row, col, opt)
  end

  def rule(row, col, opt={})
    @sheet[row, col] = @sheet[row, col]

    before = @sheet.row(row).format(col)

    format = Spreadsheet::Format.new
#    format.font = Spreadsheet::Font.new(Kconv.tosjis("MS Pゴシック"), :size => 11, :encoding => :shift_jis)
    format.font = Spreadsheet::Font.new(Kconv.tosjis("MS ゴシック"), :size => 10, :encoding => :shift_jis)
    format.font.size   = opt[:size] unless opt[:size].blank?
    format.font.bold   = opt[:bold] unless opt[:bold].blank?
    format.font.italic = opt[:italic].blank? ? before.font.italic : opt[:italic]

    format.number_format = opt[:number_format]? '#,###,###,###,###' : before.number_format
    format.top    = opt[:top   ].blank? ? before.top    : opt[:top]
    format.bottom = opt[:bottom].blank? ? before.bottom : opt[:bottom]
    format.left   = opt[:left  ].blank? ? before.left   : opt[:left]
    format.right  = opt[:right ].blank? ? before.right  : opt[:right]
    format.horizontal_align = opt[:align].blank? ? before.horizontal_align : opt[:align]
    @sheet.row(row).set_format(col, format)

    @sheet.row(row).height   = opt[:height] unless opt[:height].blank?
    @sheet.column(col).width = opt[:width ] unless opt[:width].blank?
  end

  def data
    require 'stringio'
    data = StringIO.new ''
    @book.write data
    return data.string.bytes.to_a.pack("C*")
  end

end
