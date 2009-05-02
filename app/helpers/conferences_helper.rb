module ConferencesHelper
  def conf_list_table(confs)
    row_classes = list_row_classes
    ret = []
    ret << table_tag << conf_list_head_row
    ret << confs.map do |conf| 
      conf_list_row(conf)
    end
    ret << end_table_tag

    ret.join("\n")
  end

  def conf_list_head_row
    table_head_row_tag <<
      ['',_('Conference'), _('Dates'), ''].map {|col| "<th>#{col}</th>"}.join <<
      end_table_row_tag
  end

  def conf_list_row(conf)
    table_row_tag <<
      [logo_thumb_for(conf),
       link_to(conf.name, :controller => 'conferences', 
                :action => 'show', 
                :short_name => conf.short_name),
        "#{conf.begins} - #{conf.finishes}",
        sign_up_person_for_conf_link(@user, conf)
      ].map {|col| "<td>#{col}</td>"}.join <<
      end_table_row_tag
  end

  def sign_up_person_for_conf_link(user, conf)
    return unless user

    if ! conf.accepts_registrations?
      return _('Registered') if user.conferences.include?(conf)
      return _('Registration closed')
    end

    if user.conferences.include? conf
      return link_to(_('Unregister'),
                     { :controller => 'conferences',
                       :action => 'unregister',
                       :id => conf},
                     { :method => :post,
                       :confirm => _('Confirm: Do you want to unregister ' +
                                     'from "%s"? ') % conf.name})
    else
      return link_to(_('Sign up'),
                     { :controller => 'conferences', 
                       :action => 'sign_up',
                       :id => conf}, 
                     { :method => :post })
    end
  end

  def all_details_for(conf)
    res = [ RedCloth.new(conf.descr).to_html ]
    res << ('<h3>%s</h3>' % _('Conference dates')) << 
      ('<p><b>%s:</b> %s<br/><b>%s: </b> %s</p>' %
       [_('Begins'), conf.begins, _('Finishes'), conf.finishes])

    res << ('<h3>%s</h3>' % _('Registration period')) <<
      ('<p><b>%s:</b> %s<br/><b>%s: </b> %s</p>' %
       [_('Begins'), conf.reg_open_date || _('Open'),
        _('Finishes'), conf.last_reg_date])

    res << ('<h3>%s</h3>' % _('Call for papers period')) 
    if conf.has_cfp?
      res << ('<p><b>%s:</b> %s<br/><b>%s: </b> %s</p>' %
              [_('Begins'), conf.cfp_open_date || _('Open'),
               _('Finishes'), conf.last_cfp_date])
    else
      res << ('<p>%s</p>' % _('No public call for papers'))
    end
    res.join("\n")
  end

  def conf_edit_links(conf)
    return '' unless @can_edit
    '<div class="conf-edit">' +
      [link_to(_('%d registered attendees') % conf.people.size,
               :controller => 'conferences_adm', 
               :action => 'people_list', :id => conf),
       link_to(_('Edit conference'), :controller => 'conferences_adm',
               :action => :show, :id => conf),
       link_to(_('Edit timeslots'),
               :controller => 'conferences_adm',
               :action => 'timeslots', 
               :id => conf)
      ].join(' | ') + '</div>'
  end

  def logo_thumb_for(conf)
    link_for_logo(conf, 'thumb')
  end

  def display_logo(conf)
    return '' unless logo=conf.logo
    '<div class="conf-logo">' + 
      ( logo.bigger_than_medium? ? 
        link_to(link_for_logo(conf, 'medium'),
                :controller => 'logos', :action => 'data', :id => logo) : 
        link_for_logo(conf, 'medium') ) + '</div>'
  end

  def link_for_logo(conf, size)
    %w(data medium thumb).include?(size) or
      raise Exception, _('Invalid logo size specified: %s') % size 

    logo = conf.logo or return ''
    '<img src="%s" width="%s" height="%s" />' % 
      [ url_for(:controller => 'logos', :action => size,
                :id => logo.id), 
        logo.send("#{size}_width"), logo.send("#{size}_height") ]
  end
end
