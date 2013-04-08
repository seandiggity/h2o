var popup_item_id = 0;
var popup_item_type = '';
var is_owner = false;
var permissions = {
  can_position_update: false,
  can_edit_notes: false
};
var last_data;
var access_results;
var panel_offset;
var panel_width;
var min_tick_width = 10;

$.noConflict();

jQuery.extend({
  classType: function() {
    return jQuery('body').attr('id').replace(/^b/, '');
  },
  rootPath: function(){
    return '/';
  },
  mustache: function(template, data, partial, stream) {
    if(Mustache && template && data) {
      return Mustache.to_html(template, data, partial, stream);
    }
  },
  observeResultsHover: function() {
    jQuery('#results_set .listitem').hover(function() {
      jQuery(this).find('.icon').addClass('hover');
    }, function() {
      jQuery(this).find('.icon').removeClass('hover');
    });
  },
  initializeTooltips: function() {
    jQuery('.tooltip').tipsy({ gravity: 's', live: true });
  },
  initializeHomePageBehavior: function() {
    jQuery('#featured_playlists .item, #featured_users .item').hoverIntent(function() {
      jQuery(this).find('.additional_details').slideDown(500);
    }, function() {
      jQuery(this).find('.additional_details').slideUp(200);
    });
  },
  observeTabDisplay: function(region) {
    jQuery(region + ' .link-add a, ' + region + ' a.link-add').live('click', function() {
      var element = jQuery(this);
      var current_id = element.data('item_id');
      if(jQuery('.singleitem').size()) {
        element.parentsUntil('.listitem').last().parent().addClass('adding-item');
      }
      if(popup_item_id != 0 && current_id == popup_item_id) {
        jQuery('.add-popup').hide();
        popup_item_id = 0;
      } else {
        popup_item_id = current_id;
        popup_item_type = element.data('type');
        var position = element.offset();
        var results_posn = jQuery('.add-popup').parent().offset();
        var left = position.left - results_posn.left;
        jQuery('.add-popup').hide().css({ top: position.top + 24, left: left }).fadeIn(100);
      }

      return false;
    });
    jQuery('.new-playlist-item').click(function(e) {
      var itemName = popup_item_type.charAt(0).toUpperCase() + popup_item_type.slice(1);
      jQuery.addItemToPlaylistDialog(popup_item_type + 's', itemName, popup_item_id, jQuery('#playlist_id').val()); 
      e.preventDefault();
    });
  },
  initializeCreatePopup: function() {
    jQuery('#create_all:not(.active)').live('click', function(e) {
      e.preventDefault();
      jQuery('#create_all_popup').show();
      jQuery(this).addClass('active');
    });
    jQuery('#create_all.active').live('click', function(e) {
      e.preventDefault();
      jQuery('#create_all_popup').hide();
      jQuery(this).removeClass('active');
    });
  },
  initializeHomepagePagination: function() {
    jQuery('.load_more_pagination a').live('click', function(e) {
      e.preventDefault();
      var current = jQuery(this);
      jQuery.ajax({
        method: 'GET',
        url: current.attr('href'),
        beforeSend: function(){
           jQuery.showGlobalSpinnerNode();
        },
        dataType: 'html',
        success: function(html){
          jQuery.hideGlobalSpinnerNode();
          current.parent().parent().append(jQuery(html));
          current.parent().remove();
          jQuery.initializeBarcodes();
        }
      });
    });
  },
  initializeBarcodes: function() {
    jQuery('.barcode a').tipsy({ gravity: 's', trigger: 'manual' });
    jQuery('.barcode a').mouseover(function() {
      jQuery(this).tipsy('show');
      jQuery('.tipsy').addClass(jQuery(this).attr('class'));
    }).mouseout(function() {
      jQuery(this).tipsy('hide');
    });
    jQuery.each(jQuery('.barcode:not(.adjusted)'), function(i, el) {
      var current = jQuery(el);
      current.addClass('adjusted');
      var barcode_width = current.width();
      if(current.data('karma')*3 > barcode_width) {
        current.find('.barcode_wrapper').css({ left: '0px', width: current.data('karma') * 3 + current.data('ticks') });
      } else {
        current.find('.barcode_wrapper').css({ padding: '0px' });
        current.find('.overflow').hide();
        if(jQuery('#playlist.singleitem').size() && current.parent().hasClass('additional_details')) {
          current.width(current.data('karma') * 3 + current.data('ticks') + 5);
        }
      }
    });
    jQuery('.barcode').animate({ opacity: 1.0 });

    //TODO: Clean this up a bit to be more precise
    jQuery('span.right_overflow:not(.inactive)').live('click', function() {
      var current = jQuery(this);
      var wrapper = current.siblings('.barcode_wrapper');
      var min_left_position = -1*(wrapper.width() + 21 - current.parent().width());
      var standard_shift = -1*(current.parent().width() - 21);
      var position = parseInt(jQuery(this).siblings('.barcode_wrapper').css('left').replace('px', ''));
      if(position + standard_shift < min_left_position) {
        wrapper.animate({ left: min_left_position });
        current.addClass('inactive');
      } else {
        wrapper.animate({ left: position + standard_shift });
      }
      current.siblings('.left_overflow').removeClass('inactive');
    });
    jQuery('span.left_overflow:not(.inactive)').live('click', function() {
      var current = jQuery(this);
      var wrapper = current.siblings('.barcode_wrapper');
      var standard_shift = -1*(current.parent().width() - 21);
      var position = parseInt(jQuery(this).siblings('.barcode_wrapper').css('left').replace('px', ''));
      if(position - standard_shift > 0) {
        wrapper.animate({ left: 0 });
        current.addClass('inactive');
      } else {
        wrapper.animate({ left: position - standard_shift });
      }
      current.siblings('.right_overflow').removeClass('inactive');
    });
  },
  initializeEditPanelAdjust: function() {
    //TODO: Figure out behavior when right panel is very long, e.g. playlist 945
    if(jQuery('.right_panel').size()) {
      panel_offset = jQuery('.right_panel:not(#playlist_barcode)').offset();
      panel_width = jQuery('.right_panel:not(#playlist_barcode):visible').width();
      jQuery(window).scroll(function() {
        if(jQuery(window).scrollTop() < panel_offset.top) {
          jQuery('.right_panel:visible').css({ position: "static", width: panel_width });
        } else {
          jQuery('.right_panel:visible').css({ position: "fixed", top: "0px", left: panel_offset.left, width: panel_width });
        }
      });
    }
  },
  setFontSize: function(value) {
    //Adding backwards compatibility
    if(value > 2) {
      value = parseFloat(value) / 10;
    }
    jQuery.cookie('font_size', value, { path: "/" });
    jQuery('.font-size-popup select').val(value);
    jQuery('.jsb *').addClass('no_adjust');
    jQuery('.singleitem *:not(.no_adjust,.smaller,:has(*)),.right_panel *:not(.no_adjust,:has(*))').css({ 'font-size' : (value*100) + '%', 'line-height' : (value*100) + '%' });
    jQuery('.singleitem *.smaller').css('font-size', (value*100 - 20) + '%');
  },
  initializeViewerToggle: function() {
    jQuery('#collapse_toggle').click(function(e) {
      e.preventDefault();
      var el = jQuery(this);
      if(el.hasClass('expanded')) {
        el.removeClass('expanded');
        if(jQuery('#edit_toggle').size() && jQuery('#edit_toggle').hasClass('edit_mode')) {
          jQuery('.singleitem').animate({ width: "70%" }, 100, 'swing', function() {
            jQuery('#edit_item').fadeIn(200);
          });
        } else {
          jQuery('.singleitem').animate({ width: "70%" }, 100, 'swing', function() {
            jQuery('#stats').fadeIn(200);
          });
        }
      } else {
        el.addClass('expanded');
        if(jQuery('#edit_toggle').size() && jQuery('#edit_toggle').hasClass('edit_mode')) {
          jQuery('#edit_item').fadeOut(200, function() {
            jQuery('.singleitem').animate({ width: "100%" }, 100);
          });
        } else {
          jQuery('#stats').fadeOut(200, function() {
            jQuery('.singleitem').animate({ width: "100%" }, 100);
          });
        }
      }
    });
    jQuery('#edit_toggle').click(function(e) {
      e.preventDefault();
      jQuery('#edit_item #status_message').remove();
      var el = jQuery(this);
      if(jQuery(this).hasClass('edit_mode')) {
        el.removeClass('edit_mode');
        jQuery('#playlist .dd').removeClass('playlists-edit-mode');
        jQuery('#playlist .dd .icon').removeClass('hover');
        if(jQuery('#collapse_toggle').hasClass('expanded')) {
          jQuery('#edit_item').fadeOut(200, function() {
            jQuery('.singleitem').animate({ width: "100%" }, 100);
          });
        } else {
          jQuery('#edit_item').fadeOut(200, function() {
            jQuery('#stats').fadeIn(200);
          });
        }
      } else {
        el.addClass('edit_mode');
        jQuery('#playlist .dd').addClass('playlists-edit-mode');
        jQuery('#playlist .dd .icon').addClass('hover');
        if(jQuery('#collapse_toggle').hasClass('expanded')) {
          jQuery('#collapse_toggle').removeClass('expanded');
          jQuery('.singleitem').animate({ width: "70%" }, 100, 'swing', function() {
            jQuery('#edit_item').fadeIn(200);
          });
        } else {
          jQuery('#stats').fadeOut(200, function() {
            jQuery('#edit_item').fadeIn(200);
          });
        }
      }
    });
  },
  loadSlideOutTabBehavior: function() {
    jQuery('.slide-out-div').tabSlideOut({
      tabHandle: '.handle',                     //class of the element that will become your tab
      pathToTabImage: '/images/ui/report_error.png', //path to the image for the tab //Optionally can be set using css
      imageHeight: '189px',                     //height of tab image           //Optionally can be set using css
      imageWidth: '31px',                       //width of tab image            //Optionally can be set using css
      tabLocation: 'right',                      //side of screen where tab lives, top, right, bottom, or left
      speed: 500,                               //speed of animation
      action: 'click',                          //options: 'click' or 'hover', action to trigger animation
      topPos: '300px',                          //position from the top/ use if tabLocation is left or right
      leftPos: '20px',                          //position from left/ use if tabLocation is bottom or top
      fixedPosition: true                      //options: true makes it stick(fixed position) on scroll
      //TODO: on open hide errors
    });
    jQuery('#defect_submit').click(function(e) {
      e.preventDefault();
      jQuery('#defect-form').ajaxSubmit({
        dataType: "JSON",
        beforeSend: function(){
          jQuery.showGlobalSpinnerNode();
          jQuery('#user-feedback-success, #user-feedback-error').hide().html('');
        },
        success: function(response){
          jQuery.hideGlobalSpinnerNode();
          if(response.error) {
            jQuery('#user-feedback-error').show().html(response.message);
          } else {
            jQuery.hideGlobalSpinnerNode();
            jQuery('#user-feedback-success').show().html('Thanks for your feedback. Panel will close shortly.');
            jQuery('#defect_description').val(' ');
            setTimeout(function() {
              jQuery('.handle').click();
              setTimeout(function() {
                jQuery('#user-feedback-success, #user-feedback-error').hide().html('');
              }, 500);
            }, 2000);
          }
        },
        error: function(data){
          jQuery.hideGlobalSpinnerNode();
          jQuery('#user-feedback-error').show().html('Sorry. We could not process your error. Please try again.');
        }
      });
    });
  },
  hideVisiblePopups: function() {
    if(jQuery('.btn-a-active').length) {
      jQuery('.btn-a-active').click();
    }
    if(jQuery('li.btn .active').length) {
      jQuery('li.btn .active').click();
    }
    if(jQuery('.add-popup').is(':visible')) {
      jQuery('.add-popup').hide();
      popup_item_id = 0;
    }
    if(jQuery('#collage-stats-popup').is(':visible')) {
      jQuery('#collage-stats').click();
    }
    if(jQuery('#playlist-stats-popup').is(':visible')) {
      jQuery('#playlist-stats').click();
    }
  },
  loadPopupCloseListener: function() {
    jQuery('.close-popup').live('click', function(e) {
      e.preventDefault();
      jQuery.hideVisiblePopups();
    });
  },
  loadEscapeListener: function() {
    jQuery(document).keyup(function(e) {
      if(e.keyCode == 27) {
        jQuery.hideVisiblePopups();
      }
    });
  },
  loadOuterClicks: function() {
    jQuery('html').click(function(event) {
      var dont_hide = jQuery('.font-size-popup,.add-popup,.tools-popup,#collage-stats-popup,#playlist-stats-popup').has(event.target).length > 0 ? true : false;
      if(jQuery(event.target).hasClass('jsb-moreButton')) {
        dont_hide = true;
      }
      if(!dont_hide) {
        jQuery.hideVisiblePopups();
      }
    });
  },
  loadGenericEditability: function() {
    if(jQuery('ul#logged-in').size()) {
      jQuery('.requires_logged_in').animate({ opacity: 1.0 });
    }
  },
  loadEditability: function() {
    jQuery.ajax({
      type: 'GET',
      cache: false,
      url: editability_path,
      dataType: "JSON",
      beforeSend: function(){
        jQuery.showGlobalSpinnerNode();
      },
      error: function(xhr){
        jQuery.hideGlobalSpinnerNode();
        jQuery('.requires_edit').remove();
        jQuery('.requires_logged_in').remove();
        jQuery('.afterload').animate({ opacity: 1.0 });
        jQuery.hideGlobalSpinnerNode();
        jQuery.loadState();
      },
      success: function(results){
        //Global methods
        access_results = results;
        if(results.logged_in) {
          var data = jQuery.parseJSON(results.logged_in);
          jQuery('.requires_logged_in .user_account').append(jQuery('<a>').html(data.user.login).attr('href', "/users/" + data.user.id));
          jQuery('#defect_user_id').val(data.user.id);
          jQuery('.requires_logged_in').animate({ opacity: 1.0 });
          jQuery('#header_login').remove();
        } else {
          jQuery('.requires_logged_in').remove();
        }
        jQuery('.afterload').animate({ opacity: 1.0 });
        jQuery.hideGlobalSpinnerNode();

        if(jQuery.classType() == 'collages') {  //Collages only
          last_data = jQuery.parseJSON(results.readable_state);
          jQuery.loadState();
          if(results.can_edit_annotations) {
            jQuery.listenToRecordCollageState();
            jQuery('.requires_edit').animate({ opacity: 1.0 });
          } else {
            jQuery('.requires_edit').remove();
          }
          if(results.can_edit_description) {
            jQuery('.collage_edit').animate({ opacity: 1.0 });
          } else {
            jQuery('.collage_edit').remove();
          }
        } else if(jQuery.classType() == 'playlists') {  //Playlists only
          if(results.can_edit || results.can_edit_notes || results.can_edit_desc) {
            if (results.can_edit) {
              jQuery('.requires_edit, .requires_remove').animate({ opacity: 1.0 });
              is_owner = true;
            } else {
              if(!results.can_edit_notes) {
                jQuery('#description .public-notes, #description .private-notes').remove();
              }
              if(!results.can_edit_desc) {
                jQuery('#description .icon-edit').remove();
              }
              jQuery('.requires_remove').remove();
              jQuery('.requires_edit').animate({ opacity: 1.0 });
            }
          } else {
            jQuery('.requires_edit, .requires_remove').remove();
          }
          var notes = jQuery.parseJSON(results.notes); 
          jQuery.each(notes, function(i, el) {
            if(el.playlist_item.notes != null) {
              var title = el.playlist_item.public_notes ? "Additional Notes" : "Additional Notes (private)";
              var node = jQuery('<div>').html('<b>' + title + ':</b><br />' + el.playlist_item.notes).addClass('notes');
              if(jQuery('#playlist_item_' + el.playlist_item.id + ' > .data .notes').length) {
                jQuery('#playlist_item_' + el.playlist_item.id + ' > .data .notes').remove();
              } 
              jQuery('#playlist_item_' + el.playlist_item.id + ' > .data').append(node);
            }
          });
          jQuery('.add-popup select option').remove();
          var playlists = jQuery.parseJSON(results.playlists); 
          jQuery.each(playlists, function(i, el) {
            var node = jQuery('<option>').val(el.playlist.id).text(el.playlist.name);
            jQuery('.add-popup select').append(node);
          });
          jQuery.observeDragAndDrop();
        }
      }
    });
  },
  initializeTabBehavior: function() {
    jQuery('.tabs a').click(function(e) {
      var region = jQuery(this).data('region');
      jQuery('.add-popup').hide();
      popup_item_id = 0;
      popup_item_type = '';
      jQuery('.tabs a').removeClass("active");
      jQuery('.songs > ul').hide();
      jQuery('.pagination > div, .sort > div').hide();
      jQuery('#' + region +
        ',.' + region + '_pagination' +
        ',#' + region + '_sort').show();
      jQuery(this).addClass("active");
      e.preventDefault();
    });
    //TODO: Possibly generic-ize this later if more of this
    //functionality is needed. For now it's only needed
    //on bookmarks
    if(document.location.hash == '#vbookmarks') {
      jQuery('#bookmark_tab').click();
    } else {
      jQuery('.tabs a:first').click();
    }
  },
  observeLoginPanel: function() {
    jQuery('#header_login').click(function(e) {
      jQuery(this).toggleClass('active');
      jQuery('#login-popup').toggle();
      e.preventDefault();
    });
  },
  addItemToPlaylistDialog: function(itemController, itemName, itemId, playlistId) {
    var url_string = jQuery.rootPathWithFQDN() + itemController + '/' + itemId;
    if(itemController == 'defaults') {
      url_string = itemId;
    }
    jQuery.ajax({
      method: 'GET',
      cache: false,
      dataType: "html",
      url: jQuery.rootPath() + 'item_' + itemController + '/new',
      beforeSend: function(){
           jQuery.showGlobalSpinnerNode();
      },
      data: {
        url_string: url_string,
        container_id: playlistId
      },
      success: function(html){
        jQuery.hideGlobalSpinnerNode();
        jQuery('#dialog-item-chooser').dialog('close');
        jQuery('#generic-node').remove();
        var addItemDialog = jQuery('<div id="generic-node"></div>');
        jQuery(addItemDialog).html(html);
        jQuery(addItemDialog).dialog({
          title: 'Add ' + itemName ,
          modal: true,
          width: 'auto',
          height: 'auto',
          buttons: {
            Save: function(){
              jQuery.submitGenericNode();
            },
            Close: function(){
              jQuery(addItemDialog).dialog('close');
            }
          }
        });
      }
    });
  },
  observeMarkItUpFields: function() {
    jQuery('.textile_description').observeField(5,function(){
        jQuery.ajax({
        cache: false,
        type: 'POST',
        url: jQuery.rootPath() + 'collages/description_preview',
        data: {
            preview: jQuery('.textile_description').val()
        },
           success: function(html){
            jQuery('.textile_preview').html(html);
        }
        });
    });
  },
  listResults: function(href) {
    jQuery.ajax({
      type: 'GET',
      dataType: 'html',
      url: href,
      beforeSend: function(){
           jQuery.showGlobalSpinnerNode();
         },
         error: function(xhr){
           jQuery.hideGlobalSpinnerNode();
      },
      success: function(html){
        jQuery.address.value(href);
        jQuery.hideGlobalSpinnerNode();
        if(jQuery('#busers').length) {
          //TODO TODO
          //jQuery('#TODO').html(html);
          //var class_region = region.replace(/^#/, '.');
          //jQuery(class_region + '_pagination').html(jQuery(region + ' #new_pagination').html()); 
        } else {
          jQuery('#results_set').html(html);
          jQuery('.pagination').html(jQuery('#new_pagination').html());
          jQuery.initializeBarcodes();
        }
      }
    });
  },
  observeSort: function() {
    jQuery('.sort select').selectbox({
      className: "jsb", replaceInvisible: true 
    }).change(function() {
      var sort = jQuery(this).val();
      var url = document.location.pathname;
      if(document.location.search != '') {
        url += document.location.search + "&sort=" + sort;
      } else {
        url += "&sort=" + sort;
      }
      jQuery.listResults(url);
    });
  },
  observePagination: function(){
    jQuery('.pagination a').live('click', function(e){
      e.preventDefault();
      jQuery.listResults(jQuery(this).attr('href'));
    });
  },

  observeMetadataForm: function(){
    jQuery('.datepicker').datepicker({
      changeMonth: true,
      changeYear: true,
      yearRange: 'c-300:c',
      dateFormat: 'yy-mm-dd'
    });
    jQuery('form .metadata ol').toggle();
    jQuery('form .metadata legend').bind({
      click: function(e){
        e.preventDefault();
        jQuery('form .metadata ol').toggle();
      },
      mouseover: function(){
        jQuery(this).css({cursor: 'hand'});
      },
      mouseout: function(){
        jQuery(this).css({cursor: 'pointer'});
      }
    });
  },

  observeMetadataDisplay: function(){
    jQuery('.metadatum-display').click(function(e){
      e.preventDefault();
      jQuery(this).find('ul').toggle();
    });
  },

  observeTagAutofill: function(className,controllerName){
    if(jQuery(className).length > 0){
     jQuery(className).live('click',function(){
     jQuery(this).tagSuggest({
       url: jQuery.rootPath() + controllerName + '/autocomplete_tags',
       separator: ', ',
       delay: 500
     });
     });
   }
  },

  /* Only used in collages.js */
  trim11: function(str) {
    // courtesty of http://blog.stevenlevithan.com/archives/faster-trim-javascript
    var str = str.replace(/^\s+/, '');
    for (var i = str.length - 1; i >= 0; i--) {
      if (/\S/.test(str.charAt(i))) {
        str = str.substring(0, i + 1);
        break;
      }
    }
    return str;
  },

  /* Only used in new_playlists.js */
  rootPathWithFQDN: function(){
    return location.protocol + '//' + location.hostname + ((location.port == '' || location.port == 80 || location.port == 443) ? '' : ':' + location.port) + '/';
  },
  serializeHash: function(hashVals){
    var vals = [];
    for(var val in hashVals){
    if(val != undefined){
      vals.push(val);
    }
    }
    return vals.join(',');
  },
  unserializeHash: function(stringVal){
    if(stringVal && stringVal != undefined){
    var hashVals = [];
    var arrayVals = stringVal.split(',');
    for(var i in arrayVals){
      hashVals[arrayVals[i]]=1;
    }
    return hashVals;
    } else {
    return new Array();
    }
  },

  showGlobalSpinnerNode: function() {
    jQuery('#spinner').show();
  },
  hideGlobalSpinnerNode: function() {
    jQuery('#spinner').hide();
  },
  showMajorError: function(xhr) {
    //empty for now
  },
  getItemId: function(element) {
    return jQuery(".singleitem").data("itemid");
  },
  toggleVisibilitySelector: function() {
    if (jQuery('.privacy_toggle').attr("checked") == "checked"){
      jQuery('#terms_require').html("<p class='inline-hints'>Submitting this item will allow others to see, copy, and create derivative works from this item in accordance with H2O's <a href=\"/p/terms\" target=\"_blank\">Terms of Service</a>.</p>")
    } else {
      jQuery('#terms_require').html("<p class='inline-hints'>If this item is submitted as a non-public item, other users will not be able to see, copy, or create derivative works from it, unless you change the item's setting to \"Public.\" Note that making a previously \"public\" item non-public will not affect copies or derivatives made from that public version.</p>");
    }
  },

  /* 
  This is a generic UI function that applies to all elements with the "icon-delete" class.
  With this, a dialog box is generated that asks the user if they want to delete the item (Yes, No).
  When a user clicks "Yes", an ajax call is made to the link's href, which responds with JSON.
  The listed item is then removed from the UI.
  */
  observeDestroyControls: function(region){
    jQuery(region + ' .icon-delete').live('click', function(e){
      e.preventDefault();
      if(jQuery(this).parent().hasClass('delete-playlist-item')) {
        return;
      }
      var destroyUrl = jQuery(this).attr('href');
      var item_id = destroyUrl.match(/[0-9]+$/).toString();
      var confirmNode = jQuery('<div><p>Are you sure you want to delete this item?</p></div>');
      jQuery(confirmNode).dialog({
        modal: true,
        buttons: {
          Yes: function() {
            jQuery.ajax({
              cache: false,
              type: 'POST',
              url: destroyUrl,
              dataType: 'JSON',
              data: {'_method': 'delete'},
              beforeSend: function() {
                jQuery.showGlobalSpinnerNode();
              },
              error: function(xhr){
                jQuery.hideGlobalSpinnerNode();
              },
              success: function(data){
                jQuery(".listitem" + item_id).animate({ opacity: 0.0, height: 0 }, 200, function() {
                  jQuery(".listitem" + item_id).remove();
                  if(jQuery('#playlist').size()) {
                    jQuery.update_positions(data.position_data);
                  }
                });
                jQuery.hideGlobalSpinnerNode();
                jQuery(confirmNode).remove();
              }
            });
          },
          No: function(){
            jQuery(confirmNode).remove();
          }
        }
      }).dialog('open');
    });
  },

  /*
  Generic bookmark item, more details here.
  */
  observeBookmarkControls: function(region) {
    jQuery(region + ' .bookmark-action').live('click', function(e){
      var item_url = jQuery.rootPathWithFQDN() + 'bookmark_item/';
      var el = jQuery(this);
      if(el.hasClass('bookmark-popup')) {
        item_url += popup_item_type + '/' + popup_item_id;
      } else if (el.hasClass('link-bookmark')) {
        item_url += el.data('type') + '/' + el.data('itemid');
      } else {        
        item_url += jQuery.classType() + '/' + jQuery('.singleitem').data('itemid');  
      }
      e.preventDefault();
      jQuery.ajax({
        cache: false,
        url: item_url,
        dataType: "JSON",
        data: {},
        beforeSend: function() {
          jQuery.showGlobalSpinnerNode();
        },
        success: function(data) {
          jQuery('.add-popup').hide();
          jQuery.hideGlobalSpinnerNode();

          var snode;
          if(data.already_bookmarked) {
            alert('already bookmarked!');
            //snode = jQuery('<span class="bookmarked">').html('ALREADY BOOKMARKED!').append(
            //jQuery('<a>').attr('href', jQuery.rootPathWithFQDN() + 'users/' + data.user_id + '#vbookmarks').html('VIEW BOOKMARKS'));
          } else {
            alert('bookmarked!');
            //snode = jQuery('<span class="bookmarked">').html('BOOKMARKED!').append(
            //jQuery('<a>').attr('href', jQuery.rootPathWithFQDN() + 'users/' + data.user_id + '#vbookmarks').html('VIEW BOOKMARKS'));
          }

          //TODO: Should we rerender barcode when an item is bookmarked?

 /*
          if(el.hasClass('bookmark-popup') || el.hasClass('bookmark-link')) {
            if(jQuery.classType() == 'users' && jQuery('#bookmark_tab').hasClass('active')) {
              snode.html('ALREADY BOOKMARKED!');
               jQuery('hgroup.' + popup_item_type + popup_item_id + ' .bookmarked').remove();
               snode.insertBefore(jQuery('hgroup.' + popup_item_type + popup_item_id + ' .cl'));
            } else if(jQuery.classType() == 'playlists' && jQuery('.singleitem').size() && popup_item_type != 'default') {
               jQuery('hgroup.' + popup_item_type + popup_item_id + ' .bookmarked').remove();
               snode.insertBefore(jQuery('hgroup.' + popup_item_type + popup_item_id + ' .cl'));
            } else if (el.hasClass('bookmark-link')){
               jQuery('.listitem' + el.data('itemid') + ' h4 .bookmarked').remove();
               jQuery('.listitem' + el.data('itemid') + ' h4').append(snode);
            } else {
               jQuery('.listitem' + popup_item_id + ' h4 .bookmarked').remove();
               jQuery('.listitem' + popup_item_id + ' h4').append(snode);
            }
          } else {
            jQuery('.singleitem > .description > h2 .bookmarked,#fixed_header > .description > h2 .bookmarked').remove();
            jQuery('.singleitem > .description > h2,#fixed_header > .description h2').append(snode);
          }
          */
        },
        error: function(xhr, textStatus, errorThrown) {
          jQuery.hideGlobalSpinnerNode();
        }
      });
    });
  },

  /* New Playlist and Add Item */
  observeNewPlaylistAndItemControls: function() {
      jQuery('.new-playlist-and-item').live('click', function(e){
      var item_id = popup_item_id;
      var actionUrl = jQuery(this).attr('href');
      e.preventDefault();
      jQuery.ajax({
        cache: false,
        url: actionUrl,
        beforeSend: function() {
          jQuery.showGlobalSpinnerNode();
        },
        success: function(html) {
          jQuery.hideGlobalSpinnerNode();
          jQuery.generateSpecialPlaylistNode(html);
        },
        error: function(xhr, textStatus, errorThrown) {
          jQuery.hideGlobalSpinnerNode();
        }
      });
    });
  },
  generateSpecialPlaylistNode: function(html) {
    var newItemNode = jQuery('<div id="special-node"></div>').html(html);
    var title = '';
    if(newItemNode.find('#generic_title').length) {
      title = newItemNode.find('#generic_title').html();
    }
    jQuery(newItemNode).dialog({
      title: title,
      modal: true,
      width: 'auto',
      height: 'auto',
      open: function(event, ui) {
        jQuery.observeMarkItUpFields();
      },
      close: function() {
        jQuery(newItemNode).remove();
      },
      buttons: {
        Submit: function() {
          jQuery('#special-node').find('form').ajaxSubmit({
            dataType: "JSON",
            beforeSend: function() {
              jQuery.showGlobalSpinnerNode();
            },
            success: function(data) {
              jQuery(newItemNode).dialog('close');
              var itemName = popup_item_type.charAt(0).toUpperCase() + popup_item_type.slice(1);
              jQuery.addItemToPlaylistDialog(popup_item_type + 's', itemName, popup_item_id, data.id);
            },
            error: function(xhr) {
              jQuery.hideGlobalSpinnerNode();
            }
          });
        },
        Close: function() {
          jQuery(newItemNode).remove();
        }
      }
    }).dialog('open');
  },

  /* Generic HTML form elements */
  observeGenericControls: function(region){
    jQuery(region + ' .remix-action,' + region + ' .icon-edit,' + region + ' .new-action').live('click', function(e){
      var actionUrl = jQuery(this).attr('href');
      e.preventDefault();
      jQuery.ajax({
        cache: false,
        url: actionUrl,
        beforeSend: function() {
            jQuery.showGlobalSpinnerNode();
        },
        success: function(html) {
          jQuery.hideGlobalSpinnerNode();
          jQuery.generateGenericNode(html);
        },
        error: function(xhr, textStatus, errorThrown) {
            jQuery.hideGlobalSpinnerNode();
        }
      });
    });
  },
  generateGenericNode: function(html) {
    jQuery('#generic-node').remove();
    var newItemNode = jQuery('<div id="generic-node"></div>').html(html);
    var title = '';
    if(newItemNode.find('#generic_title').length) {
      title = newItemNode.find('#generic_title').html();
    }
    jQuery(newItemNode).dialog({
      title: title,
      modal: true,
      width: 'auto',
      height: 'auto',
      open: function(event, ui) {
        jQuery.observeMarkItUpFields();
        if(newItemNode.find('#manage_playlists').length) {
          jQuery('#manage_playlists #lookup_submit').click();
        }
        if(newItemNode.find('#manage_collages').length) {
          jQuery('#manage_collages #lookup_submit').click();
        }
        if(newItemNode.find('#terms_require').length) {
          if(newItemNode.find('.privacy_toggle').length){
            jQuery('.privacy_toggle').click(function(){
              jQuery.toggleVisibilitySelector();
            });
          }
        }
        jQuery.toggleVisibilitySelector();
      },
      buttons: {
        Submit: function() {
          jQuery.submitGenericNode();
        },
        Close: function() {
          jQuery(newItemNode).remove();
        }
      }
    }).dialog('open');
  },
  submitGenericNode: function() {
    jQuery('#generic-node #error_block').html('').hide();
    var buttons = jQuery('#generic-node').parent().find('button');
    if(buttons.first().hasClass('inactive')) {
      return false;
    }
    buttons.addClass('inactive');
    jQuery('#generic-node').find('form').ajaxSubmit({
      dataType: "JSON",
      beforeSend: function() {
        jQuery.showGlobalSpinnerNode();
      },
      success: function(data) {
        if(data.error) {
          jQuery('#generic-node #error_block').html(data.message).show(); 
          jQuery.hideGlobalSpinnerNode();
          buttons.removeClass('inactive');
        } else {
          if(data.custom_block) {
            eval('jQuery.' + data.custom_block + '(data)');
          } else {
            setTimeout(function() {
              var redirect_to = jQuery.rootPath() + data.type + '/' + data.id;
              var use_new_tab = jQuery.cookie('use_new_tab');
              if(use_new_tab == 'true'){
                window.open(redirect_to, '_blank');
              }
              else{
                document.location.href = redirect_to;
              }
                
            }, 1000);
          }
        }
      },
      error: function(xhr) {
        jQuery.hideGlobalSpinnerNode();
      }
    });
  }
});

