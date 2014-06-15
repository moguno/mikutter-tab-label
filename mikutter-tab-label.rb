# coding: UTF-8

Plugin.create(:mikutter_tab_label) {
  UserConfig[:tab_label_savedsearch] ||= true
  UserConfig[:tab_label_profile] ||= false
  UserConfig[:tab_label_list] ||= false

  @i_tabs = []

  def apply()
    @i_tabs.each { |i_tab|
      icon = i_tab.icon
      i_tab.set_icon nil
      i_tab.set_icon icon
    }
  end

  on_boot {
    UserConfig.connect(:tab_label_savedsearch) { |key, val, before, id|
      apply()
    }

    UserConfig.connect(:tab_label_profile) { |key, val, before, id|
      apply()
    }

    UserConfig.connect(:tab_label_list) { |key, val, before, id|
      apply()
    }
  }

  on_tab_created do |i_tab|
    @i_tabs << i_tab
    i_tab.set_icon i_tab.icon
  end

  settings("タブのラベル") {
    boolean("保存された検索", :tab_label_savedsearch)
    boolean("プロフィール", :tab_label_profile)
    boolean("リスト", :tab_label_list)
  }

  filter_tab_update_widget { |i_tab, widgets|
    msg = case i_tab.slug.to_s
    when /^savedsearch/
      if UserConfig[:tab_label_savedsearch]
        i_tab.name
      else
        nil
      end

    when /^profile-/
      if UserConfig[:tab_label_profile] && i_tab.icon
        begin
          i_tab.slug.to_s =~ /^profile-(.+)$/
          user = User.findbyid($1)
          user[:name]
        rescue => e
          nil
        end
      end

    when /^list/
      if UserConfig[:tab_label_list]
        i_tab.name
      else
        nil
      end

    else
      nil

    end

    if msg
      #widgets[:center] << ::Gtk::Label.new(msg) 
      a = ::Gtk::Label.new(msg)
      a.angle = 270
      widgets[:center] << a

    end

    [i_tab, widgets]
  }
}
