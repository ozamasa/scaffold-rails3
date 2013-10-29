module ActiveSupport
  module CoreExtensions
    module Array
      module Conversions

        def to_csv(instance, options = {})
          csv = ApplicationCsv.new
          csv.write(self, instance, options)
        end

        def to_xls(instance, options = {})
          excel = ApplicationExcel.new
          title = instance.name
          excel.create_worksheet(title)
          excel.cell(0, 0, title, :size => 14, :bold => true)

          excel.write(self, options)

          excel.data
        end

      end
    end
  end
end