jQuery(function() {
  
  /* Only used in collages */
  jQuery.fn.observeField =  function( time, callback ){
    return this.each(function(){
      var field = this, change = false;
      jQuery(field).keyup(function(){
        change = true;
      });
      setInterval(function(){
        if ( change ) callback.call( field );
        change = false;
      }, time * 1000);
    });
  }

  jQuery('#search_button').live('click', function(e) {
    e.preventDefault();
    jQuery("#search form").attr("action", "/" + jQuery('select#search_all').val());
    jQuery('#search form').submit();
  });
  jQuery('select#search_all').selectbox({
    className: "jsb", replaceInvisible: true 
  });

  jQuery(".link-more,.link-less").click(function(e) {
    jQuery("#description_less,#description_more").toggle();
    e.preventDefault();
  });

  jQuery('.item_drag_handle').button({icons: {primary: 'ui-icon-arrowthick-2-n-s'}});

  jQuery('li.submit a').click(function() {
    jQuery('form.search').submit();
  });

  /* End TODO */

  //Set current AJAX sort value
  if(document.location.hash.match('ajax_region=') || document.location.hash.match('sort=')) {
    var sort_region = '#all_' + jQuery.address.parameter('ajax_region') + '_sort';
    jQuery(sort_region + ' select').val(jQuery.address.parameter('sort'));
  }

  jQuery.loadGenericEditability();
  jQuery.initializeBarcodes();
  jQuery.observeDestroyControls('');
  jQuery.observeGenericControls('');
  jQuery.observeBookmarkControls('');
  jQuery.observeNewPlaylistAndItemControls();
  jQuery.observePagination(); 
  jQuery.observeSort();
  jQuery.observeTabDisplay('');
  jQuery.observeLoginPanel();
  jQuery.observeResultsHover();
  jQuery.initializeTabBehavior();
  jQuery.loadEscapeListener();
  jQuery.loadPopupCloseListener();
  jQuery.loadOuterClicks();
  jQuery.loadSlideOutTabBehavior();
  jQuery.initializeViewerToggle();
  jQuery.initializeEditPanelAdjust();
  jQuery.initializeHomepagePagination();
  jQuery.initializeTooltips();
  jQuery.initializeCreatePopup();
  jQuery.initializeHomePageBehavior();

  if(document.location.hash.match('ajax_region=') || document.location.hash.match('page=')) {
    jQuery.listResults(jQuery.address.value());
  }

  var expanded_v = jQuery.cookie('expanded');
  if(expanded_v != null) {
    var expanded = expanded_v.split('-');
    for(var i=0;i<expanded.length;i++) {
      jQuery('#' + expanded[i]).click();
    }
  } 

  //For Now, this is disabled. If set to true,
  //code updates are required to work with back button
  //on each pagination and sort
  jQuery.address.history(false);
});
// -------------------------------------------------------------------
// markItUp!
// -------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// -------------------------------------------------------------------
// Textile tags example
// http://en.wikipedia.org/wiki/Textile_(markup_language)
// http://www.textism.com/
// -------------------------------------------------------------------
// Feel free to add more tags
// -------------------------------------------------------------------
var h2oTextileSettings = {
  nameSpace: 'textile',
  previewParserPath:  '/base/preview_textile_content',
  previewAutoRefresh: true,
  onShiftEnter:    {keepDefault:false, replaceWith:'\n\n'},
  markupSet: [
    {name:'Bold', key:'B', closeWith:'*', openWith:'*'},
    {name:'Underline', key:'U', closeWith:'_', openWith:'_'},
    {separator:'---------------' },
    {name:'Link', openWith:'"', closeWith:'([![Title]!])":[![Link:!:http://]!]', placeHolder:'Your text to link here...' }
  ]
}

