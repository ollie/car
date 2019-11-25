module Sinatra
  module AppHelpers
    def format_number(number, format: '%.02f')
      format(format, number).tap do |s|
        s.reverse!
        s.gsub!(/(\d{3})(\d)/, '\1 \2')
        s.tr!('.', ',')
        s.reverse!
      end
    end

    def pagination_pages(dataset)
      pages        = []
      outer_window = 1
      inner_window = 2

      inner_window_start = dataset.current_page - inner_window
      inner_window_start = 1 if inner_window_start < 1
      inner_window_end   = dataset.current_page + inner_window
      inner_window_end   = dataset.page_count if inner_window_end > dataset.page_count
      inner_window_range = inner_window_start..inner_window_end

      if inner_window_start >= 1 + outer_window - 1
        prev_outer_window_start = 1
        prev_outer_window_end   = 1 + outer_window - 1
        prev_outer_window_end   = inner_window_start - 1 if prev_outer_window_end >= inner_window_start
        prev_outer_window_range = prev_outer_window_start..prev_outer_window_end
      end

      if inner_window_end <= dataset.page_count - outer_window + 1
        next_outer_window_start = dataset.page_count - outer_window + 1
        next_outer_window_start = inner_window_end + 1 if next_outer_window_start <= inner_window_end
        next_outer_window_end   = dataset.page_count
        next_outer_window_range = next_outer_window_start..next_outer_window_end
      end

      pages << :prev unless dataset.first_page?

      if prev_outer_window_range
        prev_outer_window_range.each do |page|
          pages << page if page < inner_window_start
        end

        pages << :separator if inner_window_start - prev_outer_window_end > 1
      end

      inner_window_range.each do |page|
        pages <<
          if page == dataset.current_page
            [page, true]
          else
            page
          end
      end

      if next_outer_window_range
        pages << :separator if next_outer_window_start - inner_window_end > 1

        next_outer_window_range.each do |page|
          pages << page if page > inner_window_end
        end
      end

      pages << :next unless dataset.last_page?

      pages
    end
  end
end
