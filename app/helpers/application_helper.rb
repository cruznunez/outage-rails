module ApplicationHelper
  # monkeypatched to add comma delimiter
  def page_entries_info(collection, entry_name: nil)
    records = collection.respond_to?(:records) ? collection.records : collection.to_a
    page_size = records.size
    entry_name = if entry_name
                   entry_name.pluralize(page_size, I18n.locale)
                 else
                   collection.entry_name(count: page_size).downcase
                 end

    if collection.total_pages < 2
      t('helpers.page_entries_info.one_page.display_entries', entry_name: entry_name, count: collection.total_count)
    else
      from = collection.offset_value + 1
      to =
        if collection.is_a? ::Kaminari::PaginatableArray
          [collection.offset_value + collection.limit_value, collection.total_count].min
        else
          collection.offset_value + page_size
        end

      t('helpers.page_entries_info.more_pages.display_entries', entry_name: entry_name, first: from, last: to, total: collection.total_count.to_fs(:delimited))
    end.html_safe
  end
end
