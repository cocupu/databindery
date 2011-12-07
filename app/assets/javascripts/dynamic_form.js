$(function() {
  function templateContent(obj) {
    var assoc = obj.attr('data-association');
    var id = obj.attr('data-index');
    var content = $('#' + assoc + '_' + id + '_fields_template').html();
    var regexp = new RegExp('new_' + assoc, 'g');
    var new_id = new Date().getTime();
    return content.replace(regexp, new_id);
  }
  $('form a.add_child[data-association=field_mappings]').live('click', function() {
    $(this).prev().append(templateContent($(this)));
    return false;
  });
  $('form a.add_child[data-association=models]').live('click',function() {
    $(this).parent().before(templateContent($(this)));
    return false;
  });
  
  $('form a.remove_child').live('click', function() {
    var hidden_field = $(this).prev('input[type=hidden]')[0];
    if(hidden_field) {
      hidden_field.value = '1';
    }
    $(this).parents('.fields').hide();
    return false;
  });
});
